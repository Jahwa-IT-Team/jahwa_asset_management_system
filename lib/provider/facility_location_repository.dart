
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/facility_locaion.dart';
//import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class FacilityLocationRepository with ChangeNotifier {
  bool firstInit = false;
  SearchCondtion _searchCondtion;
  List<FacilityInfo> _facilityInfoList=[];
  List<FacilityInfo> _facilityChangeList=[];

  SettingInspactionLocation _settingInspactionLocation;

  set searchCondtion(value){
    _searchCondtion = value;
    notifyListeners();
  }
  SearchCondtion get searchCondtion => _searchCondtion;
  SettingInspactionLocation get settingInspactionLocation => _settingInspactionLocation;
  
  List<FacilityInfo> get facilityInfoList => _facilityInfoList;
  List<FacilityInfo> get facilityChangeList => _facilityChangeList;
  List<FacilityInfo> get facilitySearchList {
    if(_searchCondtion.display == SearchResultDisplay.filter_only){
      List<FacilityInfo> result = _facilityInfoList;

      if(_searchCondtion.facilityCode != ''){
        result = result.where((e) => e.facilityCode.toLowerCase().contains(searchCondtion.facilityCode.toLowerCase())).toList();
      }
      
      if(_searchCondtion.assetCode != ''){
        result = result.where((e) => e.assetCode.toLowerCase().contains(searchCondtion.assetCode.toLowerCase())).toList();
      }

      if(_searchCondtion.setupLocationCode != ''){
        result = result.where((e) => e.setupLocationCode.toLowerCase().contains(searchCondtion.setupLocationCode.toLowerCase())).toList();
      }

      return result;
    }
    return _facilityInfoList;
  }

  void init(){
    resetSearchCondition(false);
    resetSettingInspactionLocation(false);
    firstInit = true;
  }

  void resetSearchCondition(bool notify){
    _searchCondtion= new SearchCondtion();

    _searchCondtion.facilityCode = '';
    _searchCondtion.assetCode = '';
    _searchCondtion.display = SearchResultDisplay.none;
    _searchCondtion.setupLocationCode = '';

    if(notify){
      notifyListeners();
    }
  }

  void resetSettingInspactionLocation(bool notify){
    _settingInspactionLocation= new SettingInspactionLocation();

    _settingInspactionLocation.plantCode = '';
    _settingInspactionLocation.plantName = '';
    _settingInspactionLocation.setupLocationCode = '';
    _settingInspactionLocation.setupLocation = '';
    _settingInspactionLocation.itemGroupCode = '';

    if(notify){
      notifyListeners();
    }
  }

  Future<void> addSearchList(FacilityInfo info) async{
    if(info != null && !_facilityInfoList.any((item) => item.facilityCode == info.facilityCode))
    {
      _facilityInfoList.add(info);
      notifyListeners();
    }
  }

  Future<void> removeSearchList(FacilityInfo info) async{
    _facilityInfoList.removeWhere((item) => item.facilityCode == info.facilityCode);
    notifyListeners();
  }

  Future<void> removeAllSearchList() async{
    _facilityInfoList = [];
    notifyListeners();
  }

  Future<void> clearSearchList(bool notify) async{
    _facilityInfoList=[];
    if(notify){
      notifyListeners();
    }
  }

  Future<void> addChangeList(FacilityInfo info) async{
    if(info != null && !_facilityChangeList.any((item) => item.facilityCode == info.facilityCode)){
     _facilityChangeList.add(info);
     notifyListeners();
    }
  }

  Future<void> removeChangeList(FacilityInfo info) async{
    _facilityChangeList.removeWhere((item) => item.facilityCode == info.facilityCode);
    notifyListeners();
  }

  Future<void> removeAllChangeList() async{
    _facilityChangeList = [];
    notifyListeners();
  }

  Future<void> clearChahgeList(bool notify) async{
    _facilityChangeList=[];
    if(notify){
      notifyListeners();
    }
  }


  //설비 조회
  //aearchDiv : rfid, assetno
  Future<FacilityInfo> getReceiveFacilityList(String searchDiv, String searchText, String langCode) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=$searchDiv&searchText=$searchText&langCode=$langCode&page=1&pageRowCount=1';
      //https://japi.jahwa.co.kr/api/Facility/GetFacilitList?searchDiv=asset&searchText=FAB8134K&page=1&pageRowCount=1
      //https://japi.jahwa.co.kr/api/Facility/GetFacilityList?searchDiv=Asset&searchText=FAB8134K&langCode=&page=1&pageRowCount=1
      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<FacilityInfo>((http.Response response) {
          print("Result getFacilityList($searchDiv,$searchText): ${response.body}, (${response.statusCode}), $url");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            return null;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            return FacilityInfo.fromJson(responseJson[0]);
          }else{
            return null;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      return null;
    }
  }
}