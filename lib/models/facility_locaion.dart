//import 'dart:convert';

class TotalCount {
  int totalCount;

  TotalCount({this.totalCount});
  factory TotalCount.fromJson(Map<String, dynamic> json) {
    return TotalCount(
      totalCount: json['totalCount'] as int,
    );
  }
}

class FacilityInfo {
  String entCode;
  String entName;
  String locEntCode;
  String locEntName;
  String facilityCode;
  String facilityName;
  String facilityNameKo;
  String facilityNameVN;
  String facilityNameCN;
  String facilitySpec;
  String serialNo;
  String facilityGrade;
  String assetCode;
  String plantCode;
  String plantName;
  String itemGroup;
  String manager;
  String managerName;
  String setupLocationCode;
  String setupLocation;
  String rfid;
  int sendResult; //API 보내기 결과 0:기본(대기), 1:보내기 성공, -1 : 보내기 실패
  bool isScan; //설비조회 상태, 0:기본, 1:스캔완료

  FacilityInfo(
      {this.entCode,
      this.entName,
      this.locEntCode,
      this.locEntName,
      this.facilityCode,
      this.facilityName,
      this.facilityNameCN,
      this.facilityNameKo,
      this.facilityNameVN,
      this.facilitySpec,
      this.serialNo,
      this.facilityGrade,
      this.assetCode,
      this.plantCode,
      this.plantName,
      this.itemGroup,
      this.manager,
      this.managerName,
      this.setupLocation,
      this.setupLocationCode,
      this.rfid,
      this.sendResult,
      this.isScan});

  factory FacilityInfo.fromJson(Map<String, dynamic> json) {
    return FacilityInfo(
        entCode: json['entCode'] as String,
        entName: json['entName'] as String,
        locEntCode: json['locEntCode'] as String,
        locEntName: json['locEntName'] as String,
        facilityCode: json['facilityCode'] as String,
        facilityName: json['facilityName'] as String,
        facilityNameCN: json['facilityNameCN'] as String,
        facilityNameKo: json['facilityNameKo'] as String,
        facilityNameVN: json['facilityNameVN'] as String,
        facilitySpec: json['facilitySpec'] as String,
        serialNo: json['serialNo'] as String,
        facilityGrade: json['facilityGrade'] as String,
        assetCode: json['assetCode'] as String,
        plantCode: json['plantCode'] as String,
        plantName: json['plantName'] as String,
        itemGroup: json['itemGroup'] as String,
        manager: json['manager'] as String,
        managerName: json['managerName'] as String,
        setupLocationCode: json['setupLocationCode'] as String,
        setupLocation: json['setupLocation'] as String,
        rfid: json['rfid'] as String,
        sendResult: json['sendResult'] = 0,
        isScan: json['isScan'] = false);
  }
}

enum SearchResultDisplay { all, filter_only, location, none }
enum ListViewDisplayType { card, table }

class SearchCondtion {
  String facilityCode;
  String assetCode;
  String setupLocationCode;
  SearchResultDisplay display = SearchResultDisplay.none;
  bool hideAllDisplayInLocation = true;
  ListViewDisplayType listViewDisplayType = ListViewDisplayType.card;

  SearchCondtion(
      {this.facilityCode,
      this.assetCode,
      this.setupLocationCode,
      this.display,
      this.hideAllDisplayInLocation,
      this.listViewDisplayType});
}

class SettingInspactionLocation {
  String plantCode;
  String plantName;
  String setupLocationCode;
  String setupLocation;
  String itemGroupCode;
  String insertUserId;
  String insertUserName;
  String updateUserId;
  String updateUserName;

  SettingInspactionLocation(
      {this.plantCode,
      this.plantName,
      this.setupLocationCode,
      this.setupLocation,
      this.itemGroupCode,
      this.insertUserId,
      this.insertUserName,
      this.updateUserId,
      this.updateUserName});
}

class ResultMessage {
  bool result;
  String message;

  ResultMessage({this.result, this.message});

  factory ResultMessage.fromJson(Map<String, dynamic> json) {
    return ResultMessage(
        result: json['result'] as bool, message: json['message'] as String);
  }
}

class ResultChageFacilityLocation {
  ResultMessage result;
  FacilityInfo facilityInfo;

  ResultChageFacilityLocation({this.result, this.facilityInfo});

  factory ResultChageFacilityLocation.fromJson(Map<String, dynamic> json) {
    return ResultChageFacilityLocation(
        result: ResultMessage.fromJson(json['result']),
        facilityInfo: FacilityInfo.fromJson(json['facilityInfo']));
  }
}

class FacilityInspectionInfo {
  int id;
  String company;
  String dept_cd;
  String dept_nm;
  // ignore: non_constant_identifier_names
  String asst_no;
  // ignore: non_constant_identifier_names
  String asst_nm;
  String spec;
  String maker;
  // ignore: non_constant_identifier_names
  String asset_state;
  String setarea;
  String setareaName;
  // ignore: non_constant_identifier_names
  String serial_no;
  // ignore: non_constant_identifier_names
  String user_cd;
  // ignore: non_constant_identifier_names
  String user_nm;
  String plantCode;
  String plantName;
  String itemGroup;
  String insertUserId;
  String insertUserName;
  DateTime insertDate;
  String updateUserId;
  String updateUserName;
  DateTime updateDate;
  // ignore: non_constant_identifier_names
  String before_spec;
  // ignore: non_constant_identifier_names
  String before_maker;
  // ignore: non_constant_identifier_names
  String before_asset_state;
  // ignore: non_constant_identifier_names
  String before_setarea;
  // ignore: non_constant_identifier_names
  String before_serial_no;
  // ignore: non_constant_identifier_names
  String before_user_cd;
  // ignore: non_constant_identifier_names
  String before_user_nm;
  // ignore: non_constant_identifier_names
  String before_PlantCode;
  // ignore: non_constant_identifier_names
  String before_ItemGroup;
  // ignore: non_constant_identifier_names
  bool is_spec;
  // ignore: non_constant_identifier_names
  bool is_maker;
  // ignore: non_constant_identifier_names
  bool is_asset_state;
  // ignore: non_constant_identifier_names
  bool is_setarea;
  // ignore: non_constant_identifier_names
  bool is_serial_no;
  // ignore: non_constant_identifier_names
  bool is_user_cd;
  // ignore: non_constant_identifier_names
  bool is_plantCode;
  // ignore: non_constant_identifier_names
  bool is_itemGroup;

  bool inspFlag;
  int masterId;

  int sendResult; //API 보내기 결과 0:기본(대기), 1:보내기 성공, -1 : 보내기 실패
  bool isScan; //API 조회 상태, 0:기본, 1:스캔완료

  FacilityInspectionInfo(
      {this.id,
      this.company,
      this.dept_cd,
      this.dept_nm,
      // ignore: non_constant_identifier_names
      this.asst_no,
      // ignore: non_constant_identifier_names
      this.asst_nm,
      this.spec,
      this.maker,
      // ignore: non_constant_identifier_names
      this.asset_state,
      this.setarea,
      this.setareaName,
      // ignore: non_constant_identifier_names
      this.serial_no,
      // ignore: non_constant_identifier_names
      this.user_cd,
      // ignore: non_constant_identifier_names
      this.user_nm,
      this.plantCode,
      this.plantName,
      this.itemGroup,
      this.insertUserId,
      this.insertUserName,
      this.insertDate,
      this.updateUserId,
      this.updateUserName,
      this.updateDate,
      // ignore: non_constant_identifier_names
      this.before_spec,
      // ignore: non_constant_identifier_names
      this.before_maker,
      // ignore: non_constant_identifier_names
      this.before_asset_state,
      // ignore: non_constant_identifier_names
      this.before_setarea,
      // ignore: non_constant_identifier_names
      this.before_serial_no,
      // ignore: non_constant_identifier_names
      this.before_user_cd,
      // ignore: non_constant_identifier_names
      this.before_user_nm,
      // ignore: non_constant_identifier_names
      this.before_PlantCode,
      // ignore: non_constant_identifier_names
      this.before_ItemGroup,
      // ignore: non_constant_identifier_names
      this.is_spec,
      // ignore: non_constant_identifier_names
      this.is_maker,
      // ignore: non_constant_identifier_names
      this.is_asset_state,
      // ignore: non_constant_identifier_names
      this.is_setarea,
      // ignore: non_constant_identifier_names
      this.is_serial_no,
      // ignore: non_constant_identifier_names
      this.is_user_cd,
      // ignore: non_constant_identifier_names
      this.is_plantCode,
      // ignore: non_constant_identifier_names
      this.is_itemGroup,
      this.inspFlag,
      this.masterId,
      this.sendResult});

  factory FacilityInspectionInfo.fromJson(Map<String, dynamic> json) {
    return FacilityInspectionInfo(
        id: json['id'] as int,
        company: json['company'] as String,
        dept_cd: json['dept_cd'] as String,
        dept_nm: json['dept_nm'] as String,
        asst_no: json['asst_no'] as String,
        asst_nm: json['asst_nm'] as String,
        spec: json['spec'] as String,
        maker: json['maker'] as String,
        asset_state: json['asset_state'] as String,
        setarea: json['setarea'] as String,
        setareaName: json['setareaName'] as String,
        serial_no: json['serial_no'] as String,
        user_cd: json['user_cd'] as String,
        user_nm: json['user_nm'] as String,
        plantCode: json['plantCode'] as String,
        plantName: json['plantName'] as String,
        itemGroup: json['itemGroup'] as String,
        insertUserId: json['insertUserId'] as String,
        insertUserName: json['insertUserName'] as String,
        insertDate: DateTime.parse(json['insertDate']),
        updateUserId: json['updateUserId'] as String,
        updateUserName: json['updateUserName'] as String,
        updateDate: DateTime.parse(json['updateDate']),
        before_spec: json['before_spec'] as String,
        before_maker: json['before_maker'] as String,
        before_asset_state: json['before_asset_state'] as String,
        before_setarea: json['before_setarea'] as String,
        before_serial_no: json['before_serial_no'] as String,
        before_user_cd: json['before_user_cd'] as String,
        before_user_nm: json['before_user_nm'] as String,
        before_PlantCode: json['before_PlantCode'] as String,
        before_ItemGroup: json['before_ItemGroup'] as String,
        is_spec: json['is_spec'] as bool,
        is_maker: json['is_maker'] as bool,
        is_asset_state: json['is_asset_state'] as bool,
        is_setarea: json['is_setarea'] as bool,
        is_serial_no: json['is_serial_no'] as bool,
        is_user_cd: json['is_user_cd'] as bool,
        is_plantCode: json['is_plantCode'] as bool,
        is_itemGroup: json['is_itemGroup'] as bool,
        inspFlag: json['inspFlag'] as bool,
        masterId: json['masterId'] as int);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'dept_cd':dept_cd,
        'dept_nm':dept_nm,
        'asst_no': asst_no,
        'asst_nm': asst_nm,
        'spec': spec,
        'maker': maker,
        'asset_state': asset_state,
        'setarea': setarea,
        'setareaName': setareaName,
        'serial_no': serial_no,
        'user_cd': user_cd,
        'user_nm': user_nm,
        'plantCode': plantCode,
        'plantName': plantName,
        'itemGroup': itemGroup,
        'insertUserId': insertUserId,
        'insertUserName': insertUserName,
        'insertDate': insertDate.toIso8601String(),
        'updateUserId': updateUserId,
        'updateUserName': updateUserName,
        'updateDate': updateDate.toIso8601String(),
        'before_spec': before_spec,
        'before_maker': before_maker,
        'before_asset_state': before_asset_state,
        'before_setarea': before_setarea,
        'before_serial_no': before_serial_no,
        'before_user_cd': before_user_cd,
        'before_user_nm': before_user_nm,
        'before_PlantCode': before_PlantCode,
        'before_ItemGroup': before_ItemGroup,
        'is_spec': is_spec,
        'is_maker': is_maker,
        'is_asset_state': is_asset_state,
        'is_setarea': is_setarea,
        'is_serial_no': is_serial_no,
        'is_user_cd': is_user_cd,
        'is_plantCode': is_plantCode,
        'is_itemGroup': is_itemGroup,
        'inspFlag': inspFlag,
        'masterId': masterId,
      };
}
