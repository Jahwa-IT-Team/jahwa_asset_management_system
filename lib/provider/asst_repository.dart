import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/asst_info.dart';


class asstRepository with ChangeNotifier {
  AsstInfo _AsstInfo;
  AsstInfo get asstInfo => _AsstInfo;

  var _responseJson;
  dynamic get responseJson => _responseJson;

  Future searchData(String no) async {
    String url = 'https://japi.jahwa.co.kr/api/Assets/' + no;
    http.Response response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    //print(response.body);
    if (response.statusCode != 200 || response.body == null ||
        response.body == '[]') {
      _AsstInfo.result = false;
      notifyListeners();
      return null;
    }

    if (response.statusCode == 200) {
      _responseJson = jsonDecode(response.body);
      _AsstInfo = AsstInfo.fromJson(_responseJson[0]);
      _AsstInfo.result = true;
      notifyListeners();
      return _AsstInfo;


    }
  }

  Future setDecodeJson(AsstInfo asstInfo) async {
    var Json = jsonEncode(asstInfo.toJson());
    return Json;
  }

  Future getAsstInfo(String propertyName){
    var _mapRep = _AsstInfo.toJson();
    if(_mapRep.containsKey([propertyName]))
      return _mapRep[propertyName];
  }

  Future<void> saveAsstInfo(AsstInfo info) async {

    String json = jsonEncode(info.toJson());
    debugPrint(json);
    try {
      var url = "https://japi.jahwa.co.kr/api/Assets/asstInfoChange";
      var response = await http.post(
        url,
        body: json,
        headers: {'Content-Type': "application/json"},
      );

      debugPrint(
          'url : $url, response.statusCode : ${response.statusCode}, body:${response.body}, info : ${jsonEncode(info)}');

      if (response.statusCode == 200) {
        _responseJson = jsonDecode(response.body);
        _AsstInfo = AsstInfo.fromJson(_responseJson[0]);
        _AsstInfo.result = true;
      } else {
        _AsstInfo.result = false;
      }
    } catch (e) {
      debugPrint(e);
      _AsstInfo.result = false;
    }

    notifyListeners();
  }


  Future setAsstInfo(String propertyName ,String propertyValue){

    if(responseJson[0].containsKey(propertyName)){
      _responseJson[0][propertyName] = propertyValue;
      switch(propertyName){
        case 'company' :
          _AsstInfo.company = propertyValue;
          break;
        case 'company_nm' :
          _AsstInfo.company_nm = propertyValue;
          break;
        case 'asst_no,' :
          _AsstInfo.asst_no = propertyValue;
          break;
        case 'asst_nm':
          _AsstInfo.asst_nm = propertyValue;
          break;
        case 'v_asst_nm':
          _AsstInfo.v_asst_nm = propertyValue;
          break;
        case 'dept_cd':
          _AsstInfo.dept_cd = propertyValue;
          break;
        case 'dept_nm':
          _AsstInfo.dept_nm = propertyValue;
          break;
        case 'acq_loc_amt':
          _AsstInfo.acq_loc_amt = propertyValue as double;
          break;
        case 'res_amt' :
          _AsstInfo.res_amt = propertyValue;
          break;
        case 'reg_dt' :
          _AsstInfo.reg_dt = DateTime.tryParse(propertyValue.toString());
          break;
        case 'spec' :
          _AsstInfo.spec = propertyValue;
          break;
        case 'acct_cd' :
          _AsstInfo.acct_cd = propertyValue;
          break;
        case 'acct_nm' :
          _AsstInfo.acct_nm = propertyValue;
          break;
        case 'maker' :
          _AsstInfo.maker = propertyValue;
          break;
        case 'asset_state' :
          _AsstInfo.asset_state = propertyValue;
          break;
        case 'setareacode' :
          _AsstInfo.setareacode = propertyValue;
          break;
        case 'setarea' :
          _AsstInfo.setarea = propertyValue;
          break;
        case 'send_bp_nm' :
          _AsstInfo.send_bp_nm = propertyValue;
          break;
        case 'project_no' :
          _AsstInfo.project_no = propertyValue;
          break;
        case 'cust_bp_nm' :
          _AsstInfo.cust_bp_nm = propertyValue;
          break;
        case 'asset_type' :
          _AsstInfo.asset_type = propertyValue;
          break;
        case 'tax_flg' :
          _AsstInfo.tax_flg = propertyValue;
          break;
        case 'tex_end_date' :
          _AsstInfo.tex_end_date = DateTime.tryParse(propertyValue.toString());
          break;
        case 'manufacturing_date' :
          _AsstInfo.manufacturing_date = DateTime.tryParse(propertyValue);
          break;
        case 'serial_no' :
          _AsstInfo.serial_no = propertyValue;
          break;
        case 'cpu' :
          _AsstInfo.cpu = propertyValue;
          break;
        case 'ram' :
          _AsstInfo.ram = propertyValue;
          break;
        case 'hdd' :
          _AsstInfo.hdd = propertyValue;
          break;
        case 'cd' :
          _AsstInfo.cd = propertyValue;
          break;
        case 'monitor' :
          _AsstInfo.monitor = propertyValue;
          break;
        case 'user_cd' :
          _AsstInfo.user_cd = propertyValue;
          break;
        case 'user_nm' :
          _AsstInfo.user_nm = propertyValue;
          break;
        case 'mac_add' :
          _AsstInfo.mac_add = propertyValue;
          break;
        default :
            break;

      }
    }
    notifyListeners();
  }
}

