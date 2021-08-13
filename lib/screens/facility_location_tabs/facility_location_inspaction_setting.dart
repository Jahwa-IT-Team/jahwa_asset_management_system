import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:provider/provider.dart';

/*
Flutter StatefulWidget Page Example
StatefulWidget Lifecycle

1. createState()
2. mounted == true
3. initState()
4. didChangeDependencies()
*. setState()              - 개발자가 필요에 위해 State
*. didUpdateWidget()       - 부모 위젯이 변경된 경우 State 재구성시에만 호출
5. build()
6. deactivate()
7. dispose()
8. mounted == false

*/

class FacilityLocationInspactionSettingPage extends StatefulWidget {
  //1. createState()
  //StatefulWidget이 빌드 되도록 createState() 호출
  //반드시 호출해야하며 아래 코드보다 더 복잡하거나 추가될 것이 없음
  //정상적으로 createState()호출되면 buildContext가 할당되면서 this.mounted 속성 true를 리턴(2. mounted == true)
  @override
  _FacilityLocationInspactionSettingPageState createState() =>
      new _FacilityLocationInspactionSettingPageState();
}

class _FacilityLocationInspactionSettingPageState
    extends State<FacilityLocationInspactionSettingPage> {
  bool _showMaterialonIOS = true;

  final GlobalKey<ScaffoldState> scaffold1Key = GlobalKey<ScaffoldState>();

  UserRepository $userRepository;
  FacilityLocationRepository $facilityLocationRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  //3. initState()
  //위젯이 생성될때 처음 한번 호출되는 메서드
  //initState에서 실행되면 좋은 것들
  //-.생성된 위젯 인스턴스의 BuildContext에 의존적인 것들의 데이터 초기화
  //-.동일 위젯트리내에 부모위젯에 의존하는 속성 초기화
  //-.Stream 구독, 알림변경, 또는 위젯의 데이터를 변경할 수 있는 다른 객체 핸들링.
  @override
  void initState() {
    //부모 initState() 호출
    super.initState();

    //Future 사용이 필요한 경우
    new Future.delayed(Duration.zero, () {});
    // 스트림 리스너 추가
    //cartItemStream.listen((data) {
    //  _updateWidget(data);
    //});
  }

  //4. didChangeDependencies()
  //메서드는 위젯이 최초 생성될때 initState() 다음에 바로 호출
  //위젯이 의존하는 데이터의 객체가 호출될때마다 호출된다. 예를 들면 업데이트되는 위젯을 상속한 경우.
  //공식문서 또한 상속한 위젯이 업데이트 될때 네트워크 호출(API 호출이 필요한 경우 유용)
  @override
  void didChangeDependencies() {
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
      //$facilityLocationRepository.searchCondtion.display = SearchResultDisplay.all;
    }

    super.didChangeDependencies();
  }

  //*. didUpdateWidget()   --부모 위젯이 변경되어 재구성시에만 호출
  //부모 위젯이 변경되어 이 위젯을 재 구성해야 하는 경우(다음 데이터를 제공 해야하기 때문)
  //이것은 플러터가 오래동안 유지 되는 state를 다시 사용하기 때문이다. 이 경우 initState() 처럼 읿부 데이터를 다시 초기화 해야 한다.
  //build() 메서드가 Stream이나 변경 가능한 데이터에 의존적인경우 이전 객체에서 구독을 취소하고 didUpdateWidget()에서 새로운 인스턴스에 다시 구독 해야함.
  //tip: 이 메서드는 기본적으로 위젯의 상태와 관련된 위젯을 재 구성해야 하는 경우 initState()을 대치한다.
  //플러터는 항상 이 메서드 수행 후(?)에 build()메서드 호출 하므로, setState() 이후 모든 추가 호출은 불필요 하다.
  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   if (oldWidget.importantProperty != widget.importantProperty) {
  //     _init();
  //   }
  // }

  //5. build()
  //이 메서드는 자주 호출된다(fps + render라고 생각하면 됨)
  //반드시 Widget을 리턴해야 함
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold1Key,
      appBar: AppBar(
        title: Text(getTranslated(context, 'setting_location')),
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

  //6. deactivate()
  //이 메서드는 거의 사용되지 않는다.
  //tree에서 State가 제거 될때 호출

  //7. dispose()
  //영구적인 State Object가 삭제될때 호출된다. 이 함수는 주로 Stream 이나 애니메이션 을 해제시 사용된다.
  @override
  void dispose() {
    super.dispose();
  }

  //8. User Defined
  //조건 박스
  Widget searchConditionBox() {
    String sCompany = $userRepository.connectionInfo.company;
    if($facilityLocationRepository.settingInspactionLocation.locEntCode == '' || $facilityLocationRepository.settingInspactionLocation.locEntCode == null) {
      $facilityLocationRepository.settingInspactionLocation.locEntCode = sCompany;
      $facilityLocationRepository.settingInspactionLocation.locEntName = $facilityTradeCommonRepository.getSetupCompanyName(sCompany);
    }
    return CardSettings.sectioned(
        showMaterialonIOS: _showMaterialonIOS,
        labelWidth: 120,
        children: <CardSettingsSection>[
          CardSettingsSection(
            showMaterialonIOS: _showMaterialonIOS,
            // header: CardSettingsHeader(
            //   label: getTranslated(context, 'setting_location'),
            //   showMaterialonIOS: _showMaterialonIOS,
            //   labelAlign: TextAlign.center,
            //   color: Colors.deepPurple,
            // ),
            children: <Widget>[
              buildCardSettingsPickerLocEnt(),
              buildCardSettingsPickerPlant(),
              buildCardSettingsPickerLocation(),
              buildCardSettingsPickerItemGroup(),
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

  Widget buildCardSettingsPickerPlant() {
    return customCardField(
      label: getTranslated(context, 'plant'),
      content: customDropdown(
          data: $facilityTradeCommonRepository.plantData,
          value: $facilityLocationRepository.settingInspactionLocation == null
              ? ''
              : $facilityLocationRepository.settingInspactionLocation.plantCode,
          onTap: () {
            debugPrint("Grade onTap:");
            Picker(
                adapter: PickerDataAdapter(
                    data: $facilityTradeCommonRepository.plantData),
                hideHeader: true,
                title: new Text("Please Select"),
                onConfirm: (Picker picker, List value) {
                  print(picker.getSelectedValues()[0].toString());
                  $facilityLocationRepository.settingInspactionLocation
                      .plantCode = picker.getSelectedValues()[0];
                  Text t =
                      $facilityTradeCommonRepository.plantData[value[0]].text;
                  $facilityLocationRepository
                      .settingInspactionLocation.plantName = t.data;
                  setState(() {});
                }).showDialog(context);
          }),
    );
  }

  Widget buildCardSettingsPickerLocation() {
    return customCardField(
      label: getTranslated(context, 'asset_info_label_setarea'),
      content: customDropdown(
        data: $facilityTradeCommonRepository.getSetupLocationData(
            $facilityLocationRepository.settingInspactionLocation.locEntCode == null
              ? ''
              : $facilityLocationRepository.settingInspactionLocation.locEntCode),
        value: $facilityLocationRepository.settingInspactionLocation == null
          ? ''
          : $facilityLocationRepository
              .settingInspactionLocation.setupLocationCode,
        onTap: () {
          debugPrint("Grade onTap:");
          Picker(
            adapter: PickerDataAdapter(
              data: $facilityTradeCommonRepository.getSetupLocationData(
              $facilityLocationRepository.settingInspactionLocation.locEntCode == null
              ? ''
                  : $facilityLocationRepository.settingInspactionLocation.locEntCode)),
            hideHeader: true,
            textAlign: TextAlign.left,
            title: new Text("Please Select"),
            onConfirm: (Picker picker, List value) {
              print(picker.getSelectedValues()[0].toString());
              $facilityLocationRepository.settingInspactionLocation
                .setupLocationCode = picker.getSelectedValues()[0];
              $facilityLocationRepository
                .settingInspactionLocation.setupLocation =
                  $facilityTradeCommonRepository.getSetupLocationName(
                      $facilityLocationRepository.settingInspactionLocation.locEntCode == null
                      ? ''
                      : $facilityLocationRepository.settingInspactionLocation.locEntCode,
                    picker.getSelectedValues()[0]);
              setState(() {});
            }).showDialog(context);
        }),
    );
  }

  Widget buildCardSettingsPickerItemGroup() {
    return customCardField(
      label: getTranslated(context, 'item_group'),
      content: customDropdown(
          data: $facilityTradeCommonRepository.itemGroupData,
          value: $facilityLocationRepository.settingInspactionLocation == null
              ? ''
              : $facilityLocationRepository
                  .settingInspactionLocation.itemGroupCode,
          onTap: () {
            debugPrint(
                "Grade onTap: item_group${$facilityLocationRepository.settingInspactionLocation.plantCode}");
            Picker(
                adapter: PickerDataAdapter(
                    data: $facilityTradeCommonRepository.itemGroupData
                        .toList()
                        //.where((e) => e.value.toString().length > 2)
                        .where((e) => (e.value
                            .toString()
                            .toLowerCase()
                            .substring(0, 2)
                            .contains($facilityLocationRepository
                                .settingInspactionLocation.plantCode
                                .toLowerCase())))
                        .toList()),
                hideHeader: true,
                title: new Text("Please Select"),
                onConfirm: (Picker picker, List value) {
                  print(picker.getSelectedValues()[0].toString());
                  $facilityLocationRepository.settingInspactionLocation
                      .itemGroupCode = picker.getSelectedValues()[0];
                  setState(() {});
                }).showDialog(context);
          }),
    );
  }


  Widget buildCardSettingsPickerLocEnt() {
    return customCardField(
      label: getTranslated(context, 'company'),
      content: customDropdown(
          data: $facilityTradeCommonRepository.locEntData,
          value: $facilityLocationRepository.settingInspactionLocation == ''
              ? '' : $facilityLocationRepository.settingInspactionLocation.locEntCode,
          onTap: () {
            debugPrint(
                "Grade onTap: Loc_Ent${$facilityLocationRepository.settingInspactionLocation.locEntCode}");
            Picker(
                adapter: PickerDataAdapter(
                    data: $facilityTradeCommonRepository.locEntData
                        .toList()),
                hideHeader: true,
                title: new Text("Please Select"),
                onConfirm: (Picker picker, List value) {
                  print(picker.getSelectedValues()[0].toString());
                  $facilityLocationRepository.settingInspactionLocation
                      .locEntCode = picker.getSelectedValues()[0];
                  $facilityLocationRepository.settingInspactionLocation
                      .locEntName = $facilityTradeCommonRepository.getSetupCompanyName(picker.getSelectedValues()[0]);
                  setState(() {});
                }).showDialog(context);
          }
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
    Navigator.pop(context);
  }

  Future resetPressed() async {
    String sCompany;
    $facilityLocationRepository.resetSettingInspactionLocation(true);
  }
}
