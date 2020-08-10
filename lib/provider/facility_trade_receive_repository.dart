
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import "package:jahwa_asset_management_system/models/facility_trade.dart";
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';


class FacilityTradeReceiveRepository with ChangeNotifier {

  int _detailListCount = 0;
  ReceiveHeader _receiveHeader;// = new ReceiveHeader();
  List<ReceiveDetail> _receiveDetailList = [];
  List<ReceiveDetail> _receiveScanRFIDDetailList = [];
  List<InvoiceCounter> _invoiceCounterList = [];

  ReceiveHeader get receiveHeader => _receiveHeader;
  List<ReceiveDetail> get receiveDetailList =>_receiveDetailList;
  List<ReceiveDetail> get receiveScanRFIDDetailList => _receiveScanRFIDDetailList;
  List<InvoiceCounter> get invoiceCounterList => _invoiceCounterList;

  int get receiveDetailCount => _detailListCount;

  //초기화
  Future<void> init() async{
    _receiveHeader = ReceiveHeader();
    _receiveDetailList = [];
    debugPrint("Provider init()");
  }

  //수취 초기화
  Future<void> initReceive() async{
    _detailListCount = 0;
    _receiveHeader = ReceiveHeader();
    _receiveDetailList = [];
    _receiveScanRFIDDetailList = [];

    notifyListeners();
  }

  //수취 헤더 변경 이벤트
  Future<void> _onReceiveHeaderChanged(ReceiveHeader receive) async{
    if(receive == null){
      _receiveHeader = ReceiveHeader();
    }else{
      _receiveHeader = receive;
    }
    
    debugPrint("_onReceiveHeaderChanged:${receive.comment}");
    notifyListeners();
  }

  //수취 내역 변경
  Future<void> _onReceiveDetailListChanged(List<ReceiveDetail> receive) async{
    if(receive == null){
      _receiveDetailList = [];
    }else{
      _receiveDetailList = receive;
    }
    _detailListCount = _receiveDetailList.length;
    
    //인보이스별 설비 수량 카운트
    _onChangeInvoiceCounter();

    notifyListeners();
  }

  //Invoice별 설비 수량 카운트
  Future<void> _onChangeInvoiceCounter() async{
    _invoiceCounterList = [];

    _receiveDetailList.forEach((e) { 
      if(_invoiceCounterList.any((c) => c.invNo == e.invNo)){
        int count = _invoiceCounterList.where((c) => c.invNo == e.invNo).first.count;
        _invoiceCounterList.removeWhere((c) => c.invNo == e.invNo);
        _invoiceCounterList.add(new InvoiceCounter(invNo: e.invNo,count: count+1));
      }else{
        _invoiceCounterList.add(new InvoiceCounter(invNo: e.invNo,count: 1));
      }
    });
    notifyListeners();
  }

  //수취 설비 추가
  Future<void> addReceiveDetailList(ReceiveDetail d) async{
    if(!_receiveDetailList.any((item) => item.facilityCode == d.facilityCode))
    {
      _receiveDetailList.add(d);
      notifyListeners();
    }
    
    //인보이스별 설비 수량 카운트
    _onChangeInvoiceCounter();
  }


  //수취 설비 삭제
  Future<void> removeReceiveDetailOne(ReceiveDetail d) async{
    _receiveDetailList.removeWhere((item) => item.facilityCode == d.facilityCode);
    notifyListeners();
  }

  //RFID 스캔 내역 추가
  Future<void> addReceiveScanRFIDDetailList(ReceiveDetail d) async{
    if(!_receiveScanRFIDDetailList.any((item) => item.rfid == d.rfid)){
      _receiveScanRFIDDetailList.add(d);
      notifyListeners();
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      
      getReceiveFacilityList('rfid', d.rfid, langCode).then((e) {
        debugPrint("getReceiveFacilityList('rfid', ${d.rfid},$d,$e");
        if(e != null){
          _receiveScanRFIDDetailList.removeWhere((item) => item.rfid == e.rfid);
          _receiveScanRFIDDetailList.add(e);

          notifyListeners();
        }
      });
    }
  }

  //자산번호 바코드 스캔 내역 추가
  //Return 1: 추가, 0 : 이미 추가됨, -1 : 요청 불가능 자산
  Future<int> addReceiveScanAssetCodeDetailList(ReceiveDetail d) async{
    if(!_receiveDetailList.any((item) => item.assetCode == d.assetCode)){
      //Web Call
      String langCode = await getLanguageCodeWithCountryCode();
      return await getReceiveFacilityList('asset', d.assetCode, langCode).then((d) {
        if(d != null){
          _receiveDetailList.add(d);
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
  Future<void> clearReceiveScanList(bool notify) async{
    _receiveScanRFIDDetailList.clear();
    if(notify){
      notifyListeners();
    }
  }
  /* Web API  */
  //수신 헤더 정보 호출
  Future<bool> getFacilityReceiveHeader(String recNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilityReceiveHeader?recNo=$recNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityRequestHeader : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onReceiveHeaderChanged(ReceiveHeader());
            return false;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            _onReceiveHeaderChanged(ReceiveHeader.fromJson(responseJson[0]));
            return true;
          }else{
            _onReceiveHeaderChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onReceiveHeaderChanged(null);
      return false;
    }
  }

  //수신 번호에 해당하는 설비 호출
  Future<bool> getFacilityReceiveDetailList(String recNo) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetFacilityReceiveDetail?recNo=$recNo';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<bool>((http.Response response) {
          print("Result getFacilityReceiveDetailList : ${response.body}, (${response.statusCode})");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            _onReceiveDetailListChanged(null);
            return false;
          }
          if(response.statusCode == 200){
            Iterable responseJson = jsonDecode(response.body);
            _onReceiveDetailListChanged(responseJson.map((e) => ReceiveDetail.fromJson(e)).toList());
            return true;
          }else{
            _onReceiveDetailListChanged(null);
            return false;
          }
        });
    } catch (e) {
      print(e.toString());
      notifyListeners();
      _onReceiveDetailListChanged(null);
      return false;
    }
  }
  
  //발송 저장
  Future<ResultSaveReceive> setFacilityReceive(String userId) async{
    try{
      /*
      {
        "facility": "string",
        "recNo": "string",
        "entCode": "string",
        "recInvNo": "string",
        "receiver": "string",
        "receiveDate": "string",
        "comment": "string",
        "empCode": "string"
      }

      test1234♬JH-2003-0002♬Good♬JV101A♬[JV101] A CleanRoom (OIS)♬14♬11♪
      */
      String facility="";

      for(int i=0; i<_receiveDetailList.length; i++){
        ReceiveDetail d = _receiveDetailList[i];
        debugPrint("$facility${d.invNo}♬${d.facilityCode}♬${d.facilityGrade}♬${d.setupLocationCode}♬${d.setupLocation}♬${d.plantCode}♬${d.itemGroup}♪");
        facility= "$facility${d.invNo}♬${d.facilityCode}♬${d.facilityGrade}♬${d.setupLocationCode}♬${d.setupLocation}♬${d.plantCode}♬${d.itemGroup}♪";
      }

      var url = 'https://japi.jahwa.co.kr/api/Facility/SaveReceive';
      var data = {
        "facility": facility??"",
        "recNo": _receiveHeader.recNo??"",
        "entCode": _receiveHeader.entCode??"",
        "recInvNo": _receiveHeader.recInvNo??"",
        "receiver": _receiveHeader.receiver??"",
        "receiveDate": _receiveHeader.receiveDate.toString()??"",
        "comment": _receiveHeader.comment??"",
        "empCode": userId??""
      };

      debugPrint(json.encode(data));

      return await http.post(
        Uri.encodeFull(url),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"}
      ).timeout(
        const Duration(seconds: 15)
      ).then<ResultSaveReceive>((http.Response response) {
        if(response.statusCode == 200){
          debugPrint("Result setFacilityRequest($userId) : ${response.body}");
          var responseJson = jsonDecode(response.body);
          return ResultSaveReceive.fromJson(responseJson[0]) ;
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

  //수신 등록 가능한 설비
  Future<ReceiveDetail> getReceiveFacilityList(String searchDiv, String tag, String langCode) async{
    try{
      // SERVER LOGIN API URL
      notifyListeners();
      var url = 'https://japi.jahwa.co.kr/api/Facility/GetRecFacilityList?searchDiv=$searchDiv&searchText=$tag&langCode=$langCode';

      return await http.get(
          Uri.encodeFull(url),
          headers: {"Content-Type": "application/json"}
        ).timeout(
          const Duration(seconds: 15)
        ).then<ReceiveDetail>((http.Response response) {
          print("Result getReceiveFacilityList RFID($tag): ${response.body}, (${response.statusCode}), $url");
          if(response.statusCode != 200 || response.body == null || response.body == '[]'){
            return null;
          }
          if(response.statusCode == 200){
            var responseJson = jsonDecode(response.body);
            return ReceiveDetail.fromJson(responseJson[0]);
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