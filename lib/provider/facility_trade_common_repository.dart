import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/facility_common.dart';
import "package:jahwa_asset_management_system/models/facility_trade.dart";
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

//import 'package:btprotocol/btprotocol.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class FacilityTradeCommonRepository with ChangeNotifier {
  bool firstInit = false;
  DateTime _searchLastTime = DateTime.now();
  List<Manager> _searchManagerList = [];
  List<BizPartner> _searchBizPartnerList = [];
  List<Plant> _searchPlant = [];
  List<ItemGroup> _searchItemGroup = [];
  List<SetupLocation> _searchSetupLocation = [];

  List<Manager> get searchManagerList => _searchManagerList;
  List<BizPartner> get searchBizPartnerList => _searchBizPartnerList;
  List<Plant> get searchPlant => _searchPlant;
  List<ItemGroup> get searchItemGroup => _searchItemGroup;
  List<SetupLocation> get searchSetupLocation => _searchSetupLocation;

  //담당자 Data(검색 팝업용)
  List<DropdownMenuItem> get searchManagerDropdownMenuItem {
    List<DropdownMenuItem> items = [];
    _searchManagerList.forEach((d) {
      items.add(DropdownMenuItem(
        value: d.empCode,
        child: Text(d.name),
      ));
    });

    return items;
  }

  //거래처 Data(검색 팝업용)
  List<DropdownMenuItem> get searchBizPartnerDropdownMenuItem {
    List<DropdownMenuItem> items = [];
    _searchBizPartnerList.forEach((d) {
      items.add(DropdownMenuItem(
        value: d.bpCode,
        child: Text(d.bpName),
      ));
    });

    return items;
  }

  //상태 Picker Data
  List<PickerItem> gradeData = [
    PickerItem(text: Text("Good"), value: "good"),
    PickerItem(text: Text("Bad"), value: "bad"),
  ];

  //공장 Picker Data
  List<PickerItem> get plantData {
    List<PickerItem> items = [];
    _searchPlant.forEach((e) {
      items.add(PickerItem(text: Text("[${e.code}]" + e.name), value: e.code));
    });
    return items;
  }

  //품목그룹 Picker Data
  List<PickerItem> get itemGroupData {
    List<PickerItem> items = [];
    _searchItemGroup.forEach((e) {
      items.add(PickerItem(
          text: Text("[${e.itemGroupCode}] ${e.itemGroupName}"),
          value: e.itemGroupCode));
    });
    return items;
  }

  List<PickerItem> get locEntData {
    List<PickerItem> items = [];
    _searchSetupLocation.forEach((e) {
      items.add(PickerItem(text: Text("${e.entName}"), value: e.entCode));
    });
    return items;
  }

  //설치 장소 Picker Data
  List<PickerItem> getSetupLocationData(String entCode) {
    List<PickerItem> items = [];

    if (_searchSetupLocation.any((e) => e.entCode == entCode)) {
      _searchSetupLocation
          .where((e) => e.entCode == entCode)
          .first
          .setupLocation
          .forEach((e) {
        items.add(PickerItem(text: Text("${e.name}"), value: e.code));
      });
    }
    return items;
  }

  //설치 장소 명칭
  String getSetupLocationName(String entCode, String locationCode) {
    return _searchSetupLocation
        .where((e) => e.entCode == entCode)
        .first
        .setupLocation
        .where((e) => e.code == locationCode)
        .first
        .name;
  }

  String getSetupCompanyName(String entCode) {
    return _searchSetupLocation
        .where((e) => e.entCode == entCode)
        .first
        .entName;
  }

  Future<void> init() async {
    getSearchItemGroupList();
    getSearchPlantList();
    getSearchSetupLocationList();

    firstInit = true;
  }

  //요청 담당자 검색 리스트 변경
  Future<void> _onSearchManagerListChange(List<Manager> manager) async {
    if (manager == null) {
      _searchManagerList = [];
    } else {
      _searchManagerList = manager;
    }
    notifyListeners();
  }

  //요청 담당자 검색 리스트 초기화
  Future<void> clearSearchManagerList(bool notify) async {
    _searchManagerList = [];
    if (notify) {
      notifyListeners();
    }
  }

  //거래처 검색 리스트 변경 이벤트
  Future<void> _onSearchBizPartnerListChange(
      List<BizPartner> bizPartner) async {
    if (bizPartner == null) {
      _searchBizPartnerList = [];
    } else {
      _searchBizPartnerList = bizPartner;
    }
    notifyListeners();
  }

  //거래처 검색 초기화
  Future<void> clearSearchBizPartnerList(bool notify) async {
    _searchBizPartnerList = [];
    if (notify) {
      notifyListeners();
    }
  }

  //공장 검색 리스트 변경 이벤트
  Future<void> _onSearchPlantListChange(List<Plant> plant) async {
    if (plant == null) {
      _searchPlant = [];
    } else {
      _searchPlant = plant;
    }
    notifyListeners();
  }

  //공장 검색 초기화
  Future<void> clearSearchPlantList(bool notify) async {
    _searchPlant = [];
    if (notify) {
      notifyListeners();
    }
  }

  //설치 장소 리스트 변경 이벤트
  Future<void> _onSearchSetupLocationListChange(
      List<SetupLocation> location) async {
    if (location == null) {
      _searchSetupLocation = [];
    } else {
      _searchSetupLocation = location;
    }
    notifyListeners();
  }

  //설치 장소 초기화
  Future<void> clearSearchSetupLocationList(bool notify) async {
    _searchSetupLocation = [];
    if (notify) {
      notifyListeners();
    }
  }

  //품목그룹 검색 리스트 변경 이벤트
  Future<void> _onSearchItemGroupListChange(List<ItemGroup> itemGroup) async {
    if (itemGroup == null) {
      _searchItemGroup = [];
    } else {
      _searchItemGroup = itemGroup;
    }
    notifyListeners();
  }

  //품목그룹 검색 초기화
  Future<void> clearSearchItemGroupList(bool notify) async {
    _searchItemGroup = [];
    if (notify) {
      notifyListeners();
    }
  }

  /* WEB API */

  //담당자 검색
  Future<bool> getSearchUserList(String query) async {
    try {
      DateTime searchTime = DateTime.now();
      // SERVER LOGIN API URL
      //notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Users/UserList?query=$query';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            //print("Result getSearchUserList : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return false;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              //List<Manager> search = [...?_searchManagerList,...?responseJson.map((e) => Manager.fromJson(e)).toList()];
              if (_searchLastTime.isBefore(searchTime)) {
                _onSearchManagerListChange(
                    responseJson.map((e) => Manager.fromJson(e)).toList());
                _searchLastTime = searchTime;
              }

              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  //거래처 검색
  Future<bool> getSearchBizPartnerList(String query) async {
    try {
      DateTime searchTime = DateTime.now();
      // SERVER LOGIN API URL
      //notifyListeners();
      String langCode = await getLanguageCodeWithCountryCode();
      var url =
          'https://japi.jahwa.co.kr/api/Facility/GetBizPartnerList?query=$query&langCode=$langCode';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            //print("Result getSearchUserList : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return false;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              //List<Manager> search = [...?_searchManagerList,...?responseJson.map((e) => Manager.fromJson(e)).toList()];
              if (_searchLastTime.isBefore(searchTime)) {
                _onSearchBizPartnerListChange(
                    responseJson.map((e) => BizPartner.fromJson(e)).toList());
                _searchLastTime = searchTime;
              }

              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  //공장 검색
  Future<bool> getSearchPlantList() async {
    try {
      //DateTime searchTime = DateTime.now();
      // SERVER LOGIN API URL
      //notifyListeners();
      var url =
          'https://japi.jahwa.co.kr/api/Facility/GetSelectList?selectDiv=plant';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            //print("Result getSearchUserList : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return false;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              _onSearchPlantListChange(
                  responseJson.map((e) => Plant.fromJson(e)).toList());

              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  //품목그룹 검색
  Future<bool> getSearchItemGroupList() async {
    try {
      //DateTime searchTime = DateTime.now();
      // SERVER LOGIN API URL
      //notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetItemGroup';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            //print("Result getSearchUserList : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return false;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              _onSearchItemGroupListChange(
                  responseJson.map((e) => ItemGroup.fromJson(e)).toList());

              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  //설치장소
  Future<bool> getSearchSetupLocationList() async {
    try {
      //DateTime searchTime = DateTime.now();
      // SERVER LOGIN API URL
      //notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetSetupLocation';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            //print("Result getSearchUserList : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return false;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              _onSearchSetupLocationListChange(
                  responseJson.map((e) => SetupLocation.fromJson(e)).toList());
              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  //RFID 등록 설비 정보 조회
  // searchDiv : code, Asset, rfid
  // tag :
  // langCode
  Future<RFIDRegInfo> getRFIDFacility(String searchDiv, String value) async {
    try {
      // SERVER LOGIN API URL
      String langCode = await getLanguageCodeWithCountryCode();
      notifyListeners();
      var url =
          'https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=$searchDiv&searchText=$value&langCode=$langCode&page=1&pageRowCount=1';

      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<RFIDRegInfo>((http.Response response) {
            print(
                "Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return null;
            }
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body);
              return RFIDRegInfo.fromJson(responseJson[0]);
            } else {
              return null;
            }
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return null;
    }
  }

  //RFID Tag 저장
  Future<bool> setFacilityRFIDTag(
      String facilityCode, String tagData, String userId) async {
    try {
      /*
      {
        "tag": "300000000000000000000000A010",
        "facilityCode": "JH-2003-0002",
        "company": "KO532"
      }
      */

      var url = 'https://japi.jahwa.co.kr/api/Facility/SetRFIDInGW';
      var data = {
        "tag": tagData,
        "facilityCode": facilityCode,
        "company": "",
        "userId": userId,
      };
      return await http
          .post(Uri.encodeFull(url),
              body: json.encode(data),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            return (response.statusCode == 200);
          });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return null;
    }
  }
}
