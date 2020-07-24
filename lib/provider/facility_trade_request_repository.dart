
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import "package:jahwa_asset_management_system/models/facility_trade.dart";
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';


class FacilityTradeRequestRepository with ChangeNotifier {

  int _detailListCount = 0;

  RequestHeader _requestHeader;// = new RequestHeader();
  List<RequestDetail> _requestDetailList = [];
  List<RequestDetail> _requestScanRFIDDetailList = [];
  

  RequestHeader get requestHeader => _requestHeader;
  List<RequestDetail> get requestDetailList =>_requestDetailList;
  List<RequestDetail> get requestScanRFIDDetailList => _requestScanRFIDDetailList;
  
  int get requestDetailCount => _detailListCount;

  //초기화
  Future<void> init() async{
    _requestHeader = new RequestHeader();
    _requestDetailList = [];
    debugPrint("Provider init()");
    //notifyListeners();
  }

  //발송 요청 초기화
  Future<void> initRequest() async{
    _detailListCount = 0;
    _requestHeader = new RequestHeader();
    _requestDetailList = [];
    _requestScanRFIDDetailList = [];
  }

  //발송 요청 헤더 변경 이벤트
  Future<void> _onRequestHeaderChanged(RequestHeader req) async{
    if(req == null){
      _requestHeader = RequestHeader();
    }else{
      _requestHeader = req;
    }
    notifyListeners();
  }

  //발송 요청 내역 변경
  Future<void> _onRequestDetailListChanged(List<RequestDetail> req) async{
    if(req == null){
      _requestDetailList = [];
    }else{
      _requestDetailList = req;
    }

    _detailListCount = _requestDetailList.length;
    notifyListeners();
  }


  //발송 요청 설비 추가
  Future<void> addRequestDetailList(RequestDetail d) async{
    if(!_requestDetailList.any((item) => item.facilityCode == d.facilityCode))
    {
      _requestDetailList.add(d);
      notifyListeners();
    }
  }

  //발송 요청 설비 삭제
  Future<void> removeRequestDetailOne(RequestDetail d) async{
    _requestDetailList.removeWhere((item) => item.facilityCode == d.facilityCode);
    notifyListeners();
  }

  //RFID 스캔 내역 추가
  Future<void> addRequestScanRFIDDetailList(RequestDetail d) async{
    if(!_requestScanRFIDDetailList.any((item) => item.rfid == d.rfid)){
      _requestScanRFIDDetailList.add(d);
      notifyListeners();
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      getReqFacilityList('rfid', d.rfid, langCode).then((d) {
        if(d != null){
          _requestScanRFIDDetailList.removeWhere((item) => item.rfid == d.rfid);
          _requestScanRFIDDetailList.add(d);
          notifyListeners();
        }
      });
    }
  }

  //자산번호 바코드 스캔 내역 추가
  //Return 1: 추가, 0 : 이미 추가됨, -1 : 요청 불가능 자산
  Future<int> addRequestScanAssetCodeDetailList(RequestDetail d) async{
    if(!_requestDetailList.any((item) => item.assetCode == d.assetCode)){
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      return await getReqFacilityList('asset', d.assetCode, langCode).then((d) {
        if(d != null){
          //_requestDetailList.removeWhere((item) => item.assetCode == d.assetCode);
          //_requestScanRFIDDetailList.add(d);
          _requestDetailList.add(d);
          notifyListeners();
          return 1;
        }else{
          return -1;
        }
      });
    }else{
      return 0;
    }
  }
  
  //RFID 스캔 초기화
  Future<void> clearRequestScanList(bool notify) async{
    _requestScanRFIDDetailList.clear();
    if(notify){
      notifyListeners();
    }
  }
  /* Web API  */
  //요청 헤더 정보 호출
  Future<bool> getFacilityRequestHeader(String reqNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilityRequestHeader?reqCode=$reqNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onRequestHeaderChanged(RequestHeader());
            return false;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            _onRequestHeaderChanged(RequestHeader.fromJson(responseJson[0]));
            return true;
          }else{
            _onRequestHeaderChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onRequestHeaderChanged(null);
      return false;
    }
  }

  //요청 번호에 해당하는 설비 호출
  Future<bool> getFacilityRequestDetailList(String reqNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilityRequestDetail?reqCode=$reqNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityRequestDetail : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onRequestDetailListChanged(null);
            return false;
          }
          if(response.statusCode == 200){
            Iterable responseJson = jsonDecode(response.body);
            _onRequestDetailListChanged(responseJson.map((e) => RequestDetail.fromJson(e)).toList());
            return true;
          }else{
            _onRequestDetailListChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onRequestDetailListChanged(null);
      return false;
    }
  }
  
  //요청 저장
  Future<ResultSaveRequest> setFacilityRequest(String userId) async{
    try{
      String facility="";

      for(int i=0; i<_requestDetailList.length; i++){
        RequestDetail d = _requestDetailList[i];
        debugPrint("$facility${d.facilityCode}♬${d.facilityGrade}♬${d.plantCode}♬${d.itemGroup}♪");
        facility= "$facility${d.facilityCode}♬${d.facilityGrade}♬${d.plantCode}♬${d.itemGroup}♪";
      }

      var url = 'https://japi.jahwa.co.kr/api/Facility/SaveRequest';
      var data = {
        "facility": facility??"",
        "reqNo": _requestHeader.reqNo??"",
        "reqDiv": _requestHeader.reqDiv??"",
        "entCode": _requestHeader.entCode??"",
        "manager": _requestHeader.empCode??"",
        "returnDate": _requestHeader.returnDate.toString(),
        "comment": _requestHeader.comment??"",
        "empCode": userId
      };

      debugPrint(json.encode(data));

      return await http.post(
        Uri.encodeFull(url),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"}
      ).timeout(
        const Duration(seconds: 15)
      ).then<ResultSaveRequest>((http.Response response) {
        if(response.statusCode == 200){
          debugPrint("Result setFacilityRequest($userId) : ${response.body}");
          var responseJson = jsonDecode(response.body);
          return ResultSaveRequest.fromJson(responseJson[0]) ;
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

  //요청 가능한 설비
  Future<RequestDetail> getReqFacilityList(String searchDiv, String tag, String langCode) async{
    try{
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetReqFacilityList?searchDiv=$searchDiv&searchText=$tag&langCode=$langCode';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<RequestDetail>((http.Response response) {
          print("Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            return null;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            return RequestDetail.fromJson(responseJson[0]);
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