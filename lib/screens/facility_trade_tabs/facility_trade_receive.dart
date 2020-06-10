

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter/rendering.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_receive_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/card_settings_custom_text.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'widgets/facility_trade_request_user_dialog.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//card_settings 예제
//https://pub.dev/packages/card_settings#-example-tab-

class FacilityTradeReceivePage extends StatefulWidget{
  @override
  _FacilityTradeReceivePageState createState() => _FacilityTradeReceivePageState();

}

class _FacilityTradeReceivePageState extends State<FacilityTradeReceivePage>{
  bool _showMaterialonIOS = true;
  bool _autoValidate = false;

  ProgressDialog pr;
  FacilityPageStatus pageStatus = FacilityPageStatus.None;
  FacilityTradeReceiveRepository $facilityTradeReceiveRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  UserRepository $userRepository; 

  final GlobalKey<ScaffoldState> _scaffold2Key = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _form2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvNumKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvCompanyTypeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvInvoiceNo = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvDateKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvPersonNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _recvCommentNameKey = GlobalKey<FormState>();

  final _recNoController = TextEditingController();
  final _personNameController = TextEditingController();
  
  /// List Popup
  BoxConstraints menuConstraints;
  List<int> selectedItems= [];
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);
  Function displayItem;
  
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

    if($facilityTradeReceiveRepository ==null){
      $facilityTradeReceiveRepository = Provider.of<FacilityTradeReceiveRepository>(context, listen: true);
      $facilityTradeReceiveRepository.init();
    }

    if($facilityTradeCommonRepository ==null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    
    _recNoController.text = $facilityTradeReceiveRepository.receiveHeader.recNo??'';
    _personNameController.text = $facilityTradeReceiveRepository.receiveHeader.receiverName??'';
    $facilityTradeReceiveRepository.receiveHeader.receiveDate = $facilityTradeReceiveRepository.receiveHeader.receiveDate??DateTime.now();

    return Scaffold(
      key: _scaffold2Key,
      body: Form(
        key: _form2Key,
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
            label: getTranslated(context, 'facility_trade_receive'),
            showMaterialonIOS: _showMaterialonIOS,
            color: Colors.indigo,
            labelAlign: TextAlign.center,
          ),
          children: <Widget>[
            buildCardSettingsTextRecvNum(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsListPickerCompanyType(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsTextInvoiceNo(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsDatePickerRecvDate(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsTextPersonName(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsParagraphRecvComment(3),
            if(pageStatus != FacilityPageStatus.None && $facilityTradeReceiveRepository.receiveDetailList.length > 0) buildInvoiceListBox(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonDetailView(),
            if(pageStatus == FacilityPageStatus.None) buildCardSettingsButtonFind(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonSave(),
            if(pageStatus != FacilityPageStatus.New)  buildCardSettingsButtonNew(),
            if(pageStatus != FacilityPageStatus.None) buildCardSettingsButtonReset(),
            SizedBox(height: 5,),
          ],
        ),
      ]
    );

  }

  /* BUILDERS FOR EACH FIELD */
  CardSettingsCustomText buildCardSettingsTextRecvNum() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvNumKey,
      controller: _recNoController,
      label: getTranslated(context, 'facility_trade_receive_number'),
      hintText: getTranslated(context, 'facility_trade_receive_number_hint'),
      initialValue: $facilityTradeReceiveRepository.receiveHeader.recNo==null?'':$facilityTradeReceiveRepository.receiveHeader.recNo,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      readOnly: (pageStatus != FacilityPageStatus.None),
      //visible: (pageStatus != FacilityPageStatus.New),
      autovalidate: _autoValidate,
      validator: (value) {
        if(pageStatus == FacilityPageStatus.New) return null;
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_number_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.recNo = value,
      onChanged: (value) {
        $facilityTradeReceiveRepository.receiveHeader.recNo = value;
        // setState(() {
        //   $facilityTradeReceiveRepository.receiveHeader.recNo = value;
        // });
        //_showSnackBar(getTranslated(context, 'facility_trade_receive_number'), value);
      },
      
    );
  }

  CardSettingsListPicker buildCardSettingsListPickerCompanyType() {
    return CardSettingsListPicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvCompanyTypeKey,
      label: getTranslated(context, 'facility_trade_receive_company_type'),
      initialValue: $facilityTradeReceiveRepository.receiveHeader==null?'':$facilityTradeReceiveRepository.receiveHeader.entCode,
      hintText: getTranslated(context, 'facility_trade_receive_company_type_hint'),
      autovalidate: _autoValidate,
      options: <String>['자화전자주식회사','JAHWA VINA CO LTD','惠州纳诺泰克合金科技有限公司','天津磁化电子有限公司','JH VINA CO LTD','JAHWA INDIA','주식회사나노테크','NT VINA CO LTD','NANOTECH VINA CO LTD'],
      values: <String>['KO532', 'VN532','HZ532','TJ532','JV532','IN532','KO536','VN536','VN538'],
      validator: (String value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_company_type_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.entCode = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeReceiveRepository.receiveHeader.entCode = value;
        });
        //_showSnackBar(getTranslated(context, 'facility_trade_receive_company_type'), value);
      },
    );
  }

  CardSettingsText buildCardSettingsTextInvoiceNo() {
    return CardSettingsText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvInvoiceNo,
      label: getTranslated(context, 'facility_trade_receive_invoice_no'),
      hintText: getTranslated(context, 'facility_trade_receive_invoice_no_hint'),
      initialValue: $facilityTradeReceiveRepository.receiveHeader==null?'':$facilityTradeReceiveRepository.receiveHeader.recInvNo,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: false,
      validator: (value) {
        return null;
        // if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_invoice_no_hint');
        // return null;
      },
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.recInvNo = value,
      onChanged: (value) {
        // setState(() {
        //   $facilityTradeReceiveRepository.receiveHeader.recInvNo = value;
        // });
        //_showSnackBar('Name', value);
      },
      
    );
  }

  CardSettingsDatePicker buildCardSettingsDatePickerRecvDate() {
    return CardSettingsDatePicker(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvDateKey,
      //justDate: true,
      //icon: Icon(Icons.calendar_today),
      label: getTranslated(context, 'facility_trade_receive_date'),
      initialValue: $facilityTradeReceiveRepository.receiveHeader.receiveDate==null?DateTime.now():$facilityTradeReceiveRepository.receiveHeader.receiveDate,
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.receiveDate =
          updateJustDate(value,$facilityTradeReceiveRepository.receiveHeader.receiveDate),
      onChanged: (value) {
        setState(() {
          $facilityTradeReceiveRepository.receiveHeader.receiveDate = value;
        });
        
      },
    );
  }

  CardSettingsCustomText buildCardSettingsTextPersonName() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvPersonNameKey,
      controller: _personNameController,
      label: getTranslated(context, 'facility_trade_receive_person_name'),
      hintText: getTranslated(context, 'facility_trade_receive_person_name_hint'),
      onTap: showPersonDialog,
      initialValue: $facilityTradeReceiveRepository.receiveHeader==null?'':$facilityTradeReceiveRepository.receiveHeader.receiverName,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null || value.isEmpty) return getTranslated(context, 'facility_trade_receive_number_hint');
        return null;
      },
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.receiverName = value,
      onChanged: (value) {
        setState(() {
          //$facilityTradeReceiveRepository.receiveHeader.receiverName = value;
        });
        //_showSnackBar('Name', value);
      },
      
    );
  }

  void showPersonDialog() async{
    selectedItems= [];
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return (menuWidget);
    });

    if(selectedItems.length > 0){
      //await $facilityTradeRequestRepository.changeSelectManager(selectedItems[0]);
      $facilityTradeReceiveRepository.receiveHeader.receiver = $facilityTradeCommonRepository.searchManagerList[selectedItems[0]].empCode;
      $facilityTradeReceiveRepository.receiveHeader.receiverName = $facilityTradeCommonRepository.searchManagerList[selectedItems[0]].name;
      setState(() {
        //_reqPersonNameController.text = $facilityTradeRequestRepository.requestHeader.name;
      });
    }
    
  }

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
  
  CardSettingsParagraph buildCardSettingsParagraphRecvComment(int lines) {
    return CardSettingsParagraph(
      showMaterialonIOS: _showMaterialonIOS,
      key: _recvCommentNameKey,
      label: getTranslated(context, 'facility_trade_receive_comment'),
      initialValue: $facilityTradeReceiveRepository.receiveHeader==null?'':$facilityTradeReceiveRepository.receiveHeader.comment,
      numberOfLines: lines,
      onSaved: (value) => $facilityTradeReceiveRepository.receiveHeader.comment = value,
      onChanged: (value) {
        setState(() {
          $facilityTradeReceiveRepository.receiveHeader.comment = value;
        });
        //_showSnackBar('Description', value);
      },
    );
  }

  CardSettingsButton buildCardSettingsButtonFind() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'find'),
      backgroundColor: Colors.indigo,
      textColor: Colors.white,
      //visible: pageStatus == FacilityPageStatus.None,
      onPressed: (){findPressed(_recNoController.text);},
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
      label: getTranslated(context, 'facility_list_view')+"(${$facilityTradeReceiveRepository.receiveDetailList.length})",
      backgroundColor: Colors.black,
      textColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, facilityTradeRequestDetailViewRoute, arguments: PageType.Receive),
      //visible: (pageStatus != FacilityPageStatus.None),
    );
  }

  
  Widget buildInvoiceList(){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: $facilityTradeReceiveRepository.invoiceCounterList.length,
      //padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        var item = $facilityTradeReceiveRepository.invoiceCounterList[index];
        return Container(
          padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 6.0),
          //child: Text('${item.invNo} / ${item.count}', style: TextStyle(fontSize:14),)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 8,
                    fit:FlexFit.tight,
                    child: Text('${item.invNo}'),
                  ),
                  Flexible(
                    flex: 2,
                    fit:FlexFit.tight,
                    child: Text('(${item.count})', textAlign: TextAlign.center,),
                  ),
              ],)
          ],),
        );
        // return ListTile(
        //   //contentPadding: EdgeInsets.zero,
        //   title: Text('${item.invNo} / ${item.count}'),
          
        // );
      },
    );
  }

  Widget buildInvoiceListBox(){
    return Container(
      padding: EdgeInsets.all(14),
      height: 145,
      //child: buildInvoiceList(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 6.0),
            child: Text('Invoice Summary', style: TextStyle(fontSize:16, fontWeight: FontWeight.bold),),
          ),
          buildInvoiceList(),
        ],
      ),
    );
  }

  /* EVENT HANDLERS */
  Future newPressed() async {
    //_form2Key.currentState.reset();

    $facilityTradeReceiveRepository.initReceive();
    $facilityTradeReceiveRepository.receiveHeader.recNo = "";
    _recNoController.text = '';
    
    
    setState(() {
      pageStatus = FacilityPageStatus.New;
    });
  }

  Future findPressed(String recNo) async {
    $facilityTradeReceiveRepository.init();

    $facilityTradeCommonRepository.getSearchSetupLocationList();
    
    //String reqNo = _reqNumController.text;
    if(recNo == null || recNo == ''){
      customAlertOK(context,'', getTranslated(context, 'facility_trade_request_number_hint')).show();
      return;
    }
    await pr.show();
    await $facilityTradeReceiveRepository.getFacilityReceiveHeader(recNo)
      .then((rtnValue) {
        pr.hide();
        if(rtnValue){
          $facilityTradeReceiveRepository.getFacilityReceiveDetailList(recNo);
          setState(() {
            pageStatus = FacilityPageStatus.Update;
          });         
        }else{
          $facilityTradeReceiveRepository.initReceive();
          customAlertOK(context,'', getTranslated(context, 'empty_value')).show();
          pageStatus = FacilityPageStatus.New;
          
        }
        return rtnValue;
    });
    await pr.hide();
  }
  
  Future savePressed() async {
    final form = _form2Key.currentState;

    /* 데이터 체크 */
    $facilityTradeReceiveRepository.receiveHeader.receiveDate = $facilityTradeReceiveRepository.receiveHeader.receiveDate??DateTime.now();

    //설비 데이터 체크
    $facilityTradeReceiveRepository
      .receiveDetailList
      .forEach((e) {
        if(e.facilityGrade == null || e.facilityGrade == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'facility_grade')).show();
          return;
        }
        if(e.setupLocationCode == null || e.setupLocationCode == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'asset_info_label_setarea')).show();
          return;
        }
        if(e.plantCode == null || e.plantCode == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'plant')).show();
          return;
        }
        if(e.itemGroup == null || e.itemGroup == '') {
          customAlertOK(context,getTranslated(context, 'error_validation'), "[${e.facilityCode}]" + getTranslated(context, 'item_group')).show();
          return;
        }
      });

    if (form.validate()) {
      //form.save();
      //showResults(context, _ponyModel);
      ResultSaveReceive result= await $facilityTradeReceiveRepository.setFacilityReceive($userRepository.user.empNo);

      if(result.result.toLowerCase() == "okay"){
        customAlertOK(context,getTranslated(context, 'saved'), getTranslated(context, 'save_successfully'))
          .show()
          .then((_){
            if(result.recNo == ""){
              //삭제
              resetPressed();
            }else{
              //신규 및 수정
              findPressed(result.recNo);
            }
          });
      }else if(result.result.toLowerCase() == "exists"){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message_exists')).show();
      }else if(result.recNo == "" || result.result.toLowerCase()!='okay'){
        customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'saving_error_message')).show();
      }else{
        customAlertOK(context,getTranslated(context, 'save_faild'), result.result).show();
        
      }


    } else {
      debugPrint("validate error");
      customAlertOK(context,getTranslated(context, 'save_faild'), getTranslated(context, 'error_validation')).show();
      setState(() => _autoValidate = true);
    }
  }

  void resetPressed() {
    _form2Key.currentState.reset();
    $facilityTradeReceiveRepository.initReceive();
    
    setState(() {
      pageStatus = FacilityPageStatus.None;
    });
  }

}