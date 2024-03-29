import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/widgets/facility_trade_request_user_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/foundation.dart' as Foundation;
//import 'package:jahwa_asset_management_system/routes.dart';

class AssetInspectionQRScanPage extends StatefulWidget {
  final String masterId;

  AssetInspectionQRScanPage({Key key, @required this.masterId})
      : super(key: key);

  @override
  _AssetInspectionQRScanPageState createState() =>
      _AssetInspectionQRScanPageState();
}

class _AssetInspectionQRScanPageState extends State<AssetInspectionQRScanPage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  //final _key = new GlobalKey<ScaffoldState>();
  double position = 0.0;
  ScanResult scanResult;
  String assetNo;
  List<dynamic> globalData; //자산 Json Data
  ScrollController _scrollController;
  ProgressDialog pr;
  double percentage = 0.0;
  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    if (Foundation.kDebugMode) {
      assetNo = 'hab0775k';
      debugPrint('재물조사 디버그 모드, 자산번호($assetNo)');
    } else {
      scan();
    }

    _scrollController = ScrollController(
        initialScrollOffset: position ?? 0.0, keepScrollOffset: true);
  }

  @override
  void didChangeDependencies() {
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    $facilityTradeCommonRepository =
        Provider.of<FacilityTradeCommonRepository>(context, listen: true);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // it is a good practice to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if($userRepository == null){
    //   $userRepository = Provider.of<UserRepository>(context, listen: false);
    // }
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );

    pr.style(
      message: getTranslated(context, 'saving_data'),
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
      appBar: new AppBar(
        title: new Text(assetNo),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: Column(children: <Widget>[
          new Expanded(
            child: getListView(),
          ),
          new Row(
            children: <Widget>[
              saveAndExit(),
              saveAndScanQRCode(),
            ],
          ),
        ]),
      ), //getListView(),
    );
  }

  Future scan() async {
    assetNo = "";
    globalData = null;

    try {
      var options = ScanOptions();
      var result = await BarcodeScanner.scan(options: options);

      getListView(); //http 데이터 호출

      setState(() {
        scanResult = result;
        if (scanResult.type != ResultType.Cancelled) {
          assetNo = scanResult.rawContent ?? "";
        } else {
          assetNo = "";
          Navigator.pop(context);
        }
      });
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

  Future getData() async {
    if (assetNo == "") {
      globalData = null;
      return null;
    }
    String masterId = widget.masterId;
    if (globalData == null) {
      //String url = 'https://japi.jahwa.co.kr/api/Assets/'+assetNo;
      String url =
          'https://japi.jahwa.co.kr/api/InspectionDetail/GetNoInspectionAllList/$masterId/$assetNo';
      http.Response response = await http
          .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

      if (response.statusCode != 200 ||
          response.body == null ||
          response.body == '[]') {
        return null;
      }

      if (response.statusCode == 200) {
        globalData = jsonDecode(response.body);
      } else {
        return null;
      }
    }

    return globalData;
  }

  Future<http.Response> setData() async {
    globalData[0]['id'] = 0;
    globalData[0]['insertUserId'] = $userRepository.user.empNo;
    globalData[0]['insertUserName'] = $userRepository.user.name;

    String url = 'https://japi.jahwa.co.kr/api/InspectionDetail';
    http.Response response = await http.post(Uri.encodeFull(url),
        body: jsonEncode(globalData[0]),
        headers: {"Content-Type": "application/json"});
    //print("http Status code : "+response.statusCode.toString());
    return response;
  }

  //Scan 자산의 데이터 출력
  Widget getListView() {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == false) {
          return Center(
              child: Text(getTranslated(
                  context, 'asset_info_empty_value')) //'자산 정보가 존재하지 않습니다.'
              );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData == true &&
            assetNo != "") {
          if (snapshot.data.length != null && snapshot.data.length > 0) {
            //페이지 다시 로드 시 스크롤 이전 위치로 이동
            _scrollController = ScrollController(
                initialScrollOffset: position ?? 0.0, keepScrollOffset: true);

            return SingleChildScrollView(
              key: _key,
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              //shrinkWrap: true,
              child: Column(
                children: <Widget>[
                  getTileData(snapshot, 'company', true),
                  //getTileData(snapshot, 'company_nm', true),
                  getTileData(snapshot, 'asst_no', true),
                  getTileData(snapshot, 'asst_nm', true),
                  getTileData(snapshot, 'dept_cd', true),
                  getTileData(snapshot, 'dept_nm', true),
                  getTileData(snapshot, 'spec', false),
                  getTileData(snapshot, 'maker', false),
                  getTileAssetStateDropdownButton(
                      snapshot, 'asset_state', false),
                  getTileData(snapshot, 'setarea', false),
                  getTileData(snapshot, 'serial_no', false),
                  getTileDataOnTap(
                      snapshot, 'user_cd', true, _showPersonDialog),
                  getTileDataOnTap(
                      snapshot, 'user_nm', true, _showPersonDialog),
                ],
              ),
            );
          } else {
            return Center(
                child: Text(getTranslated(
                    context, 'asset_info_empty_value')) //'자산 정보가 존재하지 않습니다.'
                );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
              child: Text(getTranslated(
                  context, 'asset_info_empty_value')) //'자산 정보가 존재하지 않습니다.'
              );
        }
      },
    );
  }

  //자산 데이터 텍스트 형태
  ListTile getTileData(
      AsyncSnapshot<dynamic> snapshot, String key, bool readOnly) {
    return ListTile(
      title: Text(
        getTranslated(context, 'asset_info_label_' + key),
        style: TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      subtitle: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        //child: Text(jsonValue,style: TextStyle())
        child: TextFormField(
          readOnly: readOnly,
          onChanged: (text) {
            globalData[0][key] = text;
          },
          initialValue: snapshot.data[0][key] == null
              ? ''
              : snapshot.data[0][key].toString(),
          style: readOnly
              ? TextStyle(color: Colors.grey)
              : TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  ListTile getTileAssetStateDropdownButton(
      AsyncSnapshot<dynamic> snapshot, String key, bool readOnly) {
    final items = {
      'AA': getTranslated(context, 'asset_info_state_label_aa'),
      'AB': getTranslated(context, 'asset_info_state_label_ab'),
      'BA': getTranslated(context, 'asset_info_state_label_ba'),
      'BB': getTranslated(context, 'asset_info_state_label_bb')
    };

    return ListTile(
      title: Text(
        getTranslated(context, 'asset_info_label_' + key),
        style: TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      subtitle: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        //child: Text(jsonValue,style: TextStyle())
        child: DropdownButton(
          focusColor: Colors.blue,
          value: globalData[0][key].toString(),
          iconEnabledColor: Colors.blue,
          isExpanded: true,
          isDense: true,
          items: items.entries
              .map<DropdownMenuItem<String>>(
                  (MapEntry<String, String> e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ))
              .toList(),
          onChanged: (String newKey) {
            /* todo handle change */
            setState(() {
              position = _scrollController.position.pixels;
              globalData[0][key] = newKey;
              //print(newKey);
            });
          },
        ),
      ),
    );
  }

  //자산 데이터 텍스트 형태
  ListTile getTileDataOnTap(AsyncSnapshot<dynamic> snapshot, String key,
      bool readOnly, Function onDataTap) {
    return ListTile(
      title: Text(
        getTranslated(context, 'asset_info_label_' + key),
        style: TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      subtitle: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        //child: Text(jsonValue,style: TextStyle())
        child: TextFormField(
          readOnly: readOnly,
          onTap: onDataTap,
          onChanged: (text) {
            globalData[0][key] = text;
          },
          initialValue: snapshot.data[0][key] == null
              ? ''
              : snapshot.data[0][key].toString(),
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  //재물조사 저장 후 닫기
  Widget saveAndExit() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 0, left: 0),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 70,
        width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .width /
            2), //(MediaQuery.of(context).size.width/2),
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: TextButton(
            onPressed: () {
              //scan();
              saveData(false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  getTranslated(context, 'save'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.save,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  saveData(bool isContinue) async {
    await pr.show();
    pr.update(message: getTranslated(context, 'saving_data'));
    setData().then((onValue) {
      if (pr.isShowing()) {
        pr.hide().then((isHidden) {
          print(isHidden);
        });
      }
      if (onValue.statusCode == 200) {
        _onAlertButtonSuccessPressed(context, isContinue);
      } else {
        _onAlertButtonPressed(context);
      }
    });
  }

  _onAlertButtonPressed(context) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Error",
      desc: "Save Error.",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  _onAlertButtonSuccessPressed(context, bool isContinue) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Success",
      //desc: "Save Error.",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => {
            Navigator.pop(context),
            if (isContinue) {scan()} else {Navigator.pop(context)}
          },
          width: 120,
        )
      ],
    ).show();
  }

  Widget saveAndScanQRCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 0, left: 0, bottom: 0),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 70,
        width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .width /
            2), //(MediaQuery.of(context).size.width/2),
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
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: TextButton(
            onPressed: () {
              saveData(true);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  getTranslated(context, 'save_next'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //사용자 변경

  void _showPersonDialog() async {
    selectedItems = [];
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return (menuWidget);
        });

    if (selectedItems.length > 0) {
      //await $facilityTradeRequestRepository.changeSelectManager(selectedItems[0]);
      globalData[0]['user_cd'] = $facilityTradeCommonRepository
          .searchManagerList[selectedItems[0]].empCode;
      globalData[0]['user_nm'] = $facilityTradeCommonRepository
          .searchManagerList[selectedItems[0]].name;
      setState(() {
        //_reqPersonNameController.text = $facilityTradeRequestRepository.requestHeader.name;
      });
    }
  }

  BoxConstraints menuConstraints;
  List<int> selectedItems = [];
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);
  Function displayItem;

  Widget get menuWidget {
    return (UserDropdownDialog(
      //items: $facilityTradeRequestRepository.searchManagerDropdownMenuItem,
      hint: prepareWidget(getTranslated(context, 'asset_info_label_user_nm')),
      closeButton: 'Close',
      keyboardType: TextInputType.text,
      multipleSelection: false,
      selectedItems: selectedItems,
      doneButton: null,
      displayItem: displayItem,
      validator: null,
      dialogBox: true,
      displayMenu: displayMenu,
      menuConstraints: menuConstraints,
      menuBackgroundColor: Colors.white,
      callOnPop: () {},
    ));
  }
}
