import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' as Foundation;
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

// class FacilityLocationInspactionDetailPageArguments {
//   final String masterId;

//   FacilityLocationInspactionDetailPageArguments(
//       {@required this.masterId}); //@required 필수 전달 사항
// }

class FacilityLocationInspactionDetailPage extends StatefulWidget {
  final Object pageArguments;
  FacilityLocationInspactionDetailPage({Key key, @required this.pageArguments})
      : super(key: key);

  //1. createState()
  //StatefulWidget이 빌드 되도록 createState() 호출
  //반드시 호출해야하며 아래 코드보다 더 복잡하거나 추가될 것이 없음
  //정상적으로 createState()호출되면 buildContext가 할당되면서 this.mounted 속성 true를 리턴(2. mounted == true)
  @override
  _FacilityLocationInspactionDetailPageState createState() =>
      new _FacilityLocationInspactionDetailPageState();
}

class _FacilityLocationInspactionDetailPageState
    extends State<FacilityLocationInspactionDetailPage> {
  int masterId;
  List<String> tempTagList = [];

  bool dialVisible = true;
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
    masterId = int.parse(widget.pageArguments as String);
    //부모 initState() 호출
    super.initState();

    //Future 사용이 필요한 경우
    new Future.delayed(Duration.zero, () {});

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
      appBar: AppBar(
        title: Text(getTranslated(context, 'asset_tabs_inspaction')),
        backgroundColor: Colors.deepPurple,
        // actions: [
        //   IconButton(
        //       icon: Icon(Icons.check),
        //       onPressed: () {
        //         //Navigator.pop(context, homeRoute);
        //         //Navigator.popUntil(context, ModalRoute.withName(homeRoute));
        //         Navigator.pop(context);
        //       }),
        // ],
      ),
      body: buildLayout(),
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

    if (bluetoothSubscription != null) {
      bluetoothSubscription.cancel();
    }

    if ($facilityLocationRepository != null) {
      $facilityLocationRepository.clearInspScanList(false);
    }

    super.dispose();
  }

  //8. User Defined
  Widget buildLayout() {
    return Container(
        child: Column(
      children: <Widget>[
        setLocationBox(),
        Expanded(
          flex: 8,
          child: getListView(),
        ),
        // Expanded(
        //   child: buildQRScanLayout(),
        // ),
      ],
    ));
  }

  //QR 바코드 스캔 버튼 레이아웃
  Widget buildQRScanLayout() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('test'), Text('test1')],
      ),
    );
  }

  Widget buildQRSCanButton() {
    return Container();
  }

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
                          '${getTranslated(context, 'company')} : ${$facilityLocationRepository.settingInspactionLocation.locEntCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.locEntName}'),
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
                            Icon(Icons.save),
                            Padding(
                              padding: EdgeInsets.all(2),
                            ),
                            Text(getTranslated(context, 'apply'))
                          ],
                        )
                      ],
                    ),
                    onPressed: () => {_applyAlertDialog(context)},
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepPurple))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text('설비 위치 및 재물조사 결과를 반영하려면 "적용"을 탭하세요.',
                style: TextStyle(color: Colors.grey[400])),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  //조회 설비 리스트 뷰
  Widget getListView() {
    //Color colorDefaultTextColor = Colors.black;
    //Color colorSearchDisplayTextColro = Colors.red;
    var scanList = $facilityLocationRepository.facilityInspScanList;

    return ListView.builder(
        itemCount: scanList.length,
        itemBuilder: (context, index) {
          return Visibility(
              visible: cardVisiblility(index),
              child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, facilitylocationInspactionDetailSettingRoute,
                      arguments: index.toString()),
                  child: Card(
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
                                  $facilityLocationRepository
                                      .removeInspScanList(scanList[index]);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Text('[${scanList[index].asst_no}]'),
                                      Flexible(
                                          child: Text(
                                        '${scanList[index].asst_nm}',
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                          '${getTranslated(context, 'company')} : ${scanList[index].locEntName}')
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                          '${getTranslated(context, 'plant')} : [${scanList[index].plantCode}]${scanList[index].plantName}')
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                            '${getTranslated(context, 'location')} : [${scanList[index].setarea}]${scanList[index].setareaName}'),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                            '${getTranslated(context, 'item_group')} : ${scanList[index].itemGroup}'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [resultIcon(index)],
                                    ),
                                    Row(children: [reaseYN(index)]),
                                  ],
                                )
                                //child: resultIcon(index),
                                ),
                          ],
                        ),
                      ))));
        });
  }

  //조회 설비 리스트 아이콘
  Widget resultIcon(int index) {
    var scanList = $facilityLocationRepository.facilityInspScanList;

    if (scanList[index].sendResult == -1) {
      return IconButton(
        icon: Icon(Icons.refresh),
        color: Colors.red,
        onPressed: () {
          $facilityLocationRepository.updateChangeFacilityInfoInLocation(
              index,
              $facilityLocationRepository.settingInspactionLocation.locEntCode,
              $facilityLocationRepository.settingInspactionLocation.plantCode,
              $facilityLocationRepository
                  .settingInspactionLocation.itemGroupCode,
              $facilityLocationRepository
                  .settingInspactionLocation.setupLocationCode,
              '',
              $userRepository.user.empNo);
        },
      );
    } else if (scanList[index].sendResult == 1 || scanList[index].id > 0) {
      return IconButton(
        icon: Icon(Icons.check),
        color: Colors.green,
        onPressed: () {},
      );
    } else {
      return Container();
    }
  }

  Widget reaseYN(int index) {
    var scanList = $facilityLocationRepository.facilityInspScanList;

    if (scanList[index].locEntCode == $userRepository.connectionInfo.company) {
      return Container();
    } else if (scanList[index].locEntCode !=
        $userRepository.connectionInfo.company) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.purple),
            borderRadius: const BorderRadius.all(const Radius.circular(2))),
        margin: const EdgeInsets.all(8),
        child: Text(
          getTranslated(context, 'lease'),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Container();
    }
  }

  Future<bool> dataRead() async {
    List<SharkDataInfo> tagList = await Btprotocol.instance.getListTag;

    debugPrint("tagList length : ${tagList.length.toString()}");
    debugPrint("tempTagList length : ${tempTagList.length.toString()}");

    tagList.forEach((element) {
      if (tagList.length > 0) {
        SharkDataInfo data = element;
        String strScanData = data.tagData;

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
              .getFacilityInspectionInfo(masterId, searchDiv, strScanData)
              .then((value) {
            if (value != null) {
              value.updateUserId = $userRepository.user.empNo;
              value.updateUserName = $userRepository.user.name;
              value.insertUserId = $userRepository.user.empNo;
              value.insertUserName = $userRepository.user.name;
              value.dept_cd = $userRepository.user.deptCode;
              value.dept_nm = $userRepository.user.deptName;
              $facilityLocationRepository.addInspScanList(value);
            }
          });
        }
      }
    });

    return true;
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
      ],
    );
  }

  Future qrBarcodeScan(bool repeat) async {
    if (Foundation.kDebugMode) {
      await pr.show();
      //var assetNo = "DZA5729V";
      var assetNo = "3000E2004000770A01832470199C";
      FacilityInspectionInfo data = await $facilityLocationRepository
          .getFacilityInspectionInfo(masterId, 'RFID', assetNo)
          .then((value) {
        pr.hide();
        return value;
      });
      if (data != null) {
        data.updateUserId = $userRepository.user.empNo;
        data.updateUserName = $userRepository.user.name;
        data.insertUserId = $userRepository.user.empNo;
        data.insertUserName = $userRepository.user.name;
        data.dept_cd = $userRepository.user.deptCode;
        data.dept_nm = $userRepository.user.deptName;
        await $facilityLocationRepository.addInspScanList(data);
        if (repeat) {
          qrBarcodeScan(repeat);
        }
      } else {
        pr.hide();
      }
      setState(() {});
      return;
    }
    try {
      var options = ScanOptions();

      var result = await BarcodeScanner.scan(options: options);

      scanResult = result;
      if (scanResult.type != ResultType.Cancelled) {
        //textAssetNoController.text = scanResult.rawContent ?? "";
        //validateSubmit();
        print("QR Barcode Scan Result : " + scanResult.rawContent ?? "");
        String strScanData = scanResult.rawContent ?? "";

        await pr.show();

        //WebAPI Call & Add
        FacilityInspectionInfo data = await $facilityLocationRepository
            .getFacilityInspectionInfo(masterId, 'qr', scanResult.rawContent)
            .then((value) {
          pr.hide();
          return value;
        });
        if (data != null) {
          data.updateUserId = $userRepository.user.empNo;
          data.updateUserName = $userRepository.user.name;
          data.insertUserId = $userRepository.user.empNo;
          data.insertUserName = $userRepository.user.name;
          data.dept_cd = $userRepository.user.deptCode;
          data.dept_nm = $userRepository.user.deptName;
          await $facilityLocationRepository.addInspScanList(data);
          if (repeat) {
            qrBarcodeScan(repeat);
          }
        } else {
          pr.hide();
          showAlertDialog(context,
              'QR Barcode [$strScanData], ${getTranslated(context, 'empty_value')}');
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

  Future saveFacilityInspAllList() async {
    await pr.show();
    $facilityLocationRepository.saveFacilityInspAllList();
    pr.hide();
    showAlertDialog(context, getTranslated(context, 'save_successfully'));
  }

  void clearAll() {
    $facilityLocationRepository.clearInspScanList(true);

    Btprotocol.instance.clearData();
    tempTagList = [];
  }

  void showAlertDialog(BuildContext context, String msg) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(''),
          contentPadding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          content: Text(
            getTranslated(context, msg),
            textAlign: TextAlign.center,
          ), //위치를 먼저 선택하세요.
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
          ],
        );
      },
    );
  }

  bool cardVisiblility(int index) {
    var scanList = $facilityLocationRepository.facilityInspScanList;
    if (scanList[index].sendResult == 1 || scanList[index].id > 0) {
      return true; // 이미 저장된 설비 Visible flag
    } else {
      return true;
    }
  }

  void _applyAlertDialog(BuildContext context) async {
    var scanList = $facilityLocationRepository.facilityInspScanList;

    int iCntAlreadySave = 0;
    int iCntTargetSave = 0;
    String sFacilityList = "";

    for (var i = 0; i < scanList.length; i++) {
      if (scanList[i].sendResult == 1 || scanList[i].id > 0) {
        iCntAlreadySave++;
        sFacilityList = sFacilityList + '[' + scanList[i].asst_no + ']\r\n';
      } else {
        iCntTargetSave++;
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(''),
          contentPadding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          content: Text(
            '  ' +
                getTranslated(context, 'alert_count_target_faciliy') +
                '[' +
                iCntTargetSave.toString() +
                ']' +
                '\r\n' +
                '  ' +
                getTranslated(context, 'alert_check_already_save_faciliy') +
                '[' +
                iCntAlreadySave.toString() +
                ']' +
                '\r\n' +
                getTranslated(
                    context, 'alert_check_already_save_faciliy_info') +
                '\r\n' +
                getTranslated(
                    context, 'alert_check_already_save_faciliy_list') +
                ': \r\n ' +
                sFacilityList,
            textAlign: TextAlign.left,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(getTranslated(context, 'apply')),
              onPressed: () {
                Navigator.pop(context);
                saveFacilityInspAllList();
              },
            ),
            TextButton(
              child: Text(getTranslated(context, 'cancel')),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
