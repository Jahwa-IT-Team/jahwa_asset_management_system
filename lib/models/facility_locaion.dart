class FacilityInfo{
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
  int sendResult;

  FacilityInfo({this.entCode, this.entName, this.locEntCode, this.locEntName, this.facilityCode, this.facilityName, this.facilityNameCN, this.facilityNameKo, this.facilityNameVN,
    this.facilitySpec, this.serialNo, this.facilityGrade, this.assetCode, this.plantCode, this.plantName, this.itemGroup, this.manager, this.managerName, this.setupLocation, this.setupLocationCode,
    this.rfid, this.sendResult
  });

  factory FacilityInfo.fromJson(Map<String,dynamic> json){
    return FacilityInfo(
      entCode: json['entCode'] as String,
      entName: json['entName'] as String,
      locEntCode:json['locEntCode'] as String,
      locEntName:json['locEntName'] as String,
      facilityCode:json['facilityCode'] as String,
      facilityName:json['facilityName'] as String,
      facilityNameCN:json['facilityNameCN'] as String,
      facilityNameKo:json['facilityNameKo'] as String,
      facilityNameVN:json['facilityNameVN'] as String,
      facilitySpec:json['facilitySpec'] as String,
      serialNo:json['serialNo'] as String,
      facilityGrade:json['facilityGrade'] as String,
      assetCode:json['assetCode'] as String,
      plantCode:json['plantCode'] as String,
      plantName:json['plantName'] as String,
      itemGroup:json['itemGroup'] as String,
      manager:json['manager'] as String,
      managerName:json['managerName'] as String,
      setupLocationCode:json['setupLocationCode'] as String,
      setupLocation:json['setupLocation'] as String,
      rfid:json['rfid'] as String,
      sendResult:json['sendResult'] = 0

    );
  }
}

enum SearchResultDisplay { all, filter_only, none }

class SearchCondtion{
  String facilityCode;
  String assetCode;
  String setupLocationCode;
  SearchResultDisplay display=SearchResultDisplay.none;

  SearchCondtion({this.facilityCode, this.assetCode, this.setupLocationCode, this.display});

}

class SettingInspactionLocation{
  String plantCode;
  String plantName;
  String setupLocationCode;
  String setupLocation;
  String itemGroupCode;

  SettingInspactionLocation({this.plantCode,this.plantName, this.setupLocationCode, this.setupLocation, this.itemGroupCode});
}