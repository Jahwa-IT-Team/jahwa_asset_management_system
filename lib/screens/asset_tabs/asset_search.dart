import 'dart:async';
//import 'dart:io' show Platform;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/provider/asst_repository.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AssetSearchPage extends StatefulWidget{

  @override
  _AssetSearchPageState createState() => _AssetSearchPageState();

}

class _AssetSearchPageState extends State<AssetSearchPage>{
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  ScanResult scanResult;
  asstRepository $asstRepository = asstRepository();
  TextEditingController textAssetNoController = TextEditingController();
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
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


  String validateAssetNo(String value) { 
    if(value.isEmpty){
      return getTranslated(context, 'input_asset_no_hint');
    }
    return null;
  }
  void validateSubmit() async {
    await pr.show();
    $asstRepository.searchData(textAssetNoController.text);
    pr.hide();
    Navigator.pushNamed(context, assetInfoViewRoute, arguments: textAssetNoController.text);
  }
  @override
  Widget build(BuildContext context){
    $asstRepository = Provider.of<asstRepository>(context, listen: true);
    return Container(
      child: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key:_key,
              child: Column(
                children: <Widget>[
                  inputAssetNo(),
                  submitSearch(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                            child: Divider(
                              color: Colors.grey,
                              height: 36,
                            )),
                      ),
                      Text("OR"),
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                            child: Divider(
                              color: Colors.grey,
                              height: 36,
                            )),
                      ),
                    ],
                  ),
                  scanQRCode(),
                ],
              )
            ),
            Row(

            ),
          ],
        ),
      ),
    );
  } 

  Widget inputAssetNo(){
    return  Padding(
      padding: const EdgeInsets.only(top: 0, left: 50, right: 50),
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          
          style: TextStyle(
            color: Colors.blueGrey,
          ),
          //keyboardType: TextInputType.emailAddress,
          controller: textAssetNoController,
          validator: validateAssetNo,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.blueGrey,
            labelText: getTranslated(context, 'input_asset_no'),
            hintText: getTranslated(context, 'input_asset_no_hint'),
            labelStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget submitSearch(){
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 50, left: 50),
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
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FlatButton(
          onPressed: () {
            if(_key.currentState.validate()){

              validateSubmit();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                getTranslated(context, 'submit_search_asset_no'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget scanQRCode(){
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 50, left: 50),
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
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(10),
        ),
        child: FlatButton(
          onPressed: () {
            scan();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                getTranslated(context, 'barcode_scan'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
    );
  }

  Future scan() async {
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

      

      setState(() {
        scanResult = result;
        if(scanResult.type != ResultType.Cancelled){
          textAssetNoController.text = scanResult.rawContent ?? "";
          validateSubmit();
        }
        
      } );
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

}