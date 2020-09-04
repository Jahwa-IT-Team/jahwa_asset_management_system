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

class FacilityLocationSearchFilterPage extends StatefulWidget {
  @override
  _FacilityLocationSearchFilterPageState createState() =>
      _FacilityLocationSearchFilterPageState();
}

class _FacilityLocationSearchFilterPageState
    extends State<FacilityLocationSearchFilterPage> {
  bool _showMaterialonIOS = true;

  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();

  UserRepository $userRepository;
  FacilityLocationRepository $facilityLocationRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  final _facilityCodeController = TextEditingController();
  final _assetCodeController = TextEditingController();
  final GlobalKey<FormState> _facilityCodeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _assetCodeKey = GlobalKey<FormState>();

  SearchCondtion searchCondtion;

  @override
  void initState() {
    //부모 initState() 호출
    super.initState();

    searchCondtion = new SearchCondtion(
      assetCode: '',
      facilityCode: '',
      setupLocationCode: '',
      display: SearchResultDisplay.all,
      hideAllDisplayInLocation: true,
      listViewDisplayType: ListViewDisplayType.table,
    );
  }

  @override
  void didChangeDependencies() {
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    $facilityTradeCommonRepository =
        Provider.of<FacilityTradeCommonRepository>(context, listen: true);

    if ($facilityLocationRepository == null) {
      $facilityLocationRepository =
          Provider.of<FacilityLocationRepository>(context, listen: true);
      $facilityLocationRepository.init();

      //조건 세팅
      searchCondtion.facilityCode =
          $facilityLocationRepository.searchCondtion.facilityCode;
      searchCondtion.assetCode =
          $facilityLocationRepository.searchCondtion.assetCode;
      searchCondtion.setupLocationCode =
          $facilityLocationRepository.searchCondtion.setupLocationCode;
      searchCondtion.display =
          $facilityLocationRepository.searchCondtion.display;
      searchCondtion.hideAllDisplayInLocation =
          $facilityLocationRepository.searchCondtion.hideAllDisplayInLocation;
      searchCondtion.listViewDisplayType =
          $facilityLocationRepository.searchCondtion.listViewDisplayType;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    debugPrint('filter page dispose');
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

    if ($facilityLocationRepository == null) {
      $facilityLocationRepository =
          Provider.of<FacilityLocationRepository>(context, listen: true);
      //searchCondtion.display = SearchResultDisplay.all;
    }

    _facilityCodeController.text = searchCondtion.facilityCode;
    _assetCodeController.text = searchCondtion.assetCode;

    return Scaffold(
      key: scaffold1Key,
      appBar: AppBar(
        title: Text(getTranslated(context, 'search_condition')),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: searchConditionBox(),
            ),
            Padding(padding: const EdgeInsets.all(0.0), child: Column()),

            //SizedBox(height: 70,),
          ],
        ),
      ),
    );
  }

  //조건 박스
  Widget searchConditionBox() {
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
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ]);
  }

  CardSettingsCustomText buildCardSettingsTextFacilityCode() {
    return CardSettingsCustomText(
      showMaterialonIOS: _showMaterialonIOS,
      controller: _facilityCodeController,
      key: _facilityCodeKey,
      label: getTranslated(context, 'facility_code'),
      hintText: getTranslated(context, 'facility_code_hint'),
      initialValue: searchCondtion == null ? '' : searchCondtion.facilityCode,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      validator: (value) {
        return null;
      },
      onSaved: (value) => searchCondtion.facilityCode = value,
      onChanged: (value) {
        searchCondtion.facilityCode = value;
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
      initialValue: searchCondtion == null ? '' : searchCondtion.assetCode,
      //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      validator: (value) {
        return null;
      },
      onSaved: (value) => searchCondtion.assetCode = value,
      onChanged: (value) {
        searchCondtion.assetCode = value;
      },
    );
  }

  Widget buildCardSettingsPickerLocation() {
    return customCardField(
      label: getTranslated(context, 'asset_info_label_setarea'),
      content: customDropdown(
          data: $facilityTradeCommonRepository.getSetupLocationData(
              $userRepository.connectionInfo == null
                  ? ''
                  : $userRepository.connectionInfo.company),
          value: searchCondtion == null ? '' : searchCondtion.setupLocationCode,
          onTap: () {
            debugPrint("Grade onTap:");
            Picker(
                adapter: PickerDataAdapter(
                    data: $facilityTradeCommonRepository.getSetupLocationData(
                        $userRepository.connectionInfo == null
                            ? ''
                            : $userRepository.connectionInfo.company)),
                hideHeader: true,
                textAlign: TextAlign.left,
                title: new Text("Please Select"),
                onConfirm: (Picker picker, List value) {
                  print(picker.getSelectedValues()[0].toString());
                  searchCondtion.setupLocationCode =
                      picker.getSelectedValues()[0];
                  setState(() {});
                }).showDialog(context);
          }),
    );
  }

  Widget buildCardSettingsOptionView() {
    return customCardField(
      label: getTranslated(context, 'search_result_display'),
      content: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'all_display')),
            subtitle: Text(
              getTranslated(context, 'all_display_desc'),
              style: TextStyle(color: Colors.red),
            ),
            leading: Radio(
              value: SearchResultDisplay.all,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'filter_only')),
            leading: Radio(
              value: SearchResultDisplay.filter_only,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'all_display_in_location')),
            subtitle: Text(
              getTranslated(context, 'all_display_in_location_desc'),
              style: TextStyle(color: Colors.red),
            ),
            leading: Radio(
              value: SearchResultDisplay.location,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardSettingsSelectView() {
    return customCardField(
      label: getTranslated(context, 'search_result_display'),
      content: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'all_display')),
            subtitle: Text(
              getTranslated(context, 'all_display_desc'),
              style: TextStyle(color: Colors.red),
            ),
            leading: Radio(
              value: SearchResultDisplay.all,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'filter_only')),
            leading: Radio(
              value: SearchResultDisplay.filter_only,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(getTranslated(context, 'all_display_in_location')),
            subtitle: Text(
              getTranslated(context, 'all_display_in_location_desc'),
              style: TextStyle(color: Colors.red),
            ),
            leading: Radio(
              value: SearchResultDisplay.location,
              groupValue: searchCondtion == null
                  ? SearchResultDisplay.all
                  : searchCondtion.display,
              onChanged: (SearchResultDisplay value) {
                setState(() {
                  searchCondtion.display = value;
                });
              },
            ),
          ),
          if (searchCondtion.display == SearchResultDisplay.location)
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(getTranslated(context, 'all_display_in_location1')),
              subtitle: Text(
                getTranslated(context, 'all_display_in_location_desc1'),
                style: TextStyle(color: Colors.red),
              ),
              leading: Checkbox(
                value: searchCondtion.hideAllDisplayInLocation,
                onChanged: (bool value) {
                  setState(() {
                    searchCondtion.hideAllDisplayInLocation = value;
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

  Future applyPressed() async {
    $facilityLocationRepository.searchCondtion = searchCondtion;
    $facilityLocationRepository.getAllFacilityListInLocation();
    Navigator.pop(context);
  }

  Future resetPressed() async {
    $facilityLocationRepository.resetSearchCondition(true);
    //조건 세팅
    searchCondtion.facilityCode =
        $facilityLocationRepository.searchCondtion.facilityCode;
    searchCondtion.assetCode =
        $facilityLocationRepository.searchCondtion.assetCode;
    searchCondtion.setupLocationCode =
        $facilityLocationRepository.searchCondtion.setupLocationCode;
    searchCondtion.display = $facilityLocationRepository.searchCondtion.display;
    searchCondtion.hideAllDisplayInLocation =
        $facilityLocationRepository.searchCondtion.hideAllDisplayInLocation;
    searchCondtion.listViewDisplayType =
        $facilityLocationRepository.searchCondtion.listViewDisplayType;
  }
}
