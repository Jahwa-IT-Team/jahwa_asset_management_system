import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/asst_info.dart';

class AsstRepository with ChangeNotifier {
  AsstInfo _asstInfo;
  AsstInfo get asstInfo => _asstInfo;

  var _responseJson;
  dynamic get responseJson => _responseJson;

  Future searchData(String no) async {
    String url = 'https://japi.jahwa.co.kr/api/Assets/' + no;
    http.Response response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    //print(response.body);
    if (response.statusCode != 200 ||
        response.body == null ||
        response.body == '[]') {
      _asstInfo = null;
      //_asstInfo.result = false;
      //notifyListeners();
      return null;
    }

    if (response.statusCode == 200) {
      _responseJson = jsonDecode(response.body);
      _asstInfo = AsstInfo.fromJson(_responseJson[0]);
      _asstInfo.result = true;
      //notifyListeners();
      return _asstInfo;
    }
  }

  Future setDecodeJson(AsstInfo asstInfo) async {
    return jsonEncode(asstInfo.toJson());
  }

  Future getAsstInfo(String propertyName) {
    var _mapRep = _asstInfo.toJson();
    if (_mapRep.containsKey([propertyName])) return _mapRep[propertyName];
    return null;
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
        _asstInfo = AsstInfo.fromJson(_responseJson[0]);
        _asstInfo.result = true;
      } else {
        _asstInfo.result = false;
      }
    } catch (e) {
      debugPrint(e);
      _asstInfo.result = false;
    }

    notifyListeners();
  }

  void setAsstInfo(String propertyName, String propertyValue) {
    if (responseJson[0].containsKey(propertyName)) {
      _responseJson[0][propertyName] = propertyValue;
      switch (propertyName) {
        case 'company':
          _asstInfo.company = propertyValue;
          break;
        case 'company_nm':
          _asstInfo.company_nm = propertyValue;
          break;
        case 'asst_no,':
          _asstInfo.asst_no = propertyValue;
          break;
        case 'asst_nm':
          _asstInfo.asst_nm = propertyValue;
          break;
        case 'v_asst_nm':
          _asstInfo.v_asst_nm = propertyValue;
          break;
        case 'dept_cd':
          _asstInfo.dept_cd = propertyValue;
          break;
        case 'dept_nm':
          _asstInfo.dept_nm = propertyValue;
          break;
        case 'acq_loc_amt':
          _asstInfo.acq_loc_amt = propertyValue as double;
          break;
        case 'res_amt':
          _asstInfo.res_amt = propertyValue as double;
          break;
        case 'reg_dt':
          _asstInfo.reg_dt = DateTime.tryParse(propertyValue.toString());
          break;
        case 'spec':
          _asstInfo.spec = propertyValue;
          break;
        case 'acct_cd':
          _asstInfo.acct_cd = propertyValue;
          break;
        case 'acct_nm':
          _asstInfo.acct_nm = propertyValue;
          break;
        case 'maker':
          _asstInfo.maker = propertyValue;
          break;
        case 'asset_state':
          _asstInfo.asset_state = propertyValue;
          break;
        case 'setareacode':
          _asstInfo.setareacode = propertyValue;
          break;
        case 'setarea':
          _asstInfo.setarea = propertyValue;
          break;
        case 'send_bp_nm':
          _asstInfo.send_bp_nm = propertyValue;
          break;
        case 'project_no':
          _asstInfo.project_no = propertyValue;
          break;
        case 'cust_bp_nm':
          _asstInfo.cust_bp_nm = propertyValue;
          break;
        case 'asset_type':
          _asstInfo.asset_type = propertyValue;
          break;
        case 'tax_flg':
          _asstInfo.tax_flg = propertyValue;
          break;
        case 'tex_end_date':
          _asstInfo.tex_end_date = DateTime.tryParse(propertyValue.toString());
          break;
        case 'manufacturing_date':
          _asstInfo.manufacturing_date = DateTime.tryParse(propertyValue);
          break;
        case 'serial_no':
          _asstInfo.serial_no = propertyValue;
          break;
        case 'cpu':
          _asstInfo.cpu = propertyValue;
          break;
        case 'ram':
          _asstInfo.ram = propertyValue;
          break;
        case 'hdd':
          _asstInfo.hdd = propertyValue;
          break;
        case 'cd':
          _asstInfo.cd = propertyValue;
          break;
        case 'monitor':
          _asstInfo.monitor = propertyValue;
          break;
        case 'user_cd':
          _asstInfo.user_cd = propertyValue;
          break;
        case 'user_nm':
          _asstInfo.user_nm = propertyValue;
          break;
        case 'mac_add':
          _asstInfo.mac_add = propertyValue;
          break;
        default:
          break;
      }
    }
    notifyListeners();
  }
}
