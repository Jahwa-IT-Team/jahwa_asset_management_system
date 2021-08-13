import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_result.dart';
import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

/*
Flutter StatefulWidget Page Example
StatefulWidget Lifecycle

1. createState()
2. mounted == true
3. initState()
4. didChangeDependencies()
*. setState()              - 개발자가 필요에 위해 State
*. didUpdateWidget()       - 부모 위젯이 변경된 경우 State 재구성시에만 호출
5. build()
6. deactivate()
7. dispose()
8. mounted == false

*/

class FacilityLocationChangePage extends StatefulWidget {
  //1. createState()
  //StatefulWidget이 빌드 되도록 createState() 호출
  //반드시 호출해야하며 아래 코드보다 더 복잡하거나 추가될 것이 없음
  //정상적으로 createState()호출되면 buildContext가 할당되면서 this.mounted 속성 true를 리턴(2. mounted == true)
  @override
  _FacilityLocationChangePageState createState() =>
      _FacilityLocationChangePageState();
}

class _FacilityLocationChangePageState
    extends State<FacilityLocationChangePage> {
  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();
  bool _isStreamAction = false;
  bool dialVisible = true;
  bool isBluetoothConnected = false;
  List<String> tempTagList = [];

  ScanResult scanResult;
  ProgressDialog pr;

  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  FacilityLocationRepository $facilityLocationRepository;

  Stream<dynamic> bluetoothStream = Btprotocol.instance.onChangeState;
  StreamSubscription bluetoothSubscription;

  //3. initState()
  //위젯이 생성될때 처음 한번 호출되는 메서드
  //initState에서 실행되면 좋은 것들
  //-.생성된 위젯 인스턴스의 BuildContext에 의존적인 것들의 데이터 초기화
  //-.동일 위젯트리내에 부모위젯에 의존하는 속성 초기화
  //-.Stream 구독, 알림변경, 또는 위젯의 데이터를 변경할 수 있는 다른 객체 핸들링.
  @override
  void initState() {
    //부모 initState() 호출
    super.initState();

    //Future 사용이 필요한 경우
    new Future.delayed(Duration.zero, () {
      _actionBluetoothStream();
    });

    // 스트림 리스너 추가
    //cartItemStream.listen((data) {
    //  _updateWidget(data);
    //});

    bluetoothSubscription = bluetoothStream.listen((event) {
      dataRead();
    });

    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    pr.style(
      message: getTranslated(context, 'Receiving ....'),
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
  }

  //4. didChangeDependencies()
  //메서드는 위젯이 최초 생성될때 initState() 다음에 바로 호출
  //위젯이 의존하는 데이터의 객체가 호출될때마다 호출된다. 예를 들면 업데이트되는 위젯을 상속한 경우.
  //공식문서 또한 상속한 위젯이 업데이트 될때 네트워크 호출(API 호출이 필요한 경우 유용)
  @override
  void didChangeDependencies() {
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    $facilityTradeCommonRepository =
        Provider.of<FacilityTradeCommonRepository>(context, listen: true);

    if ($facilityLocationRepository == null) {
      $facilityLocationRepository =
          Provider.of<FacilityLocationRepository>(context, listen: true);
      $facilityLocationRepository.init();
    }

    super.didChangeDependencies();
  }

  //*. didUpdateWidget()   --부모 위젯이 변경되어 재구성시에만 호출
  //부모 위젯이 변경되어 이 위젯을 재 구성해야 하는 경우(다음 데이터를 제공 해야하기 때문)
  //이것은 플러터가 오래동안 유지 되는 state를 다시 사용하기 때문이다. 이 경우 initState() 처럼 읿부 데이터를 다시 초기화 해야 한다.
  //build() 메서드가 Stream이나 변경 가능한 데이터에 의존적인경우 이전 객체에서 구독을 취소하고 didUpdateWidget()에서 새로운 인스턴스에 다시 구독 해야함.
  //tip: 이 메서드는 기본적으로 위젯의 상태와 관련된 위젯을 재 구성해야 하는 경우 initState()을 대치한다.
  //플러터는 항상 이 메서드 수행 후(?)에 build()메서드 호출 하므로, setState() 이후 모든 추가 호출은 불필요 하다.
  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   if (oldWidget.importantProperty != widget.importantProperty) {
  //     _init();
  //   }
  // }

  //5. build()
  //이 메서드는 자주 호출된다(fps + render라고 생각하면 됨)
  //반드시 Widget을 리턴해야 함
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold1Key,
      // appBar: AppBar(
      //   title: Text(pageTitle),
      //   backgroundColor: Colors.deepPurple,
      // ),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //filterView(),
            setLocationBox(),
            Padding(padding: const EdgeInsets.all(0.0), child: Column()),
            if ($facilityLocationRepository.facilityChangeList.length <= 0)
              introPage(),
            if ($facilityLocationRepository.facilityChangeList.length > 0)
              Expanded(
                child: getListView(),
              ),

            //SizedBox(height: 70,),
          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }

  //6. deactivate()
  //이 메서드는 거의 사용되지 않는다.
  //tree에서 State가 제거 될때 호출

  //7. dispose()
  //영구적인 State Object가 삭제될때 호출된다. 이 함수는 주로 Stream 이나 애니메이션 을 해제시 사용된다.
  @override
  void dispose() {
    Btprotocol.instance.clearData();
    //Btprotocol.instance.disconnectDevice();

    if (bluetoothSubscription != null) {
      bluetoothSubscription.cancel();
    }

    super.dispose();
  }

  //8. User Defined

  //위치 설정 박스
  Widget setLocationBox() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '${getTranslated(context, 'plant')} : ${$facilityLocationRepository.settingInspactionLocation.plantCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.plantName}'),
                      Text(
                          '${getTranslated(context, 'location')} : ${$facilityLocationRepository.settingInspactionLocation.setupLocationCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.setupLocation}'),
                      Text(
                          '${getTranslated(context, 'item_group')} : ${$facilityLocationRepository.settingInspactionLocation.itemGroupCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.itemGroupCode}'),
                    ],
                  ),
                ),
                TextButton(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Text(getTranslated(context, 'location'))
                        ],
                      )
                    ],
                  ),
                  onPressed: () => {
                    Navigator.pushNamed(
                        context, facilityLocationInspactionSettingRoute)
                  },
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.deepPurple),
                )
              ],
            ),
            //SizedBox(height: 10,),
            //Text('위치를 설정하면 스캔된 설비의 위치가 자동으로 변경됩니다.', style: TextStyle(color: Colors.grey[400])),
            if ($facilityLocationRepository.facilityChangeList.length > 0)
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextButton(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.check),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Text(getTranslated(context, 'apply'))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  onPressed: () => {
                    $facilityLocationRepository.updateChangeListAll(
                        '',
                        $facilityLocationRepository
                            .settingInspactionLocation.plantCode,
                        $facilityLocationRepository
                            .settingInspactionLocation.itemGroupCode,
                        $facilityLocationRepository
                            .settingInspactionLocation.setupLocationCode,
                        '',
                        $userRepository.user.empNo)
                  },
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.red),
                ),
              ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  //페이지 소개
  Widget introPage() {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Icon(
              Icons.search,
              size: 200,
              color: Colors.grey[200],
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                getTranslated(context, 'facility_location_change_desc'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                getTranslated(context, 'facility_location_change_desc2'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actionBluetoothStream() async {
    try {
      isBluetoothConnected = await Btprotocol.instance.isConnected;

      if (!_isStreamAction) {
        //Address 체크
        // if($userRepository.bluetoothDevice == null || $userRepository.bluetoothDevice.address == null || $userRepository.bluetoothDevice.address == '')
        // {
        //   customAlertOK(context,getTranslated(context, 'device_not_found'), getTranslated(context, 'device_not_found_desc'))
        //     .show()
        //     .then((value) => Navigator.pushNamed(context, bluetoothScanRoute));
        //   return;
        // }

        int isConnected = -1;

        if (!isBluetoothConnected) {
          //블루투스 연결
          await Btprotocol.instance
              .connectDevice($userRepository.bluetoothDevice.address);

          //연결 성공 확인용 (-8이 나와야 정상)
          isConnected = await Btprotocol.instance
              .connectDevice($userRepository.bluetoothDevice.address);
        } else {
          isConnected = 0;
        }

        debugPrint(isConnected.toString());
        if (isConnected != -40 && isConnected != 0) {
          _isStreamAction = true;

          showSnackBar('Bluetooth', 'Connect successfully.');
          isBluetoothConnected = true;

          //메모리 초기화
          Btprotocol.instance.clearData();

          //정상 연결
          if (bluetoothSubscription == null || bluetoothSubscription.isPaused) {
            debugPrint("bluetoothSubscription == null");
            //bluetoothSubscription = bluetoothStream.listen((event) { dataRead();});

          } else {
            debugPrint("bluetoothSubscription not null");
          }
        } else {
          //연결 실패
          showSnackBar('Bluetooth', 'Connection failure.');
        }
      } else {
        await Btprotocol.instance.disconnectDevice();
        bluetoothSubscription.pause();
        showSnackBar('Bluetooth', 'Disconnect.');
        debugPrint(bluetoothSubscription.toString());
        _isStreamAction = false;
      }
    } catch (ex) {
      debugPrint("Error : _actionBluetoothStream()");
    }

    setState(() {});
  }

  //Read Ble Data
  Future<bool> dataRead() async {
    List<SharkDataInfo> tagList = await Btprotocol.instance.getListTag;

    debugPrint("tagList length : ${tagList.length.toString()}");
    debugPrint("tempTagList length : ${tempTagList.length.toString()}");

    tagList.forEach((element) {
      if (tagList.length > 0) {
        SharkDataInfo data = element;
        String strScanData = data.tagData;

        // //마지막 태그 중복 호출 방지
        // if(tagLastValue==data.tagData){
        //   return true;
        // }

        //태그 중복 호출 방지
        if (!tempTagList.any((e) => e == data.tagData)) {
          tempTagList.add(data.tagData);

          String searchDiv = '';

          if (data.type.toUpperCase() == "R") {
            searchDiv = 'rfid';
          } else if (data.type.toUpperCase() == "B") {
            searchDiv = 'Asset';
          }

          $facilityLocationRepository
              .getFacilityList(searchDiv, strScanData, "")
              .then((value) {
            if (value != null) {
              $facilityLocationRepository.addChangeList(value);
            }
          });
        }
      }
    });

    return true;
  }

  void showSnackBar(String label, dynamic value) {
    try {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text(label + ' = ' + value.toString()),
      ));
    } catch (ex) {
      debugPrint("Error : showSnackBar()");
    }
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      //animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 22.0),
      child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.camera, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => qrBarcodeScan(false),
          label: 'QR',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.repeat, color: Colors.white),
          backgroundColor: Colors.blue[300],
          onTap: () => qrBarcodeScan(true),
          label: 'QR(Repeat)',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.blue[300],
        ),
        SpeedDialChild(
          child: Icon(Icons.clear_all, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: clearAll,
          label: 'Clear All',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.red,
        ),
        // SpeedDialChild(
        //   child: Icon(Icons.bluetooth_searching, color: Colors.white),
        //   backgroundColor: Colors.blue,
        //   onTap: () => {
        //     if($userRepository.bluetoothDevice == null || $userRepository.bluetoothDevice.address == null || $userRepository.bluetoothDevice.address == ""){
        //       customAlertOK(context,getTranslated(context, 'device_not_found'), getTranslated(context, 'device_not_found_desc'))
        //         .show()
        //         .then((value) => Navigator.pushNamed(context, bluetoothScanRoute))

        //     }else{
        //       Navigator.pushNamed(context, facilityTradeBluetoothReaderRoute, arguments: FacilityTradeBluetoothReaderArguments(address:$userRepository.bluetoothDevice.address,pageType: widget.pageType))
        //     }
        //   } ,
        //   labelWidget: Container(
        //     color: Colors.blue,
        //     margin: EdgeInsets.only(right: 10),
        //     padding: EdgeInsets.all(6),
        //     child: Text('RFID'),
        //   ),
        // ),
      ],
    );
  }

  void clearAll() {
    $facilityLocationRepository.clearChahgeList(true);

    Btprotocol.instance.clearData();
    tempTagList = [];
  }

  Future qrBarcodeScan(bool repeat) async {
    try {
      var options = ScanOptions(
          // strings: {
          //   "cancel": _cancelController.text,
          //   "flash_on": _flashOnController.text,
          //   "flash_off": _flashOffController.text,
          // },
          // restrictFormat: selectedFormats,
          // useCamera: _selectedCamera,
          // autoEnableFlash: _autoEnableFlash,
          // android: AndroidOptions(
          //   aspectTolerance: _aspectTolerance,
          //   useAutoFocus: _useAutoFocus,
          // ),
          );

      var result = await BarcodeScanner.scan(options: options);

      scanResult = result;
      if (scanResult.type != ResultType.Cancelled) {
        //textAssetNoController.text = scanResult.rawContent ?? "";
        //validateSubmit();
        print("QR Barcode Scan Result : " + scanResult.rawContent ?? "");
        String strScanData = scanResult.rawContent ?? "";

        await pr.show();

        //WebAPI Call & Add
        FacilityInfo data = await $facilityLocationRepository
            .getFacilityList("Asset", strScanData, "")
            .then((value) {
          pr.hide();
          return value;
        });
        if (data != null) {
          await $facilityLocationRepository.addChangeList(data);
          showSnackBar("QR Barcode[" + strScanData + "]",
              getTranslated(context, 'additional_completion'));
          if (repeat) {
            qrBarcodeScan(repeat);
          }
        } else {
          showSnackBar("QR Barcode[" + strScanData + "]",
              getTranslated(context, 'empty_value'));
        }

        pr.hide();
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  //조회 설비 리스트 뷰
  Widget getListView() {
    //Color colorDefaultTextColor = Colors.black;
    //Color colorSearchDisplayTextColro = Colors.red;
    return ListView.builder(
        itemCount: $facilityLocationRepository.facilityChangeList.length,
        itemBuilder: (context, index) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              elevation: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle),
                        color: Colors.red,
                        onPressed: () {
                          $facilityLocationRepository.removeChangeList(
                              $facilityLocationRepository
                                  .facilityChangeList[index]);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Text(
                                  '[${$facilityLocationRepository.facilityChangeList[index].facilityCode}][${$facilityLocationRepository.facilityChangeList[index].assetCode}]'),
                              Flexible(
                                  child: Text(
                                '${$facilityLocationRepository.facilityChangeList[index].facilityName}',
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                  '${getTranslated(context, 'plant')} : [${$facilityLocationRepository.facilityChangeList[index].plantCode}]${$facilityLocationRepository.facilityChangeList[index].plantName}')
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                    '${getTranslated(context, 'location')} : [${$facilityLocationRepository.facilityChangeList[index].setupLocationCode}]${$facilityLocationRepository.facilityChangeList[index].setupLocation}'),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                    '${getTranslated(context, 'item_group')} : ${$facilityLocationRepository.facilityChangeList[index].itemGroup}'),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: resultIcon(index),
                    ),
                  ],
                ),
              ));
        });
  }

  Widget resultIcon(int index) {
    if ($facilityLocationRepository.facilityChangeList[index].sendResult ==
        -1) {
      return IconButton(
        icon: Icon(Icons.refresh),
        color: Colors.red,
        onPressed: () {
          $facilityLocationRepository.updateChangeFacilityInfoInLocation(
              index,
              '',
              $facilityLocationRepository.settingInspactionLocation.plantCode,
              $facilityLocationRepository
                  .settingInspactionLocation.itemGroupCode,
              $facilityLocationRepository
                  .settingInspactionLocation.setupLocationCode,
              '',
              $userRepository.user.empNo);
        },
      );
    } else if ($facilityLocationRepository
            .facilityChangeList[index].sendResult ==
        1) {
      return IconButton(
        icon: Icon(Icons.check),
        color: Colors.green,
        onPressed: () {},
      );
    } else {
      return Container();
    }
  }
}
