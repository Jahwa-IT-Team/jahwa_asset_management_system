

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_request_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/widgets/facility_trade_request_user_dialog.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import '../../widgets/card_settings_custom_text.dart';



//card_settings 예제
//https://pub.dev/packages/card_settings#-example-tab-

class FacilityTradeRequestPage extends StatefulWidget{
  @override
  _FacilityTradeRequestPageState createState() => _FacilityTradeRequestPageState();

}

class _FacilityTradeRequestPageState extends State<FacilityTradeRequestPage>{
  bool _showMaterialonIOS = true;
  bool _autoValidate = false;
  bool _isUpdate = false;
  bool _isFirst = true;
  bool _btnSave = false;
  bool _btnNew = true;
  bool _btnFind = true;
  bool _btnReset = false;
  UserRepository $userRepository; 
  FacilityTradeRequestRepository $facilityTradeRequestRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  ProgressDialog pr;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqNumKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqTypeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqCompanyTypeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqPersonNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqDateKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reqCommentNameKey = GlobalKey<FormState>();

  final _reqNumController = TextEditingController();
  final _reqPersonNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

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
    //var orientation = MediaQuery.of(context).orientation;
    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if($facilityTradeRequestRepository == null){
      $facilityTradeRequestRepository = Provider.of<FacilityTradeRequestRepository>(context, listen: true);
      $facilityTradeRequestRepository.init();
    }

    if($facilityTradeCommonRepository == null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }
    _reqNumController.text = $facilityTradeRequestRepository.requestHeader.reqNo??'';
    _reqPersonNameController.text = $facilityTradeRequestRepository.requestHeader.name??'';
    
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
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
            label: getTranslated(context, 'facility_trade_request'),
            showMaterialonIOS: _showMaterialonIOS,
            labelAlign: TextAlign.center,
            color: Colors.indigo,
          ),
          children: <Widget>[
            //if(_isUpdate || _isFirst) 
            buildCardSettingsTextReqNum(),
            if(_isUpdate || !_isFirst) buildCardSettingsListPickerReqType(),
            if(_isUpdate || !_isFirst) buildCardSettingsListPickerCompanyType(),
            if(_isUpdate || !_isFirst) buildCardSettingsTextPersonName(),
            if(_isUpdate || !_isFirst) buildCardSettingsDatePickerReqDate(),
            if(_isUpdate || !_isFirst) buildCardSettingsParagraphReqComment(3),
            if($facilityTradeRequestRepository.requestDetailList.length > 0 || _btnSave) buildCardSettingsButtonDetailView(),
            if(_btnSave) buildCardSettingsButtonSave(),
            if(_btnFind) buildCardSettingsButtonFind(),
            if(_btnNew) buildCardSettingsButtonNew(),
            if(_btnReset) buildCardSettingsButtonReset(),
            //testSearch(),
            SizedBox(height: 5,),
            
          ],
        ),
      ]
    );

  }

  /* BUILDERS FOR EACH FIELD */
  CardSettingsCustomText buildCardSettingsTextReqNum() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      controller: _reqNumController,
      key: _reqNumKey,
      readOnly: !_isFirst,
      label: getTranslated(context, 'facility_trade_request_number'),
      hintText: getTranslated(context, 'facility_trade_request_number_hint'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?'':$facilityTradeRequestRepository.requestHeader.reqNo,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      validator: (value) {
        if (!(_isUpdate||_isFirst)) return null;
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_request_number_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.reqNo = value,
      onChanged: (value) {
        debugPrint("onChanged ReqNo(Provider)");
        debugPrint("onChanged ReqNo(Provider):${$facilityTradeRequestRepository.requestHeader.reqNo}");
        $facilityTradeRequestRepository.init();
        $facilityTradeRequestRepository.requestHeader.reqNo = value;
        // setState(() {
        //   $facilityTradeRequestRepository.requestHeader.reqNo = value;
        // });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_number'), value);
      },
      
    );
  }

  CardSettingsListPicker buildCardSettingsListPickerReqType() {
    return CardSettingsListPicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqTypeKey,
      label: getTranslated(context, 'facility_trade_request_type'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?'Repair':$facilityTradeRequestRepository.requestHeader.reqDiv==''?'Repair':$facilityTradeRequestRepository.requestHeader.reqDiv,
      hintText: getTranslated(context, 'facility_trade_request_type_hint'),
      autovalidate: _autoValidate,
      options: <String>[
        getTranslated(context,'facility_trade_request_type_repair'), 
        getTranslated(context,'facility_trade_request_type_remodel'), 
        getTranslated(context,'facility_trade_request_type_return'), 
        getTranslated(context,'facility_trade_request_type_sale'), 
        getTranslated(context,'facility_trade_request_type_etc')
      ],
      values: <String>['Repair', 'Remodel', 'Return', 'Sale', 'Etc'],
      validator: (String value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_request_type_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.reqDiv = value,
      onChanged: (value) {
        debugPrint(value);
        setState(() {
          $facilityTradeRequestRepository.requestHeader.reqDiv = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_type'), value);
      },
    );
  }

  CardSettingsListPicker buildCardSettingsListPickerCompanyType() {
    return CardSettingsListPicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqCompanyTypeKey,
      label: getTranslated(context, 'facility_trade_request_company_type'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?'':$facilityTradeRequestRepository.requestHeader.entCode,
      hintText: getTranslated(context, 'facility_trade_request_company_type_hint'),
      autovalidate: _autoValidate,
      options: <String>['자화전자주식회사','JAHWA VINA CO LTD','惠州纳诺泰克合金科技有限公司','天津磁化电子有限公司','JH VINA CO LTD','JAHWA INDIA','주식회사나노테크','NT VINA CO LTD','NANOTECH VINA CO LTD'],
      values: <String>['KO532', 'VN532','HZ532','TJ532','JV532','IN532','KO536','VN536','VN538'],
      validator: (String value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_request_company_type_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.entCode = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeRequestRepository.requestHeader.entCode = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_company_type'), value);
      },
    );
  }

  CardSettingsCustomText buildCardSettingsTextPersonName() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqPersonNameKey,
      controller: _reqPersonNameController,
      readOnly: true,
      onTap: _showPersonDialog,
      label: getTranslated(context, 'facility_trade_request_person_name'),
      hintText: getTranslated(context, 'facility_trade_request_person_name_hint'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?'':$facilityTradeRequestRepository.requestHeader.name,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_request_number_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.name = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeRequestRepository.requestHeader.name = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_number'), value);
      },
      
    );
  }

  void _showPersonDialog() async{
    selectedItems= [];
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return (menuWidget);
    });

    if(selectedItems.length > 0){
      //await $facilityTradeRequestRepository.changeSelectManager(selectedItems[0]);
      $facilityTradeRequestRepository.requestHeader.empCode = $facilityTradeCommonRepository.searchManagerList[selectedItems[0]].empCode;
      $facilityTradeRequestRepository.requestHeader.name = $facilityTradeCommonRepository.searchManagerList[selectedItems[0]].name;
      setState(() {
        //_reqPersonNameController.text = $facilityTradeRequestRepository.requestHeader.name;
      });
    }
    
  }

  BoxConstraints menuConstraints;
  List<int> selectedItems= [];
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);
  Function displayItem;


  Widget get menuWidget {
    return (UserDropdownDialog(
      //items: $facilityTradeRequestRepository.searchManagerDropdownMenuItem,
      hint: prepareWidget(getTranslated(context, 'facility_trade_request_person_name_hint')),
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

  CardSettingsDatePicker buildCardSettingsDatePickerReqDate() {
    return CardSettingsDatePicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqDateKey,
      //justDate: true,
      //icon: Icon(Icons.calendar_today),
      dateFormat: DateFormat.yMd(),
      label: getTranslated(context, 'facility_trade_request_date'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?DateTime.now():$facilityTradeRequestRepository.requestHeader.returnDate,
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.returnDate =
          updateJustDate(value, DateTime.now() ),
      onChanged: (value) {
        setState(() {
          $facilityTradeRequestRepository.requestHeader.returnDate = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_request_date'), updateJustDate(value, $facilityTradeRequestRepository.requestHeader.returnDate));
      },
    );
  }

  CardSettingsParagraph buildCardSettingsParagraphReqComment(int lines) {
    return CardSettingsParagraph(
      showMaterialonIOS: _showMaterialonIOS,
      key: _reqCommentNameKey,
      label: getTranslated(context, 'facility_trade_request_comment'),
      initialValue: $facilityTradeRequestRepository.requestHeader==null?'':$facilityTradeRequestRepository.requestHeader.comment,
      numberOfLines: lines,
      onSaved: (value) => $facilityTradeRequestRepository.requestHeader.comment = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeRequestRepository.requestHeader.comment = value;
        });
        //_showSnackBar('Description', value);
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
    );
  }

  CardSettingsButton buildCardSettingsButtonSave() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'save'),
      backgroundColor: Colors.indigo,
      textColor: Colors.white,
      onPressed: savePressed,
    );
  }

  CardSettingsButton buildCardSettingsButtonFind() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'find'),
      backgroundColor: Colors.indigo,
      textColor: Colors.white,
      onPressed: (){findPressed(_reqNumController.text);},
    );
  }

  CardSettingsButton buildCardSettingsButtonNew() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'new'),
      backgroundColor: Colors.red,
      textColor: Colors.white,
      onPressed: newPressed,
    );
  }

  CardSettingsButton buildCardSettingsButtonDetailView() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'facility_list_view')+"(${$facilityTradeRequestRepository.requestDetailList.length})",
      backgroundColor: Colors.black,
      textColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, facilityTradeRequestDetailViewRoute, arguments: PageType.Request),
    );
  }

  /* EVENT HANDLERS */
  Future newPressed() async {
    $facilityTradeRequestRepository.init();
    //_reqPersonNameController.clear();
    _reqNumController.text = "";
    setState(() {
      _isUpdate = false;
      _isFirst = false;

      //버튼 활성화
      _btnSave = true;
      _btnNew = false;
      _btnFind = false;
      _btnReset = true;
    });
  }

  Future findPressed(String reqNo) async {
    $facilityTradeRequestRepository.init();
    //debugPrint("reqNo : ${$facilityTradeRequestRepository.requestHeader.reqNo}");
    //String reqNo = _reqNumController.text;
    if(reqNo == null || reqNo == ''){
      customAlertOK(context,'', getTranslated(context, 'facility_trade_request_number_hint')).show();
      return;
    }
    await pr.show();
    await $facilityTradeRequestRepository.getFacilityRequestHeader(reqNo)
      .then((rtnValue) {
        pr.hide();
        
        if(rtnValue){
          $facilityTradeRequestRepository.getFacilityRequestDetailList(reqNo);
          setState(() {
            _isUpdate = true;
            _isFirst = false;
            //버튼 활성화
            _btnSave = true;
            _btnNew = false;
            _btnFind = false;
            _btnReset = true;

          });
        }else{
          customAlertOK(context,'', getTranslated(context, 'empty_value')).show();
        }
        return rtnValue;
    });

    await pr.hide();
  }

  Future savePressed() async {
    final form = _formKey.currentState;
    bool checkValidation = true;

    /* 데이터 체크 */
    $facilityTradeRequestRepository.requestHeader.returnDate = $facilityTradeRequestRepository.requestHeader.returnDate??DateTime.now();
    //설비 데이터 체크
    $facilityTradeRequestRepository
      .requestDetailList
      .forEach((e) {
        if(e.facilityGrade == null || e.facilityGrade == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'facility_grade')).show();
          checkValidation = false;
        }
        if(e.plantCode == null || e.plantCode == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'plant')).show();
          checkValidation = false;
        }
        if(e.itemGroup == null || e.itemGroup == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'item_group'))
          .show();
          checkValidation = false;
        }
      });

    if (form.validate() && checkValidation) {
      //form.save();
      //showResults(context, _ponyModel);
      //버튼 활성화
      

      ResultSaveRequest result= await $facilityTradeRequestRepository.setFacilityRequest($userRepository.user.empNo);

      if(result.result.toLowerCase() == "okay"){
        customAlertOK(context,getTranslated(context, 'saved'), getTranslated(context, 'save_successfully'))
          .show()
          .then((_){
            if(result.reqNo == ""){
              resetPressed();
            }else{
              findPressed(result.reqNo);
            }
            
          });
      }else if(result.result.toLowerCase() == "exists"){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message_exists')).show();
      }else if(result.reqNo == ""){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message')).show();
      }else{
        customAlertOK(context,getTranslated(context, 'save_faild'), result.result).show();
      }

    } else if(checkValidation) {
      customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'error_validation')).show();
      setState(() => _autoValidate = true);
    }
  }

  void resetPressed() {
    $facilityTradeRequestRepository.init();
    //_reqPersonNameController.clear();

    setState(() {
      _isUpdate = false;
      _isFirst = true;

      //버튼 활성화
      _btnSave = false;
      _btnNew = true;
      _btnFind = true;
      _btnReset = false;
    });
    
  }


}

