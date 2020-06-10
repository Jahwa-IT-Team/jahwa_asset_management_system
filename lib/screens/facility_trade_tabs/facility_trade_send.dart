

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_send_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/widgets/facility_trade_request_customer_dialog.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/card_settings_custom_text.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';


//card_settings 예제
//https://pub.dev/packages/card_settings#-example-tab-

class FacilityTradeSendPage extends StatefulWidget{
  @override
  _FacilityTradeSendPageState createState() => _FacilityTradeSendPageState();

}

class _FacilityTradeSendPageState extends State<FacilityTradeSendPage>{
  bool _showMaterialonIOS = true;
  bool _autoValidate = false;
  
  ProgressDialog pr;
  FacilityTradeSendRepository $facilityTradeSendRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  UserRepository $userRepository; 
  FacilityPageStatus pageStatus = FacilityPageStatus.None;

  final GlobalKey<ScaffoldState> _scaffold1Key = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _form1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _sendInvoiceNoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _sendTypeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqShipperNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _sendDateKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forecastDateKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _sendCommentNameKey = GlobalKey<FormState>();
  
  
  final _invNoController = TextEditingController();
  final _shipperNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context){
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    pr.style(
      //message: getTranslated(context, 'Login'),
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

    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if($facilityTradeSendRepository ==null){
      $facilityTradeSendRepository = Provider.of<FacilityTradeSendRepository>(context, listen: true);
      $facilityTradeSendRepository.init();
    }

    if($facilityTradeCommonRepository ==null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    _invNoController.text = $facilityTradeSendRepository.sendHeader.invNo;
    _shipperNameController.text = $facilityTradeSendRepository.sendHeader.sendCustName??'';
    
    return Scaffold(
      key: _scaffold1Key,
      body: Form(
        key: _form1Key,
        // child: (orientation == Orientation.portrait)
        //     ? buildPortraitLayout()
        //     : buildLandscapeLayout(),
        child: buildPortraitLayout(),
      ),
    );
  } 

  Widget buildPortraitLayout(){
    

    return CardSettings.sectioned(
      showMaterialonIOS: _showMaterialonIOS,
      labelWidth: 120,
      children: <CardSettingsSection>[
        CardSettingsSection(
          showMaterialonIOS: _showMaterialonIOS,
          
          header: CardSettingsHeader(
            label: getTranslated(context, 'facility_trade_send'),
            showMaterialonIOS: _showMaterialonIOS,
            color: Colors.indigo,
            labelAlign: TextAlign.center,
          ),
          children: <Widget>[
            buildCardSettingsTextInvoiceNo(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsDatePickerSendDate(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsDatePickerForecastDate(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsListPickerSendType(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsTextShipperName(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsParagraphReqComment(3),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonDetailView(),
            if(pageStatus == FacilityPageStatus.None) buildCardSettingsButtonFind(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonSave(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonReset(),
            SizedBox(height: 5,),
          ],
        ),
      ]
    );

  }


  /* BUILDERS FOR EACH FIELD */
  CardSettingsCustomText buildCardSettingsTextInvoiceNo() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _sendInvoiceNoKey,
      controller: _invNoController,
      readOnly: pageStatus != FacilityPageStatus.None,
      label: getTranslated(context, 'facility_trade_send_invoice_no'),
      hintText: getTranslated(context, 'facility_trade_send_invoice_no_hint'),
      initialValue:  $facilityTradeSendRepository.sendHeader==null?'':$facilityTradeSendRepository.sendHeader.invNo,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_send_invoice_no_hint');
        return null;
      },
      //visible: !(pageStatus == FacilityPageStatus.New),
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.invNo = value,
      onChanged: (value) {
        //$facilityTradeSendRepository.init();
        // setState(() {
        //   $facilityTradeSendRepository.sendHeader.invoiceNo = value;
        // });
        //_showSnackBar(getTranslated(context, 'facility_trade_send_invoice_no'), value);
      },
      
    );
  }

  CardSettingsListPicker buildCardSettingsListPickerSendType() {
    
    //debugPrint("buildCardSettingsListPickerSendType : "); //+ ($facilityTradeSendRepository.sendHeader==null?'':$facilityTradeSendRepository.sendHeader.sendMethod));
    return CardSettingsListPicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _sendTypeKey,
      label: getTranslated(context, 'facility_trade_send_type'),
      initialValue: $facilityTradeSendRepository.sendHeader==null?'':$facilityTradeSendRepository.sendHeader.sendMethod,
      hintText: getTranslated(context, 'facility_trade_send_type_hint'),
      autovalidate: _autoValidate,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      //visible: (pageStatus != FacilityPageStatus.None),
      options: <String>[
        getTranslated(context,'facility_trade_send_type_air'), 
        getTranslated(context,'facility_trade_send_type_shp'), 
        getTranslated(context,'facility_trade_send_type_exp'), 
        getTranslated(context,'facility_trade_send_type_trk'), 
        getTranslated(context,'facility_trade_send_type_trn')
      ],
      values: <String>['AIR', 'SHP', 'EXP', 'TRK', 'TRN'],
      validator: (String value) {
        if (value == null || value.isEmpty) return 'AIR'; //return getTranslated(context, 'facility_trade_send_type_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.sendMethod = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeSendRepository.sendHeader.sendMethod = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_send_type'), value);
      },
    );
  }

  CardSettingsCustomText buildCardSettingsTextShipperName() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqShipperNameKey,
      controller: _shipperNameController,
      readOnly: true,
      label: getTranslated(context, 'facility_trade_send_shipper'),
      hintText: getTranslated(context, 'facility_trade_send_shipper_hint'),
      initialValue: $facilityTradeSendRepository.sendHeader==null?'': $facilityTradeSendRepository.sendHeader.sendCustName??'',
      autovalidate: _autoValidate,
      // validator: (value) {
      //   if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_send_shipper_hint');
      //   return null;
      // },
      onTap: showCustomerDialog ,
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.sendCustName = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeSendRepository.sendHeader.sendCustName = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_send_shipper'), value);
      },
      
    );
  }


  void showCustomerDialog() async{
    selectedItems= [];
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return (menuWidget);
    });

    if(selectedItems.length > 0){
     
      $facilityTradeSendRepository.sendHeader.sendCustCode = $facilityTradeCommonRepository.searchBizPartnerList[selectedItems[0]].bpCode;
      $facilityTradeSendRepository.sendHeader.sendCustName = $facilityTradeCommonRepository.searchBizPartnerList[selectedItems[0]].bpName;
      setState(() {
        
      });
    }
    
  }

  BoxConstraints menuConstraints;
  List<int> selectedItems= [];
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);
  Function displayItem;


  Widget get menuWidget {
    return (CustomerDropdownDialog(
      //items: $facilityTradeRequestRepository.searchManagerDropdownMenuItem,
      hint: prepareWidget(getTranslated(context, 'facility_trade_send_shipper_hint')),
      closeButton: 'Close',
      keyboardType: TextInputType.text,
      multipleSelection: false,
      selectedItems: selectedItems,
      doneButton: null,
      displayItem: displayItem,
      validator: null,
      dialogBox: true,
      displayMenu: displayMenu,
      menuConstraints:menuConstraints,
      menuBackgroundColor: Colors.white,
      callOnPop: () {

      },
    ));
  }

  CardSettingsDatePicker buildCardSettingsDatePickerSendDate() {
    return CardSettingsDatePicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _sendDateKey,
      label: getTranslated(context, 'facility_trade_send_date'),
      initialValue: $facilityTradeSendRepository.sendHeader.sendDate==null?DateTime.now():$facilityTradeSendRepository.sendHeader.sendDate,
      //visible: (pageStatus != FacilityPageStatus.None),
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.sendDate =
          updateJustDate(value, $facilityTradeSendRepository.sendHeader.sendDate),
      onChanged: (value) {
        setState(() {
          $facilityTradeSendRepository.sendHeader.sendDate = value;
        });
         //_showSnackBar(getTranslated(context, 'facility_trade_send_date'), updateJustDate(value, $facilityTradeSendRepository.sendHeader.sendDate));
      },
    );
  }

  CardSettingsDatePicker buildCardSettingsDatePickerForecastDate() {
    return CardSettingsDatePicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _forecastDateKey,
      //justDate: true,
      //icon: Icon(Icons.calendar_today),
      label: getTranslated(context, 'facility_trade_forecast_date'),
      initialValue: $facilityTradeSendRepository.sendHeader.forecastDate==null?DateTime.now():$facilityTradeSendRepository.sendHeader.forecastDate,
      //visible: (pageStatus != FacilityPageStatus.None),
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.forecastDate =
          updateJustDate(value, $facilityTradeSendRepository.sendHeader.forecastDate),
      onChanged: (value) {
        setState(() {
          $facilityTradeSendRepository.sendHeader.forecastDate = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_forecast_date'), updateJustDate(value, $facilityTradeSendRepository.sendHeader.forecastDate));
      },
    );
  }

  CardSettingsParagraph buildCardSettingsParagraphReqComment(int lines) {
    return CardSettingsParagraph(
      showMaterialonIOS: _showMaterialonIOS,
      key: _sendCommentNameKey,
      label: getTranslated(context, 'facility_trade_request_comment'),
      initialValue: $facilityTradeSendRepository.sendHeader==null?'':$facilityTradeSendRepository.sendHeader.comment,
      numberOfLines: lines,
      //visible: (pageStatus != FacilityPageStatus.None),
      onSaved: (value) => $facilityTradeSendRepository.sendHeader.comment = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeSendRepository.sendHeader.comment = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_comment'), value);
      },
    );
  }

  CardSettingsButton buildCardSettingsButtonReset() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'cancel'),
      isDestructive: true,
      onPressed: resetPressed,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      //visible: (pageStatus != FacilityPageStatus.None),
    );
  }

  CardSettingsButton buildCardSettingsButtonFind() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'find'),
      backgroundColor: Colors.indigo,
      textColor: Colors.white,
      //visible: pageStatus == FacilityPageStatus.None,
      onPressed: (){findPressed(_invNoController.text);},
    );
  }

  CardSettingsButton buildCardSettingsButtonSave() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'save'),
      onPressed: savePressed,
      backgroundColor: Colors.indigo,
      textColor: Colors.white,
      //visible: (pageStatus != FacilityPageStatus.None),
    );
  }

  CardSettingsButton buildCardSettingsButtonDetailView() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'facility_list_view')+"(${$facilityTradeSendRepository.sendDetailList.length})",
      backgroundColor: Colors.black,
      textColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, facilityTradeRequestDetailViewRoute, arguments: PageType.Send),
      //visible: (pageStatus != FacilityPageStatus.None),
    );
  }


  Future findPressed(String invNo) async {
    $facilityTradeSendRepository.init();
    
    //String reqNo = _reqNumController.text;
    if(invNo == null || invNo == ''){
      customAlertOK(context,'', getTranslated(context, 'facility_trade_request_number_hint')).show();
      return;
    }
    await pr.show();
    await $facilityTradeSendRepository.getFacilitySendHeader(invNo)
      .then((rtnValue) {
        pr.hide();
        if(rtnValue){
          $facilityTradeSendRepository.getFacilitySendDetailList(invNo);
          setState(() {
            pageStatus = FacilityPageStatus.Update;
          });         
        }else{
          $facilityTradeSendRepository.initSend();
          customAlertOK(context,'', getTranslated(context, 'empty_value')).show();
          pageStatus = FacilityPageStatus.New;
          $facilityTradeSendRepository.sendHeader.invNo = invNo;
          $facilityTradeSendRepository.sendHeader.sendDate = DateTime.now();
          $facilityTradeSendRepository.sendHeader.forecastDate = DateTime.now();
        }
        return rtnValue;
    });
    await pr.hide();
  }

  /* EVENT HANDLERS */
  Future savePressed() async {
    final form = _form1Key.currentState;
    
    /* 데이터 체크 */
    $facilityTradeSendRepository.sendHeader.invNo = $facilityTradeSendRepository.sendHeader.invNo??_invNoController.text;
    $facilityTradeSendRepository.sendHeader.sendDate = $facilityTradeSendRepository.sendHeader.sendDate??DateTime.now();
    $facilityTradeSendRepository.sendHeader.forecastDate = $facilityTradeSendRepository.sendHeader.forecastDate??DateTime.now();

    
    if (form.validate()) {
      //form.save();
      //showResults(context, _ponyModel);
      //버튼 활성화
      

      ResultSaveSend result= await $facilityTradeSendRepository.setFacilitySend($userRepository.user.empNo);

      if(result.result.toLowerCase() == "okay"){
        customAlertOK(context,getTranslated(context, 'saved'), getTranslated(context, 'save_successfully'))
          .show()
          .then((_){
            if(result.invNo == ""){
              //삭제 후
              resetPressed();
            }else{
              //신규 및 수정 후
              findPressed(result.invNo);
            }
            
          });
      }else if(result.result.toLowerCase() == "exists"){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message_exists')).show();
      }else if(result.invNo == "" || result.result.toLowerCase()!='okay'){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message')).show();
      }else{
        customAlertOK(context,getTranslated(context, 'saved'), getTranslated(context, 'save_successfully')).show();
      }


    } else {
      customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'error_validation')).show();
      setState(() => _autoValidate = true);
    }
  }

  void resetPressed() {
    //_form1Key.currentState.reset();
    $facilityTradeSendRepository.initSend();
    
    setState(() {
      pageStatus = FacilityPageStatus.None;
    });
  }

  // void _showSnackBar(String label, dynamic value) {
  //   _scaffold1Key.currentState.removeCurrentSnackBar();
  //   _scaffold1Key.currentState.showSnackBar(
  //     SnackBar(
  //       duration: Duration(seconds: 1),
  //       content: Text(label + ' = ' + value.toString()),
  //     ),
  //   );
  // }
}