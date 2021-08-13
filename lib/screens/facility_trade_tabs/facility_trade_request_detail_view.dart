import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_receive_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_request_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_send_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/facility_trade_bluetooth_reader.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../../routes.dart';

class FacilityTradeRequestDetailViewPage extends StatefulWidget {
  final PageType pageType;
  FacilityTradeRequestDetailViewPage({Key key, @required this.pageType})
      : super(key: key);

  @override
  _FacilityTradeRequestDetailViewPageState createState() =>
      _FacilityTradeRequestDetailViewPageState();
}

class _FacilityTradeRequestDetailViewPageState
    extends State<FacilityTradeRequestDetailViewPage> {
  ScanResult scanResult;
  String pageTitle = "";
  ScrollController scrollController = ScrollController();
  bool dialVisible = true;
  bool _showMaterialonIOS = true;
  bool isSearch = false;
  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  FacilityTradeRequestRepository $facilityTradeRequestRepository;
  FacilityTradeSendRepository $facilityTradeSendRepository;
  FacilityTradeReceiveRepository $facilityTradeReceiveRepository;
  ProgressDialog pr;

  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();

  get http => null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ($userRepository == null) {
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if ($facilityTradeCommonRepository == null) {
      $facilityTradeCommonRepository =
          Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    if ($facilityTradeRequestRepository == null) {
      $facilityTradeRequestRepository =
          Provider.of<FacilityTradeRequestRepository>(context, listen: true);
    }

    if ($facilityTradeSendRepository == null) {
      $facilityTradeSendRepository =
          Provider.of<FacilityTradeSendRepository>(context, listen: true);
    }

    if ($facilityTradeReceiveRepository == null) {
      $facilityTradeReceiveRepository =
          Provider.of<FacilityTradeReceiveRepository>(context, listen: true);
    }

    switch (widget.pageType) {
      case PageType.Request:
        pageTitle = getTranslated(context, 'facility_trade_list') +
            " - " +
            getTranslated(context, 'facility_trade_request');
        break;
      case PageType.Send:
        pageTitle = getTranslated(context, 'facility_trade_list') +
            " - " +
            getTranslated(context, 'facility_trade_send');
        break;
      case PageType.Receive:
        pageTitle = getTranslated(context, 'facility_trade_list') +
            " - " +
            getTranslated(context, 'facility_trade_receive');
        break;
      default:
        pageTitle = getTranslated(context, 'facility_trade_list');
        break;
    }

    return buildRequestPage();
  }

  Widget buildRequestPage() {
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
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isSearch)
              Padding(
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(0.0)))),
                  cursorColor: Colors.green,
                ),
              ),
            //getRequestListView(),
            if (widget.pageType == PageType.Request)
              Expanded(
                child: getRequestListView(),
              ),
            if (widget.pageType == PageType.Send)
              Expanded(
                child: getSendListView(),
              ),
            if (widget.pageType == PageType.Receive)
              Expanded(
                child: getReceiveListView(),
              ),
            SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
      // floatingActionButton:FloatingActionButton.extended(
      //   onPressed: () {

      //     if($userRepository.bluetoothDevice == null || $userRepository.bluetoothDevice.address == null || $userRepository.bluetoothDevice.address == ""){
      //       customAlertOK(context,getTranslated(context, 'device_not_found'), getTranslated(context, 'device_not_found_desc'))
      //         .show()
      //         .then((value) => Navigator.pushNamed(context, bluetoothScanRoute));

      //     }else{
      //       Navigator.pushNamed(context, facilityTradeBluetoothReaderRoute, arguments: FacilityTradeBluetoothReaderArguments(address:$userRepository.bluetoothDevice.address,pageType: widget.pageType));
      //     }
      //   },
      //   label: Text('Add(RFID)'),
      //   icon: Icon(Icons.add),
      //   backgroundColor: Colors.indigo,
      // ),
    );
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
        // SpeedDialChild(
        //   child: Icon(Icons.exposure_neg_1, color: Colors.white),
        //   backgroundColor: Colors.deepOrange,
        //   onTap: () => setMinusPower(),
        //   label: '-1',
        //   labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //   labelBackgroundColor: Colors.deepOrangeAccent,
        // ),
        SpeedDialChild(
          child: Icon(Icons.camera, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => qrBarcodeScan(),
          label: 'QR',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.bluetooth_searching, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => {
            if ($userRepository.bluetoothDevice == null ||
                $userRepository.bluetoothDevice.address == null ||
                $userRepository.bluetoothDevice.address == "")
              {
                customAlertOK(
                        context,
                        getTranslated(context, 'device_not_found'),
                        getTranslated(context, 'device_not_found_desc'))
                    .show()
                    .then((value) =>
                        Navigator.pushNamed(context, bluetoothScanRoute))
              }
            else
              {
                Navigator.pushNamed(context, facilityTradeBluetoothReaderRoute,
                    arguments: FacilityTradeBluetoothReaderArguments(
                        address: $userRepository.bluetoothDevice.address,
                        pageType: widget.pageType))
              }
          },
          labelWidget: Container(
            color: Colors.blue,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(6),
            child: Text('RFID'),
          ),
        ),
      ],
    );
  }

  Future qrBarcodeScan() async {
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

        int rtnValue;
        switch (widget.pageType) {
          case PageType.Request:
            rtnValue = await $facilityTradeRequestRepository
                .addRequestScanAssetCodeDetailList(
                    RequestDetail(assetCode: strScanData))
                .then((value) {
              pr.hide();
              return value;
            });
            break;
          case PageType.Send:
            rtnValue = await $facilityTradeSendRepository
                .addSendScanAssetCodeDetailList(
                    SendDetail(assetCode: strScanData))
                .then((value) {
              pr.hide();
              return value;
            });
            break;
          case PageType.Receive:
            rtnValue = await $facilityTradeReceiveRepository
                .addReceiveScanAssetCodeDetailList(
                    ReceiveDetail(assetCode: strScanData))
                .then((value) {
              pr.hide();
              return value;
            });
            break;
          default:
            break;
        }

        //결과 메세지 표시
        switch (rtnValue) {
          case -1:
            //설비 대상 아님
            showSnackBar(
                "QR Barcode[" + strScanData + "]",
                getTranslated(
                    context, 'facility_trade_list_not_found_or_fail'));
            break;
          case 0:
            //이미 추가된 설비
            showSnackBar("QR Barcode[" + strScanData + "]",
                getTranslated(context, 'facility_trade_list_already'));
            break;
          case 1:
            //추가 완료
            showSnackBar("QR Barcode[" + strScanData + "]",
                getTranslated(context, 'facility_trade_list_ok'));
            break;
          default:
            break;
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

  Widget getRequestListView() {
    return ListView.builder(
        //shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
        itemCount: $facilityTradeRequestRepository.requestDetailList.length,
        itemBuilder: (context, index) {
          return Card(
              elevation: 5.0,
              margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      ),
                  child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
                                    "[${$facilityTradeRequestRepository.requestDetailList[index].facilityCode}]",
                                showMaterialonIOS: _showMaterialonIOS,
                                labelAlign: TextAlign.center,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            customCardField(
                                label: getTranslated(context, 'facility_name'),
                                content: Text($facilityTradeRequestRepository
                                    .requestDetailList[index].facilityName)),
                            customCardField(
                                label: getTranslated(
                                    context, 'asset_info_label_spec'),
                                content: Text($facilityTradeRequestRepository
                                    .requestDetailList[index].facilitySpec)),
                            customCardField(
                                label: getTranslated(
                                    context, 'asset_info_label_asst_no'),
                                content: Text($facilityTradeRequestRepository
                                    .requestDetailList[index].assetCode)),
                            customCardField(
                              label: getTranslated(context, 'facility_grade'),
                              content: customDropdown(
                                  data:
                                      $facilityTradeCommonRepository.gradeData,
                                  value: $facilityTradeRequestRepository
                                      .requestDetailList[index].facilityGrade,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .gradeData),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeRequestRepository
                                                  .requestDetailList[index]
                                                  .facilityGrade =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            customCardField(
                              label: getTranslated(context, 'plant'),
                              content: customDropdown(
                                  data:
                                      $facilityTradeCommonRepository.plantData,
                                  value: $facilityTradeRequestRepository
                                      .requestDetailList[index].plantCode,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .plantData),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeRequestRepository
                                                  .requestDetailList[index]
                                                  .plantCode =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            customCardField(
                              label: getTranslated(context, 'item_group'),
                              content: customDropdown(
                                  data: $facilityTradeCommonRepository
                                      .itemGroupData,
                                  value: $facilityTradeRequestRepository
                                      .requestDetailList[index].itemGroup,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .itemGroupData
                                                .toList()
                                                .where((e) => (e.value
                                                    .toString()
                                                    .toLowerCase()
                                                    .substring(0, 3)
                                                    .contains(
                                                        $facilityTradeRequestRepository
                                                            .requestDetailList[
                                                                index]
                                                            .plantCode
                                                            .toLowerCase())))
                                                .toList()),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeRequestRepository
                                                  .requestDetailList[index]
                                                  .itemGroup =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Expanded(child: new Text('')),
                                  new Expanded(
                                      child: Container(
                                          alignment: Alignment.bottomRight,
                                          height: 40,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              $facilityTradeRequestRepository
                                                  .removeRequestDetailOne(
                                                      $facilityTradeRequestRepository
                                                              .requestDetailList[
                                                          index]);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  getTranslated(
                                                      context, 'remove'),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.restore_from_trash,
                                                  color: Colors.white70,
                                                ),
                                              ],
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ]))));
        });
  }

  Widget getSendListView() {
    return ListView.builder(
        itemCount: $facilityTradeSendRepository.sendDetailList.length,
        itemBuilder: (context, index) {
          return Card(
              elevation: 5.0,
              margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      ),
                  child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
                                    "[${$facilityTradeSendRepository.sendDetailList[index].facilityCode}]",
                                showMaterialonIOS: _showMaterialonIOS,
                                labelAlign: TextAlign.center,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context, 'facility_name'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].facilityName,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'facility_trade_request_number'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].reqNo,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'asset_info_label_spec'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].facilitySpec,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'asset_info_label_asst_no'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].assetCode,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context,
                                  'facility_trade_request_company_type'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].entName,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context,
                                  'facility_trade_request_person_name'),
                              content: Text(
                                $facilityTradeSendRepository
                                    .sendDetailList[index].managerName,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Expanded(child: new Text('')),
                                  new Expanded(
                                      child: Container(
                                          alignment: Alignment.bottomRight,
                                          height: 40,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              $facilityTradeSendRepository
                                                  .removeSendDetailOne(
                                                      $facilityTradeSendRepository
                                                              .sendDetailList[
                                                          index]);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  getTranslated(
                                                      context, 'remove'),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.restore_from_trash,
                                                  color: Colors.white70,
                                                ),
                                              ],
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ]))));
        });
  }

  Widget getReceiveListView() {
    return ListView.builder(
        itemCount: $facilityTradeReceiveRepository.receiveDetailList.length,
        itemBuilder: (context, index) {
          return Card(
              elevation: 5.0,
              margin: new EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      ),
                  child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
                                    "[${$facilityTradeReceiveRepository.receiveDetailList[index].facilityCode}]",
                                showMaterialonIOS: _showMaterialonIOS,
                                labelAlign: TextAlign.center,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context, 'facility_name'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].facilityName,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'facility_trade_send_invoice_no'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].invNo,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'asset_info_label_spec'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].facilitySpec,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'asset_info_label_asst_no'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].assetCode,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context,
                                  'facility_trade_request_company_type'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].entName,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context,
                                  'facility_trade_request_person_name'),
                              content: Text(
                                $facilityTradeReceiveRepository
                                    .receiveDetailList[index].managerName,
                              ),
                            ),
                            customCardField(
                              label: getTranslated(context, 'facility_grade'),
                              content: customDropdown(
                                  data:
                                      $facilityTradeCommonRepository.gradeData,
                                  value: $facilityTradeReceiveRepository
                                      .receiveDetailList[index].facilityGrade,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .gradeData),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeReceiveRepository
                                                  .receiveDetailList[index]
                                                  .facilityGrade =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            customCardField(
                              label: getTranslated(
                                  context, 'asset_info_label_setarea'),
                              content: customDropdown(
                                  data: $facilityTradeCommonRepository
                                      .getSetupLocationData(
                                          $facilityTradeReceiveRepository
                                              .receiveDetailList[index]
                                              .entCode),
                                  value: $facilityTradeReceiveRepository
                                      .receiveDetailList[index]
                                      .setupLocationCode,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .getSetupLocationData(
                                                    $facilityTradeReceiveRepository
                                                        .receiveDetailList[
                                                            index]
                                                        .entCode)),
                                        hideHeader: true,
                                        textAlign: TextAlign.left,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeReceiveRepository
                                                  .receiveDetailList[index]
                                                  .setupLocationCode =
                                              picker.getSelectedValues()[0];
                                          $facilityTradeReceiveRepository
                                                  .receiveDetailList[index]
                                                  .setupLocation =
                                              $facilityTradeCommonRepository
                                                  .getSetupLocationName(
                                                      $facilityTradeReceiveRepository
                                                          .receiveDetailList[
                                                              index]
                                                          .entCode,
                                                      picker.getSelectedValues()[
                                                          0]);

                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            customCardField(
                              label: getTranslated(context, 'plant'),
                              content: customDropdown(
                                  data:
                                      $facilityTradeCommonRepository.plantData,
                                  value: $facilityTradeReceiveRepository
                                      .receiveDetailList[index].plantCode,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .plantData),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeReceiveRepository
                                                  .receiveDetailList[index]
                                                  .plantCode =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            customCardField(
                              label: getTranslated(context, 'item_group'),
                              content: customDropdown(
                                  data: $facilityTradeCommonRepository
                                      .itemGroupData,
                                  value: $facilityTradeReceiveRepository
                                      .receiveDetailList[index].itemGroup,
                                  onTap: () {
                                    debugPrint("Grade onTap:");
                                    Picker(
                                        adapter: PickerDataAdapter(
                                            data: $facilityTradeCommonRepository
                                                .itemGroupData
                                                .toList()
                                                .where((e) => (e.value
                                                    .toString()
                                                    .toLowerCase()
                                                    .substring(0, 3)
                                                    .contains(
                                                        $facilityTradeReceiveRepository
                                                            .receiveDetailList[
                                                                index]
                                                            .plantCode
                                                            .toLowerCase())))
                                                .toList()),
                                        hideHeader: true,
                                        title: new Text("Please Select"),
                                        onConfirm: (Picker picker, List value) {
                                          print(picker
                                              .getSelectedValues()[0]
                                              .toString());
                                          $facilityTradeReceiveRepository
                                                  .receiveDetailList[index]
                                                  .itemGroup =
                                              picker.getSelectedValues()[0];
                                          setState(() {});
                                        }).showDialog(context);
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Expanded(child: new Text('')),
                                  new Expanded(
                                      child: Container(
                                          alignment: Alignment.bottomRight,
                                          height: 40,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              $facilityTradeReceiveRepository
                                                  .removeReceiveDetailOne(
                                                      $facilityTradeReceiveRepository
                                                              .receiveDetailList[
                                                          index]);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  getTranslated(
                                                      context, 'remove'),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.restore_from_trash,
                                                  color: Colors.white70,
                                                ),
                                              ],
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                          ]))));
        });
  }

  void showSnackBar(String label, dynamic value) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        content: Text(label + ' = ' + value.toString()),
      ),
    );
  }
}
