

import 'dart:async';

import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
//import 'package:jahwa_asset_management_system/routes.dart';
//import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/card_settings_custom_text.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//card_settings 예제
//https://pub.dev/packages/card_settings#-example-tab-

class FacilityTradeRFIDRegistrationPage extends StatefulWidget{
  @override
  _FacilityTradeRFIDRegistrationPageState createState() => _FacilityTradeRFIDRegistrationPageState();

}

class _FacilityTradeRFIDRegistrationPageState extends State<FacilityTradeRFIDRegistrationPage>{
  bool _showMaterialonIOS = true;
  bool _autoValidate = false;
  bool _isStreamAction = false;
  bool _autoSaveSwitch = false;
  bool dialVisible = true;
  String tagLastValue;
  Stream<dynamic> bluetoothStream = Btprotocol.instance.onChangeState;
  StreamSubscription bluetoothSubscription;

  UserRepository $userRepository; 
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _tagKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _facilityCodeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _assetCodeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _facilityNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _autosaveKey = GlobalKey<FormState>();
  
  final _tagControll = TextEditingController();
  final _assetCodeControll = TextEditingController();
  final _facilityNameControll = TextEditingController();
  final _facilityCodeControll = TextEditingController();
  
  @override
  Widget build(BuildContext context){
    
    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if($facilityTradeCommonRepository == null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        // child: (orientation == Orientation.portrait)
        //     ? _buildPortraitLayout()
        //     : _buildLandscapeLayout(),
        child: _buildPortraitLayout(),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  } 

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
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
        if(!_isStreamAction) SpeedDialChild(
          child: Icon(Icons.bluetooth_searching, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => _actionBluetoothStream(),
          label: 'Connect',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
          labelBackgroundColor: Colors.blue,
        ),
        if(_isStreamAction) SpeedDialChild(
          child: Icon(Icons.bluetooth_disabled, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () => _actionBluetoothStream(),
          label: 'Disconnect',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
          labelBackgroundColor: Colors.red,
        ),
        SpeedDialChild(
          child: Icon(Icons.clear_all, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => clearData() ,
          labelWidget: Container(
            color: Colors.blue,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(6),
            child: Text('Clear All', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(){
    return CardSettings.sectioned(
      showMaterialonIOS: _showMaterialonIOS,
      labelWidth: 100,
      children: <CardSettingsSection>[
        CardSettingsSection(
          showMaterialonIOS: _showMaterialonIOS,
          header: CardSettingsHeader(
            label: getTranslated(context, 'facility_info'),
            showMaterialonIOS: _showMaterialonIOS,
            color: Colors.indigo,
            labelAlign: TextAlign.center,
          ),
          children: <Widget>[
            
            _buildCardSettingsTextFacilityCode(),
            _buildCardSettingsTextAssetCode() ,
            _buildCardSettingsTextFacilityName(),
            CardSettingsHeader(
              label: getTranslated(context, 'facility_trade_rfid_registration'),
              showMaterialonIOS: _showMaterialonIOS,
              color: Colors.indigo,
              labelAlign: TextAlign.center,
            ),
            _buildCardSettingsSwitchAutoSave(),
            customCardField(
              label: getTranslated(context, 'bluetooth'),
              content: Container(
                child: Row(
                  //verticalDirection:  direction,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Container(
                        
                        padding: EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
                        //child: label,
                        child: Text(
                          $userRepository.bluetoothDevice==null?'None':$userRepository.bluetoothDevice.address??'None', 
                          softWrap: true, 
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.normal),
                        ),//Expanded(child: displayText) ,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        child: Container(
                          child: Icon(Icons.arrow_drop_down)
                        ),
                      ),
                    ),
                ],)
                
              ),
            ),
            _buildCardSettingsParagraphRFIDTag(2),
            _buildCardSettingsButtonSave(),
            //_buildCardSettingsButtonConnectBluetooth(),
            SizedBox(height: 5,),
          ],
        ),
        
      ]
    );

  }


  /* BUILDERS FOR EACH FIELD */
  
  CardSettingsParagraph _buildCardSettingsParagraphRFIDTag(int lines) {
    return CardSettingsParagraph(
      showMaterialonIOS: _showMaterialonIOS,
      key: _tagKey,
      controller: _tagControll,
      label: 'RFID Tag',
      initialValue: '',
      numberOfLines: lines,
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_rfid_tag_hint');
        return null;
      },
      onSaved: (value) => {},
      onChanged: (value) {
        setState(() {
          
        });
        //_showSnackBar('Description', value);
      },
    );
  }

  CardSettingsCustomText _buildCardSettingsTextFacilityCode() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _facilityCodeKey,
      controller: _facilityCodeControll,
      label: getTranslated(context, 'facility_code'),
      hintText: getTranslated(context, 'facility_code_hint'),
      initialValue: '',
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_code_hint');
        return null;
      },
      onSaved: (_){},
      onChanged: (value) {
        setState(() {
          //_receiveModel.receiveNum = value;
        });
      },
    );
  }

  CardSettingsCustomText _buildCardSettingsTextAssetCode() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _assetCodeKey,
      label: getTranslated(context, 'input_asset_no'),
      hintText: getTranslated(context, 'input_asset_no_hint'),
      initialValue: '',
      controller: _assetCodeControll,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: false,
      validator: (value) {
        //if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_number_hint');
        return null;
      },
      onSaved: (_){},
      onChanged: (value) {
        setState(() {
          //_receiveModel.receiveNum = value;
        });
      },
    );
  }

  CardSettingsCustomText _buildCardSettingsTextFacilityName() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _facilityNameKey,
      controller: _facilityNameControll,
      label: getTranslated(context, 'facility_name'),
      hintText: '',
      initialValue: '',
      readOnly: true,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: false,
      validator: (value) {
        //if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_number_hint');
        return null;
      },
      onSaved: (_){},
      onChanged: (value) {
        setState(() {
          //_receiveModel.receiveNum = value;
        });
      },
    );
  }

  CardSettingsSwitch _buildCardSettingsSwitchAutoSave() {
    return CardSettingsSwitch(
      key: _autosaveKey,
      label: getTranslated(context, 'auto_save'),
      labelWidth: 240.0,
      initialValue: _autoSaveSwitch,
      onSaved: (value) => _autoSaveSwitch = value,
      onChanged: (value) {
        setState(() {
          _autoSaveSwitch = value;
        });
        _showSnackBar('Auto Save', value);
      },
    );
  }

  CardSettingsButton _buildCardSettingsButtonSave() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'save'),
      backgroundColor: Colors.red,
      textColor: Colors.white,
      onPressed: _savePressed,
    );
  }

  // CardSettingsButton _buildCardSettingsButtonConnectBluetooth() {
  //   return CardSettingsButton(
  //     showMaterialonIOS: _showMaterialonIOS,
  //     label: getTranslated(context, 'Connect Bluetooth'),
  //     backgroundColor: Colors.blue,
  //     textColor: Colors.white,
  //     onPressed: _actionBluetoothStream,
  //   );
  // }

  Future _autoSave() async{
    if(_autoSaveSwitch && _facilityCodeControll.text != '' && _tagControll.text != '')
    {
      bool result = await _savePressed();

      await Future.delayed((Duration(seconds: 3)));
      
      if(result) await Btprotocol.instance.barcodeStartDecode.then((value) {debugPrint('barcode Start!');});
      setState(() {
        
      });
    }
  }

  Future<bool> _savePressed() async {
    final form = _formKey.currentState;


    if (form.validate()) {
      //form.save();
      //showResults(context, _ponyModel);
      //버튼 활성화
      
      bool result = await $facilityTradeCommonRepository.setFacilityRFIDTag(_facilityCodeControll.text, _tagControll.text, $userRepository.user.empNo);

      if(result){
        _showSnackBar("Save", getTranslated(context,"save_successfully"));
        clearData();
        
        setState(() {
          _autoValidate = false;
        });
      }else{
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'error_validation')).show();
      }
      return result;

    } else {
      customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'error_validation')).show();
      setState(() => _autoValidate = true);
    }
    
    return false;
    
  }

  void _actionBluetoothStream() async{
    try{
      bool deviceConnected = await Btprotocol.instance.isConnected;

      if(!_isStreamAction){
         
        //Address 체크
        if($userRepository.bluetoothDevice == null || $userRepository.bluetoothDevice.address == null || $userRepository.bluetoothDevice.address == '')
        {
          customAlertOK(context,getTranslated(context, 'device_not_found'), getTranslated(context, 'device_not_found_desc'))
            .show()
            .then((value) => Navigator.pushNamed(context, bluetoothScanRoute));
          return;
        }
        
        int isConnected = -1;

        if(!deviceConnected){
          //블루투스 연결
          isConnected = await Btprotocol.instance
            .connectDevice($userRepository.bluetoothDevice.address);
        }else{
          isConnected = 0;
        }
        
        debugPrint(isConnected.toString());
        if(isConnected > -9){
          _isStreamAction = true;

          _showSnackBar('Bluetooth', 'Connect successfully.');

          //파워 최소로 변경
          await Btprotocol.instance.setPower(50).then((_) => _showSnackBar('Power','Minimum size(50)'));

          //메모리 초기화
          //Btprotocol.instance.clearData();

          //정상 연결
          if(bluetoothSubscription == null || bluetoothSubscription.isPaused){
            debugPrint("bluetoothSubscription == null");
            bluetoothSubscription = bluetoothStream.listen((event) { dataRead();});
            
          }else{
            debugPrint("bluetoothSubscription not null");
          }
          
        }else{
          //연결 실패
          _showSnackBar('Bluetooth', 'Connection failure.');
        }
      }else{
        await Btprotocol.instance.disconnectDevice();
        bluetoothSubscription.pause();
        _showSnackBar('Bluetooth', 'Disconnect.');
        debugPrint(bluetoothSubscription.toString());
        _isStreamAction = false;
      }

    } catch(ex){
      debugPrint("Error : _actionBluetoothStream()");
    }
    
    setState(() {
      
    });
    
  }
  
  Future<bool> dataRead() async {
    List<SharkDataInfo> tagList = await Btprotocol.instance.getListTag;

    debugPrint("tagList length : ${tagList.length.toString()}");
    if(tagList.length > 0){
      //for(SharkDataInfo data in tagList)
      SharkDataInfo data = tagList.last;
      if(tagLastValue==data.tagData){
        debugPrint("Same Tag Data  : Last Data $tagLastValue , Current Data ${data.type}, ${data.tagData}");
        return true;
      }else{
        tagLastValue = data.tagData;
      }

      debugPrint("Tag Id(device) : ${data.type}, ${data.tagData}");
      if(data.type.toUpperCase() == "B")
      {
        debugPrint("Check => _assetCodeControll.text :"+_assetCodeControll.text);
        if(_assetCodeControll.text == ""){
          _assetCodeControll.text = data.tagData;
          debugPrint("In => _assetCodeControll.text :"+_assetCodeControll.text);
          bool result = await getFacilityInfo('asset', data.tagData);
          if(result){
            _showSnackBar('Facility Info', 'The call was successful.');
            //await _autoSave();
          }else{
            _showSnackBar('Facility Info', 'The call failed.');
          }
          
        }
        
      }
      if(data.type.toUpperCase() == "R"){
        debugPrint("Check => _tagControll.text :"+_tagControll.text);
        if(_tagControll.text == ""){
          _tagControll.text = data.tagData;
          debugPrint("In => _tagControll.text :"+_tagControll.text);
          await _autoSave();
          
        }else if(_tagControll.text.toLowerCase() != data.tagData.toLowerCase()){
          customAlertOK(context,getTranslated(context, 'check_error_rfid_tag_exists'),'')
            .show();
        }else if(_tagControll.text.toLowerCase() == data.tagData.toLowerCase()){
          await _autoSave();
          
        }
      }
    }
    
    return true;
  }

  Future<bool> getFacilityInfo(String searchDiv, String value) async{
    return await $facilityTradeCommonRepository.getRFIDFacility(searchDiv, value)
      .then<bool>((info){
        if(info != null){
          debugPrint("assetCode : ${info.assetCode}, code: ${info.facilityCode}, name: ${info.facilityName}, rfid: ${info.rfid}");
          _assetCodeControll.text = info.assetCode;
          _facilityCodeControll.text = info.facilityCode;
          _facilityNameControll.text = info.facilityName??'';
          _tagControll.text = info.rfid??'';

          setState(() {
          
          });
          return true;
        }else{
          setState(() {
          
          });
          return false;
        }
      });
  }

  Future clearData() async{

    _tagControll.text = '';
    _facilityNameControll.text = '';
    _facilityCodeControll.text = '';
    _assetCodeControll.text = '';
    tagLastValue='';

    if(_isStreamAction) {
      await Btprotocol.instance.clearData().then((value){ debugPrint('Reader Tag Data Clear!');});
    }
    //_formKey.currentState.reset();
    
    setState(() {
      
    });    
    
  }

  void _showSnackBar(String label, dynamic value) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(label + ' = ' + value.toString()),
      ),
    );
  }
}