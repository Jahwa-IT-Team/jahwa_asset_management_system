import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
//import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';

class FacilityLocationRepository with ChangeNotifier {
  //위치에 해당하는 설비 호출 관련
  String setupLocationCode;
  int _facilityInfoListInLocationPage = 0;
  int _facilityInfoListInLocationTotalCount = 0;

  bool firstInit = false;
  bool lockAllFacilityListInLocation = false;
  SearchCondtion _searchCondtion;

  List<FacilityInfo> _facilityInfoList = [];
  List<FacilityInfo> _facilityInfoListInLocation = [];
  List<FacilityInfo> _facilityChangeList = [];
  List<FacilityInspectionInfo> _facilityInspScanList = [];

  SettingInspactionLocation _settingInspactionLocation;
  UserRepository $userRepository;

  //위치내에 설비 총 수량
  int get facilityInfoListInLocationTotalCount =>
      _facilityInfoListInLocationTotalCount;
  //위치내에 스캔 완료 수량
  int get facilityInfoListInLocationCurrentCount {
    int count = 0;
    _facilityInfoList.forEach((info) {
      if (_facilityInfoListInLocation
          .any((loc) => loc.facilityCode == info.facilityCode)) count++;
    });

    return count;
  }

  //위치내에 API 다운로드 완료 수량
  int get facilityInfoListInLocationDownloadCompleteCount =>
      _facilityInfoListInLocation.length;

  set searchCondtion(value) {
    _searchCondtion = value;
    notifyListeners();
  }

  SearchCondtion get searchCondtion => _searchCondtion;
  SettingInspactionLocation get settingInspactionLocation =>
      _settingInspactionLocation;

  List<FacilityInfo> get facilityInfoList => _facilityInfoList;
  List<FacilityInfo> get facilityChangeList => _facilityChangeList;
  List<FacilityInspectionInfo> get facilityInspScanList =>
      _facilityInspScanList;

  //설비 조회 리스트
  //필터 조건에 해당하는 데이터로 리스트를 재구성해서 보여줌
  List<FacilityInfo> get facilitySearchList {
    List<FacilityInfo> resultFilter = [];
    FacilityInfo more = new FacilityInfo(facilityCode: 'more');

    //전체 표시
    if (_searchCondtion.display == SearchResultDisplay.all) {
      resultFilter = _facilityInfoList;

      return resultFilter;
    }

    //필터 조건만 표시인 경우
    if (_searchCondtion.display == SearchResultDisplay.filter_only) {
      //resultFilter = _facilityInfoList;

      _facilityInfoList.forEach((e) {
        resultFilter.add(e);
      });

      if (_searchCondtion.facilityCode != '') {
        resultFilter = resultFilter
            .where((e) => e.facilityCode
                .toLowerCase()
                .contains(searchCondtion.facilityCode.toLowerCase()))
            .toList();
      }

      if (_searchCondtion.assetCode != '') {
        resultFilter = resultFilter
            .where((e) => e.assetCode
                .toLowerCase()
                .contains(searchCondtion.assetCode.toLowerCase()))
            .toList();
      }

      if (_searchCondtion.setupLocationCode != '') {
        resultFilter = resultFilter
            .where((e) => e.setupLocationCode
                .toLowerCase()
                .contains(searchCondtion.setupLocationCode.toLowerCase()))
            .toList();
      }
      return resultFilter;
    }

    //설치장소 자산 모두 표시
    if (_searchCondtion.display == SearchResultDisplay.location &&
        !_searchCondtion.hideAllDisplayInLocation) {
      //resultFilter = _facilityInfoList;
      _facilityInfoList.forEach((e) {
        resultFilter.add(e);
      });

      _facilityInfoListInLocation.forEach((e) {
        if (!resultFilter.any((r) =>
            r.facilityCode.toUpperCase() == e.facilityCode.toUpperCase())) {
          resultFilter.add(e);
        }
      });

      if (_facilityInfoListInLocation.length <
          _facilityInfoListInLocationTotalCount) {
        resultFilter.add(more);
      }

      return resultFilter;
    }

    //설치장소 자산 모두 표시-Scan 대상 숨김
    if (_searchCondtion.display == SearchResultDisplay.location &&
        _searchCondtion.hideAllDisplayInLocation) {
      resultFilter = [];

      _facilityInfoListInLocation.forEach((e) {
        if (!_facilityInfoList.any((r) =>
            r.facilityCode.toUpperCase() == e.facilityCode.toUpperCase())) {
          resultFilter.add(e);
        }
      });

      if (_facilityInfoListInLocation.length <
          _facilityInfoListInLocationTotalCount) {
        resultFilter.add(more);
      }

      return resultFilter;
    }

    return resultFilter;
  }

  void init() {
    if (!firstInit) {
      resetSearchCondition(false);
      resetSettingInspactionLocation(false);
      firstInit = true;
    }
  }

  void resetSearchCondition(bool notify) {
    _searchCondtion = new SearchCondtion();

    _searchCondtion.facilityCode = '';
    _searchCondtion.assetCode = '';
    _searchCondtion.display = SearchResultDisplay.all;
    _searchCondtion.setupLocationCode = '';
    _searchCondtion.hideAllDisplayInLocation = true;
    _searchCondtion.listViewDisplayType = ListViewDisplayType.card;

    //위치에 해당하는 설비 호출 리셋
    resetLocationInfo();

    //필터링 리스트 초기화

    if (notify) {
      notifyListeners();
    }
  }

  //위치에 해당하는 설비 정보 관련 리셋
  void resetLocationInfo() {
    setupLocationCode = '';
    _facilityInfoListInLocationPage = 0;
    _facilityInfoListInLocationTotalCount = 0;
    lockAllFacilityListInLocation = false;

    _onClearAllFacilityListInLocation();
  }

  void resetSettingInspactionLocation(bool notify) {
    _settingInspactionLocation = new SettingInspactionLocation();

    _settingInspactionLocation.plantCode = '';
    _settingInspactionLocation.plantName = '';
    _settingInspactionLocation.setupLocationCode = '';
    _settingInspactionLocation.setupLocation = '';
    _settingInspactionLocation.itemGroupCode = '';
    _settingInspactionLocation.insertUserName = '';
    _settingInspactionLocation.insertUserId = '';
    _settingInspactionLocation.updateUserId = '';
    _settingInspactionLocation.updateUserName = '';
    _settingInspactionLocation.locEntCode = '';

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> addInfoList(FacilityInfo info) async {
    if (info != null &&
        !_facilityInfoList
            .any((item) => item.facilityCode == info.facilityCode)) {
      info.isScan = true;
      _facilityInfoList.add(info);
      notifyListeners();
    }
  }

  Future<void> removeInfoList(FacilityInfo info) async {
    _facilityInfoList
        .removeWhere((item) => item.facilityCode == info.facilityCode);
    notifyListeners();
  }

  Future<void> removeAllInfoList() async {
    _facilityInfoList = [];
    notifyListeners();
  }

  Future<void> clearSearchInfo(bool notify) async {
    _facilityInfoList = [];
    _facilityInfoListInLocation = [];
    _facilityInfoListInLocationPage = 0;
    _facilityInfoListInLocationTotalCount = 0;
    resetSearchCondition(false);

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _onAddAllFacilityListInLocation(List<FacilityInfo> d) async {
    d.forEach((e) {
      if (!_facilityInfoListInLocation
          .any((f) => f.facilityCode == e.facilityCode)) {
        _facilityInfoListInLocation.add(e);
      }
    });
    notifyListeners();
  }

  void _onClearAllFacilityListInLocation() {
    _facilityInfoListInLocation.clear();
    notifyListeners();
  }

  //설비 재물조사 관련
  //설비 재물조사 스캔 추가
  Future<void> addInspScanList(FacilityInspectionInfo info) async {
    if (info != null &&
        !_facilityInspScanList.any((item) => item.asst_no == info.asst_no)) {
      info.isScan = true;
      _facilityInspScanList.add(info);
      notifyListeners();
    }
  }

  //설비 재물조사 스캔 목록에서 삭제
  Future<void> removeInspScanList(FacilityInspectionInfo info) async {
    _facilityInspScanList.removeWhere((e) => e.asst_no == info.asst_no);
    notifyListeners();
  }

  //설비 재물조사 스캔 리스트 초기화
  Future<void> clearInspScanList(bool notify) async {
    _facilityInspScanList.clear();
    if (notify) {
      notifyListeners();
    }
  }

  //설비 정보 변경 관련
  Future<void> addChangeList(FacilityInfo info) async {
    if (info != null &&
        !_facilityChangeList
            .any((item) => item.facilityCode == info.facilityCode)) {
      _facilityChangeList.add(info);
      notifyListeners();
    }
  }

  Future<void> removeChangeList(FacilityInfo info) async {
    _facilityChangeList
        .removeWhere((item) => item.facilityCode == info.facilityCode);
    notifyListeners();
  }

  Future<void> removeAllChangeList() async {
    _facilityChangeList = [];
    notifyListeners();
  }

  Future<void> clearChahgeList(bool notify) async {
    _facilityChangeList = [];
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> updateChangeListAll(
      String locEntCode,
      String plantCode,
      String itemGroup,
      String setupLocationCode,
      String lang,
      String empCode) async {
    //수정 상태 초기화
    _facilityChangeList.forEach((e) {
      e.sendResult = 0;
    });
    notifyListeners();

    //서버로 수정 사항 적용
    _facilityChangeList.forEach((e) {
      updateChangeListFacilityInfoInLocation(e.facilityCode, e.locEntCode,
          plantCode, itemGroup, setupLocationCode, lang, empCode);
    });
  }

  Future<void> updateChangeFacilityInfoInLocation(
      int index,
      String locEntCode,
      String plantCode,
      String itemGroup,
      String setupLocationCode,
      String lang,
      String empCode) async {
    var e = _facilityChangeList[index];
    updateChangeListFacilityInfoInLocation(e.facilityCode, e.locEntCode,
        plantCode, itemGroup, setupLocationCode, lang, empCode);
  }

  Future<void> updateChangeListFacilityInfoInLocation(
      String facilityCode,
      String locEntCode,
      String plantCode,
      String itemGroup,
      String setupLocationCode,
      String lang,
      String empCode) async {
    try {
      var url = "https://japi.jahwa.co.kr/api/Facility/ChangeFacilityLocation";
      var response = await http.post(
        url,
        body: jsonEncode(
          {
            "facilityCode": facilityCode,
            "locEntCode": locEntCode,
            "plantCode": plantCode,
            "itemGroup": itemGroup,
            "setupLocationCode": setupLocationCode,
            "lang": lang,
            "empCode": empCode
          },
        ),
        headers: {'Content-Type': "application/json"},
      );

      debugPrint(
          'url : $url, response.statusCode : ${response.statusCode}, body:${response.body}');

      if (response.statusCode == 200 && response.body != "[]") {
        var change =
            ResultChageFacilityLocation.fromJson(jsonDecode(response.body));

        if (change.result.result) {
          int index = _facilityChangeList
              .indexWhere((e) => e.facilityCode == facilityCode);
          _facilityChangeList[index] = change.facilityInfo;
          _facilityChangeList[index].sendResult = 1;
        }
      } else {
        _facilityChangeList
            .firstWhere((e) => e.facilityCode == facilityCode)
            .sendResult = -1;
      }
    } catch (e) {
      _facilityChangeList
          .firstWhere((e) => e.facilityCode == facilityCode)
          .sendResult = -1;
    }

    notifyListeners();
  }

  Future<void> getMoreFacilityListInLocation() async {
    int page = _facilityInfoListInLocationPage + 1;
    debugPrint('getMoreFacilityListInLocation Page:$page');
    if (_facilityInfoListInLocation.length <
        _facilityInfoListInLocationTotalCount)
      await getFacilityListInLocation(page: page);
    return;
  }

  Future<void> getAllFacilityListInLocation() async {
    int pageRowCount = 20;
    String searchText = _searchCondtion.setupLocationCode;

    //기존 설치 장소가 다른 경우 초기화
    if (_facilityInfoListInLocation.length > 0) {
      if (_facilityInfoListInLocation[0].setupLocationCode.toLowerCase() !=
          searchText.toLowerCase()) {
        _onClearAllFacilityListInLocation();
        _facilityInfoListInLocationPage = 0;
      }
    }

    //중복 실행 방지
    if (lockAllFacilityListInLocation) return;

    lockAllFacilityListInLocation = true;
    await getFacilityListInLocation(page: 1, pageRowCount: pageRowCount);

    while (_facilityInfoListInLocation.length <
            _facilityInfoListInLocationTotalCount &&
        _searchCondtion.display == SearchResultDisplay.location) {
      await getMoreFacilityListInLocation();
      await new Future.delayed(new Duration(seconds: 1));
    }
    lockAllFacilityListInLocation = false;
  }

  Stream<void> getAllFacilityListInLocationStream() async* {
    while (true) {
      sleep(new Duration(seconds: 1));
    }
  }

  //조회 조건 - 설치장소에 해당하는 설비 호출(한번에 10건씩 호출)
  Future<bool> getFacilityListInLocation(
      {int page = 1, int pageRowCount = 20}) async {
    String searchDiv = 'LocationCode';
    String searchText = _searchCondtion.setupLocationCode;
    String langCode = '';

    //기존 설치 장소가 다른 경우 초기화
    if (_facilityInfoListInLocation.length > 0) {
      if (_facilityInfoListInLocation[0].setupLocationCode.toLowerCase() !=
          searchText.toLowerCase()) {
        _onClearAllFacilityListInLocation();
        page = 1;
        _facilityInfoListInLocationPage = 0;
      }
    }

    //이미 호출한 페이지인 경우 패스~
    if (page <= _facilityInfoListInLocationPage) {
      return true;
    }

    //조회조건 - 설치장소가 없는 경우 패스
    if (searchText == '') {
      return true;
    }

    //조회조건 - 위치에 해당하는 설비 표시가 아닌 경우 패스
    if (searchCondtion.display != SearchResultDisplay.location) {
      return true;
    }

    var url =
        'https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=$searchDiv&searchText=$searchText&langCode=$langCode&page=$page&pageRowCount=$pageRowCount';
    var countUrl =
        'https://japi.jahwa.co.kr/api/Facility/GetFacilitListTotalCount?searchDiv=$searchDiv&searchText=$searchText&langCode=$langCode&page=$page&pageRowCount=$pageRowCount';

    //Total Count
    try {
      _facilityInfoListInLocationTotalCount = await http
          .get(Uri.encodeFull(countUrl),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<int>((http.Response response) {
            debugPrint(countUrl);
            debugPrint(response.body);
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return 0;
            }
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body);
              TotalCount cnt = TotalCount.fromJson(responseJson[0]);
              return cnt.totalCount;
            } else {
              return 0;
            }
          });
    } catch (e) {
      _facilityInfoListInLocationTotalCount = 0;
    }

    //조회 결과
    try {
      return await http.get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          //.timeout(const Duration(seconds: 30))
          .then<bool>((http.Response response) {
        if (response.statusCode != 200 ||
            response.body == null ||
            response.body == '[]') {
          return false;
        }
        if (response.statusCode == 200) {
          Iterable responseJson = jsonDecode(response.body);
          //List<Manager> search = [...?_searchManagerList,...?responseJson.map((e) => Manager.fromJson(e)).toList()];
          _onAddAllFacilityListInLocation(
              responseJson.map((e) => FacilityInfo.fromJson(e)).toList());
          _facilityInfoListInLocationPage = page;
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

  //설비 조회
  //aearchDiv : rfid, assetno
  Future<FacilityInfo> getFacilityList(
      String searchDiv, String searchText, String langCode,
      {int page = 1, int pageRowCount = 1}) async {
    try {
      if (page <= 1) page = 1;
      if (pageRowCount <= 1) pageRowCount = 1;
      // SERVER LOGIN API URL
      notifyListeners();
      var url =
          'https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=$searchDiv&searchText=$searchText&langCode=$langCode&page=$page&pageRowCount=$pageRowCount';
      //https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=asset&searchText=FAB8134K&page=1&pageRowCount=1
      //https://japi.jahwa.co.kr/api/Facility/GetFacilityList?searchDiv=Asset&searchText=FAB8134K&langCode=&page=1&pageRowCount=1
      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<FacilityInfo>((http.Response response) {
            print(
                "Result getFacilityList($searchDiv,$searchText): ${response.body}, (${response.statusCode}), $url");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return null;
            }
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body);
              return FacilityInfo.fromJson(responseJson[0]);
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

  //재물조사 대상의 정보를 가져옵니다.
  Future<FacilityInspectionInfo> getFacilityInspectionInfo(
      int masterId, String div, String code) async {
    try {
      var url =
          'https://japi.jahwa.co.kr/api/Facility/GetFacilityInspDetail?masterID=$masterId&div=$div&code=$code';
      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<FacilityInspectionInfo>((http.Response response) {
            print(
                "Result getFacilityInspectionInfo($masterId,$div,$code): ${response.body}, (${response.statusCode}), $url");
            if (response.statusCode != 200 ||
                response.body == null ||
                response.body == '[]') {
              return null;
            }
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body);
              return FacilityInspectionInfo.fromJson(responseJson[0]);
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

  Future<void> saveFacilityInspAllList() async {
    _facilityInspScanList.forEach((e) {
      if (e.sendResult == 1 || e.id > 0) {
        return;
      } else {
        e.plantCode = settingInspactionLocation.plantCode;
        e.plantName = settingInspactionLocation.plantName;
        e.setarea = settingInspactionLocation.setupLocationCode;
        e.setareaName = settingInspactionLocation.setupLocation;
        e.itemGroup = settingInspactionLocation.itemGroupCode;
        e.locEntCode = settingInspactionLocation.locEntCode;
        e.locEntName = settingInspactionLocation.locEntName;
        saveFacilityInsp(e);
      }
    });
  }

  //재물조사 정보를 저장합니다.
  Future<void> saveFacilityInsp(FacilityInspectionInfo info) async {
    int index =
        _facilityInspScanList.indexWhere((e) => e.asst_no == info.asst_no);

    String json = jsonEncode(info.toJson());
    debugPrint(json);
    try {
      var url = "https://japi.jahwa.co.kr/api/Facility/SaveFacilityInspection";
      var response = await http.post(
        url,
        body: json,
        headers: {'Content-Type': "application/json"},
      );

      debugPrint(
          'url : $url, response.statusCode : ${response.statusCode}, body:${response.body}, info : ${jsonEncode(info)}');

      if (response.statusCode == 200) {
        _facilityInspScanList[index].sendResult = 1;
      } else {
        _facilityInspScanList[index].sendResult = -1;
      }
    } catch (e) {
      debugPrint(e);
      _facilityInspScanList[index].sendResult = -1;
    }

    notifyListeners();
  }
}
