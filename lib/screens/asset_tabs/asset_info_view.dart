import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/provider/asst_repository.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/widgets/facility_trade_request_user_dialog.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';

class AssetInfoViewPage extends StatefulWidget {
  final String assetNo;
  AssetInfoViewPage({Key key, @required this.assetNo}) : super(key: key);

  @override
  _AssetInfoViewPageState createState() => _AssetInfoViewPageState();
}

class _AssetInfoViewPageState extends State<AssetInfoViewPage> {

  asstRepository $asstRepository = asstRepository();
  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {});
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
    //$asstRepository.searchData(widget.assetNo);
  }

  @override
  void didChangeDependencies() {
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    $asstRepository = Provider.of<asstRepository>(context, listen: true);
    $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //$asstRepository = Provider.of<asstRepository>(context, listen: true);

    return Scaffold(
        appBar: new AppBar(
          title: new Text(widget.assetNo),
          backgroundColor: Colors.green,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.save),
              onPressed: () => {
                  saveAsstInfo()
              }
            )
          ],
        ),
        body: getListView(widget.assetNo));
  }

  Widget getListView(String assetNo) {
    var asstInfo = $asstRepository.responseJson;
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey,
      ),
      itemCount: asstInfo == null ? 0 : asstInfo[0].keys.length,
      itemBuilder: (context, index) {
        String jsonKey = asstInfo[0].keys.elementAt(index);
        String jsonValue = asstInfo[0][jsonKey] == null
            ? ''
            : asstInfo[0][jsonKey].toString();
        return ListTile(
          //contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),

          title: Text(
            getTranslated(context, 'asset_info_label_' + jsonKey),
            style: saveAbleTextStyle(jsonKey)
          ),
          subtitle: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Text(
                jsonValue,
                style: saveAbleTextStyle(jsonKey)
              )
          ),
          onTap: () => {
            if(jsonKey == 'setarea'){
              createTextFieldDialog(context, jsonKey)

            }
            else if(jsonKey == 'user_cd' ||jsonKey == 'user_nm'){
              _showPersonDialog(jsonKey)
            }

          },
        );
      },
    );
  }


  Future getAsstRepository(String asstNo) async {
    //await pr.show();
    await $asstRepository.searchData(asstNo);
    //pr.hide();
  }

  TextStyle saveAbleTextStyle(jsonKey){
    if(jsonKey == 'setarea' || jsonKey == 'user_cd' || jsonKey == 'user_nm'){
      return TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 17
      );
    }
    else{
      return TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
          fontSize: 17
      );
    }
  }

  Future<String> createTextFieldDialog(BuildContext context, String jsonKey) async{
    TextEditingController customController = TextEditingController();
    return showDialog(
      context: context ,
      builder: (context){
        return AlertDialog(
          title: Text(
            getTranslated(context, 'asset_info_label_' + jsonKey),
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 17),),
          content: TextField(
            controller: customController,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Submit'),
              onPressed:(){
                $asstRepository.setAsstInfo(jsonKey, customController.text.toString());

                Navigator.of(context).pop(customController.text.toString());
              }
            ),
            MaterialButton(
                elevation: 5.0,
                child: Text('Cancel'),
                onPressed:(){
                  Navigator.of(context).pop(customController.text.toString());
                }
            )

          ]
        );
      }
    );
  }

  void _showPersonDialog(String JsonKey) async {
    var asstInfo = $asstRepository.responseJson;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return (menuWidget);
        });

    if (selectedItems.length > 0) {
      //await $facilityTradeRequestRepository.changeSelectManager(selectedItems[0]);
      $asstRepository.setAsstInfo('user_cd', $facilityTradeCommonRepository
          .searchManagerList[selectedItems[0]].empCode.toString()) ;
      $asstRepository.setAsstInfo('user_nm', $facilityTradeCommonRepository
          .searchManagerList[selectedItems[0]].name.toString()) ;
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
      callOnPop: () {
      },
    ));
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
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context ,"OK");
              },
            ),
          ],
        );
      },
    );
  }
  Future saveAsstInfo() async {
    await pr.show();
    $asstRepository.asstInfo.updt_user = $userRepository.user.empNo;
    $asstRepository.saveAsstInfo($asstRepository.asstInfo);
    pr.hide();

    showAlertDialog(context, getTranslated(context, 'save_successfully'));
  }
}
