import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/card_settings_custom_text.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:provider/provider.dart';



class FacilityLocationSearchFilterPage extends StatefulWidget{

  @override
  _FacilityLocationSearchFilterPageState createState() => _FacilityLocationSearchFilterPageState();

}

class _FacilityLocationSearchFilterPageState extends State<FacilityLocationSearchFilterPage>{
  bool _showMaterialonIOS = true;
  
  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();

  UserRepository $userRepository; 
  FacilityLocationRepository $facilityLocationRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  final _facilityCodeController = TextEditingController();
  final _assetCodeController = TextEditingController();
  final GlobalKey<FormState> _facilityCodeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _assetCodeKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){

    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if($facilityTradeCommonRepository == null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    if($facilityLocationRepository == null){
      $facilityLocationRepository = Provider.of<FacilityLocationRepository>(context, listen: true);
      //$facilityLocationRepository.searchCondtion.display = SearchResultDisplay.all;
    }

    _facilityCodeController.text = $facilityLocationRepository.searchCondtion.facilityCode;
    _assetCodeController.text = $facilityLocationRepository.searchCondtion.assetCode;
    
    return Scaffold(
      key:scaffold1Key,
      appBar: AppBar(
        title: Text(getTranslated(context, 'search_condition')),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: searchConditionBox(),),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column()
            ),
            
            //SizedBox(height: 70,),
          ],
        ),
      ),
    
    );
  }


  //조건 박스
  Widget searchConditionBox(){
    return CardSettings.sectioned(
      showMaterialonIOS: _showMaterialonIOS,
      labelWidth: 120,
      children: <CardSettingsSection>[
        CardSettingsSection(
          showMaterialonIOS: _showMaterialonIOS,
          header: CardSettingsHeader(
            label: getTranslated(context, 'search_condition'),
            showMaterialonIOS: _showMaterialonIOS,
            labelAlign: TextAlign.center,
            color: Colors.deepPurple,
          ),
          children: <Widget>[
            buildCardSettingsTextFacilityCode(),
            buildCardSettingsTextAssetCode(),
            buildCardSettingsPickerLocation(),
            buildCardSettingsSelectView(),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildCardSettingsButtonReset(),
                    buildCardSettingsButtonApply(),
                  ],
                )
              ],
            ),
            //testSearch(),
            SizedBox(height: 5,),
            
          ],
        ),
      ]
    );
  }

  CardSettingsCustomText buildCardSettingsTextFacilityCode() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      controller: _facilityCodeController,
      key: _facilityCodeKey,
      label: getTranslated(context, 'facility_code'),
      hintText: getTranslated(context, 'facility_code_hint'),
      initialValue: $facilityLocationRepository.searchCondtion==null?'':$facilityLocationRepository.searchCondtion.facilityCode,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      validator: (value) {
        return null;
      },
      onSaved: (value) => $facilityLocationRepository.searchCondtion.facilityCode = value,
      onChanged: (value) {
        debugPrint("onChanged ReqNo(Provider)");
        debugPrint("onChanged ReqNo(Provider):${$facilityLocationRepository.searchCondtion.facilityCode}");
        $facilityLocationRepository.searchCondtion.facilityCode = value;
      },
    );
  }
  CardSettingsCustomText buildCardSettingsTextAssetCode() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      controller: _assetCodeController,
      key: _assetCodeKey,
      label: getTranslated(context, 'input_asset_no'),
      hintText: getTranslated(context, 'input_asset_no_hint'),
      initialValue: $facilityLocationRepository.searchCondtion==null?'':$facilityLocationRepository.searchCondtion.assetCode,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      validator: (value) {
        return null;
      },
      onSaved: (value) => $facilityLocationRepository.searchCondtion.assetCode = value,
      onChanged: (value) {
        debugPrint("onChanged ReqNo(Provider)");
        debugPrint("onChanged ReqNo(Provider):${$facilityLocationRepository.searchCondtion.assetCode}");
        $facilityLocationRepository.searchCondtion.assetCode = value;
      },
    );
  }

  Widget buildCardSettingsPickerLocation(){
    return customCardField(
      label: getTranslated(context, 'asset_info_label_setarea'),
      content: customDropdown(
        data: $facilityTradeCommonRepository.getSetupLocationData($userRepository.connectionInfo==null?'':$userRepository.connectionInfo.company),
        value: $facilityLocationRepository.searchCondtion==null?'':$facilityLocationRepository.searchCondtion.setupLocationCode,
        onTap: (){
          debugPrint("Grade onTap:");
          Picker(
            adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.getSetupLocationData($userRepository.connectionInfo==null?'':$userRepository.connectionInfo.company)),
            hideHeader: true,
            textAlign: TextAlign.left,
            title: new Text("Please Select"),
            onConfirm: (Picker picker, List value) {
              print(picker.getSelectedValues()[0].toString());
              $facilityLocationRepository.searchCondtion.setupLocationCode = picker.getSelectedValues()[0];
              //$facilityLocationRepository.searchCondtion.setupLocation = $facilityTradeCommonRepository.getSetupLocationName($facilityTradeReceiveRepository.receiveDetailList[index].entCode, picker.getSelectedValues()[0]);
              setState(() {
              });
            }
          ).showDialog(context);
        }
      ),
    );
  }

  Widget buildCardSettingsSelectView(){
    return customCardField(
      label: getTranslated(context, 'search_result_display'),
      content: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'all_display')),
            subtitle: Text(getTranslated(context, 'all_display_desc'),style: TextStyle(color:Colors.red),),
            leading: Radio(
              value: SearchResultDisplay.all,
              groupValue: $facilityLocationRepository.searchCondtion==null?SearchResultDisplay.all:$facilityLocationRepository.searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  $facilityLocationRepository.searchCondtion.display = value;
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'filter_only')),
            leading: Radio(
              value: SearchResultDisplay.filter_only,
              groupValue: $facilityLocationRepository.searchCondtion==null?SearchResultDisplay.all:$facilityLocationRepository.searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  $facilityLocationRepository.searchCondtion.display = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  CardSettingsButton buildCardSettingsButtonReset() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'reset'),
      backgroundColor: Colors.white,
      textColor: Colors.black,
      onPressed: resetPressed,
    );
  }

  CardSettingsButton buildCardSettingsButtonApply() {
    return CardSettingsButton(
      showMaterialonIOS: _showMaterialonIOS,
      label: getTranslated(context, 'apply'),
      backgroundColor: Colors.deepPurple,
      textColor: Colors.white,
      onPressed: applyPressed,
    );
  }

  Future applyPressed() async{
    Navigator.pop(context);
  }

  Future resetPressed() async{
    $facilityLocationRepository.resetSearchCondition(true);
  }

}