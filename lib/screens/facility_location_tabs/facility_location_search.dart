import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class FacilityLocationSearchPage extends StatefulWidget {
  @override
  _FacilityLocationSearchPageState createState() =>
      _FacilityLocationSearchPageState();
}

class _FacilityLocationSearchPageState
    extends State<FacilityLocationSearchPage> {
  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();
  bool _isStreamAction = false;
  String pageTitle = "";
  bool isSearch = false;
  bool dialVisible = true;
  bool _showMaterialonIOS = true;
  //Bluetooth connection status
  bool isBluetoothConnected = false;
  String tagLastValue;
  List<String> tempTagList = [];

  ScanResult scanResult;
  ProgressDialog pr;

  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  FacilityLocationRepository $facilityLocationRepository;

  Stream<dynamic> bluetoothStream = Btprotocol.instance.onChangeState;
  StreamSubscription bluetoothSubscription;

  Stream backgroundStream;

  @override
  void initState() {
    super.initState();

    new Future.delayed(Duration.zero, () {
      _actionBluetoothStream();
    });

    bluetoothSubscription = bluetoothStream.listen((event) {
      dataRead();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    Btprotocol.instance.clearData();
    //Btprotocol.instance.disconnectDevice();

    if (bluetoothSubscription != null) {
      bluetoothSubscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ($facilityTradeCommonRepository == null) {
      $facilityTradeCommonRepository =
          Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    if ($facilityLocationRepository == null) {
      $facilityLocationRepository =
          Provider.of<FacilityLocationRepository>(context, listen: true);
      if (!$facilityLocationRepository.firstInit) {
        $facilityLocationRepository.init();
      }
    }

    if ($userRepository == null) {
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    debugPrint("isBluetoothConnected:" + isBluetoothConnected.toString());

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
            filterView(),
            if (isSearch) searchBar(),
            //searchConditionBox(),
            Padding(padding: const EdgeInsets.all(0.0), child: Column()),
            if ($facilityLocationRepository.facilitySearchList.length <= 0)
              introPage(),
            if ($facilityLocationRepository.facilitySearchList.length > 0)
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

  //필터 박스
  Widget filterView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //alignment: Alignment.centerRight,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  //alignment: Alignment.centerRight,
                  margin: new EdgeInsets.only(top: 10.0, left: 10.0),
                  child: isBluetoothConnected
                      ? Text('Bluetooth 연결 ',
                          style: TextStyle(color: Colors.black87))
                      : Text('Bluetooth 연결안됨 ',
                          style: TextStyle(color: Colors.black87)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      alignment: Alignment.centerRight,
                      icon: Icon(Icons.view_headline),
                      onPressed: () => {
                        setState(() {
                          $facilityLocationRepository.searchCondtion
                              .listViewDisplayType = ListViewDisplayType.table;
                        })
                      },
                      color: Colors.deepPurple,
                    ),
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: Icon(Icons.view_agenda),
                      onPressed: () => {
                        setState(() {
                          $facilityLocationRepository.searchCondtion
                              .listViewDisplayType = ListViewDisplayType.card;
                        })
                      },
                      color: Colors.deepPurple,
                    ),
                    FlatButton(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.search),
                              Text(getTranslated(context, 'filter'))
                            ],
                          )
                        ],
                      ),
                      onPressed: () => {
                        Navigator.pushNamed(
                            context, facilityLocationSearchFilterRoute)
                      },
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: new EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    filterDisplay(),
                    style: TextStyle(color: Colors.grey),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String filterDisplay() {
    String display = '';

    //'설비코드:xxxxxxxx 자산번호:xxxxxxxx 설치장소:xxxxxxxx 표시: 전체 aaaa'
    if ($facilityLocationRepository.searchCondtion != null) {
      if ($facilityLocationRepository.searchCondtion.facilityCode != '') {
        display = display +
            getTranslated(context, 'facility_code') +
            ' : ' +
            $facilityLocationRepository.searchCondtion.facilityCode +
            '    ';
      }

      if ($facilityLocationRepository.searchCondtion.assetCode != '') {
        display = display +
            getTranslated(context, 'input_asset_no') +
            ' : ' +
            $facilityLocationRepository.searchCondtion.assetCode +
            '    ';
      }

      if ($facilityLocationRepository.searchCondtion.setupLocationCode != '') {
        display = display +
            getTranslated(context, 'asset_info_label_setarea') +
            ' : ' +
            $facilityLocationRepository.searchCondtion.setupLocationCode +
            '    ';
      }

      if ($facilityLocationRepository.searchCondtion.display !=
          SearchResultDisplay.none) {
        if (display != '') {
          display = display + '\n';
        }

        if ($facilityLocationRepository.searchCondtion.display ==
            SearchResultDisplay.filter_only) {
          display = display +
              getTranslated(context, 'search_result_display') +
              ' : ' +
              getTranslated(context, 'filter_only') +
              '    ';
        } else if ($facilityLocationRepository.searchCondtion.display ==
                SearchResultDisplay.location &&
            $facilityLocationRepository
                .searchCondtion.hideAllDisplayInLocation) {
          display = display +
              getTranslated(context, 'search_result_display') +
              ' : ' +
              getTranslated(context, 'all_display_in_location') +
              '(' +
              getTranslated(context, 'all_display_in_location1') +
              ')';
          display = display + '\n';
          display = display +
              '위치 수량 : ${$facilityLocationRepository.facilityInfoListInLocationCurrentCount} / ${$facilityLocationRepository.facilityInfoListInLocationTotalCount}';
          try {
            double per = $facilityLocationRepository
                    .facilityInfoListInLocationDownloadCompleteCount /
                $facilityLocationRepository
                    .facilityInfoListInLocationTotalCount *
                100;
            if (per >= 100) {
              display = display + '(다운로드 완료)';
            } else {
              display = display + '(다운로드 중..${per.round()}%)';
            }
          } catch (e) {}
        } else if ($facilityLocationRepository.searchCondtion.display ==
                SearchResultDisplay.location &&
            !$facilityLocationRepository
                .searchCondtion.hideAllDisplayInLocation) {
          display = display +
              getTranslated(context, 'search_result_display') +
              ' : ' +
              getTranslated(context, 'all_display_in_location');
          display = display + '\n';
          display = display +
              '위치 수량 : ${$facilityLocationRepository.facilityInfoListInLocationCurrentCount} / ${$facilityLocationRepository.facilityInfoListInLocationTotalCount}';

          try {
            double per = $facilityLocationRepository
                    .facilityInfoListInLocationDownloadCompleteCount /
                $facilityLocationRepository
                    .facilityInfoListInLocationTotalCount *
                100;

            if (per >= 100) {
              display = display + '(다운로드 완료)';
            } else {
              display = display + '(다운로드 중..${per.round()}%)';
            }
          } catch (e) {}
        } else {
          display = display +
              getTranslated(context, 'search_result_display') +
              ' : ' +
              getTranslated(context, 'all_display') +
              '    ';
        }
      }
    }

    return display;
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
                getTranslated(context, 'facility_location_search_desc'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                getTranslated(context, 'facility_location_search_desc2'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //검색 박스
  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          //filterSearchResults(value);
        },
        //controller: editingController,
        decoration: InputDecoration(
            labelText: "Search",
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0)))),
        cursorColor: Colors.green,
      ),
    );
  }

  //조회 설비 리스트 뷰
  Widget getListView() {
    Color colorDefaultTextColor = Colors.black;
    Color colorSearchDisplayTextColor = Colors.red;

    return ListView.builder(

        //shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
        itemCount: $facilityLocationRepository.facilitySearchList.length,
        itemBuilder: (context, index) {
          bool isCompFacilityCode = true;
          bool isCompAssetCode = true;
          bool isCompSetupLocationCode = true;
          Color headerColor = Colors.deepPurple;

          String searchFacilityCode =
              $facilityLocationRepository.searchCondtion.facilityCode;
          String searchAssetCode =
              $facilityLocationRepository.searchCondtion.assetCode;
          String searchSetupLocationCode =
              $facilityLocationRepository.searchCondtion.setupLocationCode;

          //더보기 버튼
          if ($facilityLocationRepository
                  .facilitySearchList[index].facilityCode ==
              'more') {
            return Card(
                elevation: 0.0,
                color: Colors.transparent,
                margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(
                      //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 50, left: 50),
                        child: Container(
                          alignment: Alignment.bottomRight,
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.blue[300],
                              //     blurRadius: 10.0, // has the effect of softening the shadow
                              //     spreadRadius: 1.0, // has the effect of extending the shadow
                              //     offset: Offset(
                              //       5.0, // horizontal, move right 10
                              //       5.0, // vertical, move down 10
                              //     ),
                              //   ),
                              // ],
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(color: Colors.black45)),
                          child: FlatButton(
                            onPressed: () {
                              $facilityLocationRepository
                                  .getMoreFacilityListInLocation();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  getTranslated(context, 'more_view'),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Icon(
                                  Icons.add,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          }

          if (searchFacilityCode != '') {
            isCompFacilityCode = $facilityLocationRepository
                .facilitySearchList[index].facilityCode
                .toLowerCase()
                .contains(searchFacilityCode.toLowerCase());
          }

          if (searchAssetCode != '') {
            isCompAssetCode = $facilityLocationRepository
                .facilitySearchList[index].assetCode
                .toLowerCase()
                .contains(searchAssetCode.toLowerCase());
          }

          if (searchSetupLocationCode != '') {
            isCompSetupLocationCode = $facilityLocationRepository
                .facilitySearchList[index].setupLocationCode
                .toLowerCase()
                .contains(searchSetupLocationCode.toLowerCase());
          }

          if (!isCompFacilityCode ||
              !isCompAssetCode ||
              !isCompSetupLocationCode) {
            headerColor = Colors.red;
          }

          //설치장소 자산 모두 표시의 경우, 미스캔 설비는 회색으로 표시
          if ($facilityLocationRepository.searchCondtion.display ==
                  SearchResultDisplay.location &&
              !$facilityLocationRepository.facilitySearchList[index].isScan) {
            headerColor = Colors.grey;
          }

          //리스트 형태로 출력
          if ($facilityLocationRepository.searchCondtion.listViewDisplayType ==
              ListViewDisplayType.table) {
            String detailInfo = "" +
                "${getTranslated(context, 'plant')} : [${$facilityLocationRepository.facilitySearchList[index].plantCode}]${$facilityLocationRepository.facilitySearchList[index].plantName},    " +
                "${getTranslated(context, 'asset_info_label_setarea')} : ${$facilityLocationRepository.facilitySearchList[index].setupLocation}  " +
                "\n" +
                "${getTranslated(context, 'facility_grade')} : ${$facilityLocationRepository.facilitySearchList[index].facilityGrade},  " +
                "${getTranslated(context, 'asset_info_label_spec')} : ${$facilityLocationRepository.facilitySearchList[index].facilitySpec},  " +
                "\n" +
                "${getTranslated(context, 'item_group')} : ${$facilityLocationRepository.facilitySearchList[index].itemGroup}  ";

            return Card(
                elevation: 0.0,
                margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(
                      //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
                    title: Text(
                      "[${$facilityLocationRepository.facilitySearchList[index].facilityCode}][${$facilityLocationRepository.facilitySearchList[index].assetCode}] ${$facilityLocationRepository.facilitySearchList[index].facilityName}",
                      style: TextStyle(
                        color: headerColor,
                        fontSize: 12,
                        fontWeight: (FontWeight.bold),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    subtitle: Text(
                      detailInfo,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: (FontWeight.normal),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ));
          }

          //카드 형태로 출력
          if ($facilityLocationRepository.searchCondtion.listViewDisplayType ==
              ListViewDisplayType.card) {
            return Card(
                elevation: 5.0,
                margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                child: Container(
                    decoration: BoxDecoration(
                        //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                        ),
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 0.0),
                        // title: Text(
                        //   "test",
                        //   style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
                        //   textAlign: TextAlign.center,
                        // ),

                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CardSettingsSection(
                                showMaterialonIOS: _showMaterialonIOS,
                                header: CardSettingsHeader(
                                  label:
                                      "[${$facilityLocationRepository.facilitySearchList[index].facilityCode}]",
                                  showMaterialonIOS: _showMaterialonIOS,
                                  labelAlign: TextAlign.center,
                                  color: headerColor,
                                ),
                              ),
                              customCardField(
                                  label:
                                      getTranslated(context, 'facility_name'),
                                  content: Text($facilityLocationRepository
                                      .facilitySearchList[index].facilityName)),
                              customCardField(
                                  label: getTranslated(
                                      context, 'asset_info_label_spec'),
                                  content: Text($facilityLocationRepository
                                      .facilitySearchList[index].facilitySpec)),
                              customCardField(
                                  label: getTranslated(
                                      context, 'asset_info_label_asst_no'),
                                  content: Text(
                                    $facilityLocationRepository
                                        .facilitySearchList[index].assetCode,
                                    style: TextStyle(
                                        color: isCompAssetCode
                                            ? colorDefaultTextColor
                                            : colorSearchDisplayTextColor),
                                  )),
                              customCardField(
                                  label:
                                      getTranslated(context, 'facility_grade'),
                                  content: Text($facilityLocationRepository
                                      .facilitySearchList[index]
                                      .facilityGrade)),
                              customCardField(
                                  label: getTranslated(context, 'plant'),
                                  content: Text($facilityLocationRepository
                                          .facilitySearchList[index].plantCode +
                                      "[${$facilityLocationRepository.facilitySearchList[index].plantName}]")),
                              customCardField(
                                  label: getTranslated(context, 'item_group'),
                                  content: Text($facilityLocationRepository
                                      .facilitySearchList[index].itemGroup)),
                              customCardField(
                                  label: getTranslated(
                                      context, 'asset_info_label_setarea'),
                                  content: Text(
                                      $facilityLocationRepository
                                          .facilitySearchList[index]
                                          .setupLocation,
                                      style: TextStyle(
                                          color: isCompSetupLocationCode
                                              ? colorDefaultTextColor
                                              : colorSearchDisplayTextColor))),

                              // Padding(
                              //   padding: const EdgeInsets.all(10),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: <Widget>[
                              //       new Expanded(child: new Text('')),
                              //       new Expanded(
                              //         child: Container(
                              //           alignment: Alignment.bottomRight,
                              //           height: 40,
                              //           width: MediaQuery.of(context).size.width,
                              //           decoration: BoxDecoration(
                              //             color: Colors.red,
                              //             borderRadius: BorderRadius.circular(3),
                              //           ),
                              //           child: FlatButton(
                              //             onPressed: (){$facilityLocationRepository.remove($facilityLocationRepository.facilityInfoList[index]);},
                              //             child: Row(
                              //               mainAxisAlignment: MainAxisAlignment.center,
                              //               children: <Widget>[
                              //                 Text(
                              //                   getTranslated(context, 'remove'),
                              //                   style: TextStyle(
                              //                     color: Colors.white70,
                              //                     fontSize: 14,
                              //                     fontWeight: FontWeight.w700,
                              //                   ),
                              //                 ),
                              //                 Icon(
                              //                   Icons.restore_from_trash,
                              //                   color: Colors.white70,
                              //                 ),
                              //               ],
                              //             ),
                              //           )
                              //         )
                              //       ),
                              //   ],),
                              // ),
                            ]))));
          } else {
            return null;
          }
        });
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
    $facilityLocationRepository.clearSearchInfo(true);

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
          await $facilityLocationRepository.addInfoList(data);
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

  void showSnackBar(String label, dynamic value) {
    try {
      scaffold1Key.currentState.removeCurrentSnackBar();
      scaffold1Key.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text(label + ' = ' + value.toString()),
        ),
      );
    } catch (ex) {
      debugPrint("Error : showSnackBar()");
    }
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
              $facilityLocationRepository.addInfoList(value);
            }
          });

          // if(data.type.toUpperCase() == "R")
          // {
          //   //RFID
          //   //data.tagData
          //   $facilityLocationRepository.getReceiveFacilityList("rfid", strScanData, "").then((value){
          //     if(value != null){
          //       $facilityLocationRepository.add(value);
          //       //showSnackBar("QR Barcode["+strScanData+"]",getTranslated(context, 'additional_completion'));
          //     }else{
          //       //showSnackBar("QR Barcode["+strScanData+"]",getTranslated(context, 'empty_value'));
          //     }
          //     return value;
          //   });

          // }else if(data.type.toUpperCase() == "B"){
          //   //Barcode

          //   //WebAPI Call & Add
          //   FacilityInfo apiData = await $facilityLocationRepository.getReceiveFacilityList("Asset", strScanData, "").then((value){return value;});
          //   if(apiData != null){
          //     await $facilityLocationRepository.add(apiData);
          //     showSnackBar("QR Barcode["+strScanData+"]",getTranslated(context, 'additional_completion'));
          //   }else{
          //     showSnackBar("QR Barcode["+strScanData+"]",getTranslated(context, 'empty_value'));
          //   }
          // }
        }
      }
    });

    return true;
  }
}
