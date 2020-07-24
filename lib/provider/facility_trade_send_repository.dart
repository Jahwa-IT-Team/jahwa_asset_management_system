
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import "package:jahwa_asset_management_system/models/facility_trade.dart";
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';


class FacilityTradeSendRepository with ChangeNotifier {

  int _detailListCount = 0;
  SendHeader _sendHeader;// = new SendHeader();
  List<SendDetail> _sendDetailList = [];
  List<SendDetail> _sendScanRFIDDetailList = [];

  SendHeader get sendHeader => _sendHeader;
  List<SendDetail> get sendDetailList =>_sendDetailList;
  List<SendDetail> get sendScanRFIDDetailList => _sendScanRFIDDetailList;

  int get sendDetailCount => _detailListCount;

  //초기화
  Future<void> init() async{
    _sendHeader = SendHeader();
    _sendDetailList = [];
    debugPrint("Provider init()");
    //notifyListeners();
  }

  //발송 요청 초기화
  Future<void> initSend() async{
    _detailListCount = 0;
    _sendHeader = new SendHeader();
    _sendDetailList = [];
    _sendScanRFIDDetailList = [];
  }

  //발송 헤더 변경 이벤트
  Future<void> _onSendHeaderChanged(SendHeader send) async{
    if(send == null){
      _sendHeader = SendHeader();
    }else{
      _sendHeader = send;
    }
    
    debugPrint("_onSendHeaderChanged:${send.comment}");
    notifyListeners();
  }

  //발송 내역 변경
  Future<void> _onSendDetailListChanged(List<SendDetail> send) async{
    if(send == null){
      _sendDetailList = [];
    }else{
      _sendDetailList = send;
    }

    _detailListCount = _sendDetailList.length;
    notifyListeners();
  }

  //발송 요청 설비 추가
  Future<void> addSendDetailList(SendDetail d) async{
    if(!_sendDetailList.any((item) => item.facilityCode == d.facilityCode))
    {
      _sendDetailList.add(d);
      notifyListeners();
    }
  }

  //발송 요청 설비 삭제
  Future<void> removeSendDetailOne(SendDetail d) async{
    _sendDetailList.removeWhere((item) => item.facilityCode == d.facilityCode);
    notifyListeners();
  }

  //RFID 스캔 내역 추가
  Future<void> addSendScanRFIDDetailList(SendDetail d) async{
    if(!_sendScanRFIDDetailList.any((item) => item.rfid == d.rfid)){
      _sendScanRFIDDetailList.add(d);
      notifyListeners();
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      getSendFacilityList('rfid', d.rfid, langCode).then((d) {
        if(d != null){
          _sendScanRFIDDetailList.removeWhere((item) => item.rfid == d.rfid);
          _sendScanRFIDDetailList.add(d);
          notifyListeners();
        }
      });
    }
  }

  //자산번호 바코드 스캔 내역 추가
  //Return 1: 추가, 0 : 이미 추가됨, -1 : 요청 불가능 자산
  Future<int> addSendScanAssetCodeDetailList(SendDetail d) async{
    if(!_sendDetailList.any((item) => item.assetCode == d.assetCode)){
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      return await getSendFacilityList('asset', d.assetCode, langCode).then((d) {
        if(d != null){
          _sendDetailList.add(d);
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
  Future<void> clearSendScanList(bool notify) async{
    _sendScanRFIDDetailList.clear();
    if(notify){
      notifyListeners();
    }
  }
  /* Web API  */
  //발송 헤더 정보 호출
  Future<bool> getFacilitySendHeader(String invNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilitySendHeader?InvNo=$invNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onSendHeaderChanged(SendHeader());
            return false;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            _onSendHeaderChanged(SendHeader.fromJson(responseJson[0]));
            return true;
          }else{
            _onSendHeaderChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onSendHeaderChanged(null);
      return false;
    }
  }

  //발송 번호에 해당하는 설비 호출
  Future<bool> getFacilitySendDetailList(String invNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilitySendDetail?InvNo=$invNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityRequestDetail : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onSendDetailListChanged(null);
            return false;
          }
          if(response.statusCode == 200){
            Iterable responseJson = jsonDecode(response.body);
            _onSendDetailListChanged(responseJson.map((e) => SendDetail.fromJson(e)).toList());
            return true;
          }else{
            _onSendDetailListChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onSendDetailListChanged(null);
      return false;
    }
  }
  
  //발송 저장
  Future<ResultSaveSend> setFacilitySend(String userId) async{
    try{
      /*
      "facility": "string",
      "invNo": "string",
      "sendDate": "string",
      "forecastDate": "string",
      "sendMethod": "string",
      "sendCustCode": "string",
      "sendCustName": "string",
      "comment": "string",
      "empCode": "string"

      REQ20200521001♬JH-2003-0002♪
      */
      String facility="";

      for(int i=0; i<_sendDetailList.length; i++){
        SendDetail d = _sendDetailList[i];
        debugPrint("$facility${d.reqNo}♬${d.facilityCode}♪");
        facility= "$facility${d.reqNo}♬${d.facilityCode}♪";
      }

      var url = 'https://japi.jahwa.co.kr/api/Facility/SaveSend';
      var data = {
        "facility": facility??"",
        "invNo": _sendHeader.invNo,
        "sendDate": _sendHeader.sendDate.toString(),
        "forecastDate": _sendHeader.forecastDate.toString(),
        "sendMethod": _sendHeader.sendMethod,
        "sendCustCode": _sendHeader.sendCustCode,
        "sendCustName": _sendHeader.sendCustName,
        "comment": _sendHeader.comment,
        "empCode": userId
      };

      debugPrint(json.encode(data));

      return await http.post(
        Uri.encodeFull(url),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"}
      ).timeout(
        const Duration(seconds: 15)
      ).then<ResultSaveSend>((http.Response response) {
        if(response.statusCode == 200){
          debugPrint("Result setFacilityRequest($userId) : ${response.body}");
          var responseJson = jsonDecode(response.body);
          return ResultSaveSend.fromJson(responseJson[0]) ;
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

  //요청에 등록 가능한 설비
  Future<SendDetail> getSendFacilityList(String searchDiv, String tag, String langCode) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetSendFacilityList?searchDiv=$searchDiv&searchText=$tag&langCode=$langCode';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<SendDetail>((http.Response response) {
          print("Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            return null;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            return SendDetail.fromJson(responseJson[0]);
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