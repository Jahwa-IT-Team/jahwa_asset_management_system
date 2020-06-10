

enum PageType { Request, Send, Receive}
enum FacilityPageStatus { None, New, Update}

class CodeName{
  String code;
  String name;

  CodeName({this.code, this.name});

  factory CodeName.fromJson(Map<String,dynamic> json){
    return CodeName(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}

class SetupLocation{
  /*
   {
    "entCode": "KO532",
    "entName": "자화전자주식회사",
    "setupLocation": [
      {
        "code": "KO101Z",
        "name": "[KO101] Jahwa HQ ETC"
      }
    ]
  }
  */
  String entCode;
  String entName;
  List<CodeName> setupLocation;


  SetupLocation({this.entCode, this.entName, this.setupLocation});

  factory SetupLocation.fromJson(Map<String, dynamic> json){
    return SetupLocation(
      entCode: json['entCode'] as String,
      entName: json['entName'] as String,
      setupLocation: (json['setupLocation'] as Iterable).map((e)=>CodeName.fromJson(e)).toList(),
    );
  }
}

class ItemGroup{
  /*
  {
    "item_group_cd": "1119G",
    "item_group_nm": "0219",
    "upper_item_group_cd": "1119",
    "leaf_flg": "Y",
    "del_flg": "N"
  },
  */
  String itemGroupCode;
  String itemGroupName;
  
  ItemGroup({this.itemGroupCode, this.itemGroupName});

  factory ItemGroup.fromJson(Map<String, dynamic> json){
    return ItemGroup(
      itemGroupCode: json['item_group_cd'] as String,
      itemGroupName: json['item_group_nm'] as String,
    );
  }
}

class BizPartner{
  /*
  {
    "bp_cd": "100001",
    "bp_nm": "삼성전자(주)영상"
  },
   */
  String bpCode;
  String bpName;
  BizPartner({this.bpCode, this.bpName});

  factory BizPartner.fromJson(Map<String, dynamic> json){
    return BizPartner(
      bpCode: json['bp_cd'] as String,
      bpName: json['bp_nm'] as String,
    );
  }

}

class Plant{
  /*
    "code": "11",
    "name": "PCM"
   */
  String code;
  String name;

  Plant({this.code, this.name});

  factory Plant.fromJson(Map<String,dynamic> json){
    return Plant(name: json['name'] as String, code: json['code'] as String);
  }
}

class Manager{
  /*
  manager
    "entCode": "KO532",
    "empCode": "K21203005",
    "name": "김태원",
    "deptCode": "KO532_3223000",
    "deptName": "IT운영팀",
    "rollPstn": "대리",
    "role": "팀원",
    "email": "twkim@jahwa.co.kr"
  */
  String entCode;
  String empCode;
  String name;
  String deptCode;
  String detpName;
  String rollPstn;
  String role;
  String email;
  
  Manager({this.entCode, this.empCode, this.name, this.deptCode, this.detpName, this.rollPstn, this.role, this.email});
  factory Manager.fromJson(Map<String, dynamic> json){
    return Manager(
      entCode: json['entCode'] as String,
      empCode: json['empCode'] as String,
      name: json['name'] as String,
      deptCode: json['deptCode'] as String,
      detpName: json['detpName'] as String,
      rollPstn: json['rollPstn'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
    );
  }
}

class RFIDRegInfo{
  String facilityCode;
  String facilityName;
  String rfid; 
  String assetCode;

  RFIDRegInfo({this.facilityCode, this.facilityName, this.rfid, this.assetCode});

  factory RFIDRegInfo.fromJson(Map<String, dynamic> json){
    return RFIDRegInfo(
      facilityCode: json['facilityCode'] as String,
      facilityName: json['facilityName'] as String,
      rfid: json['rfid'] as String,
      assetCode: json['assetCode'] as String,
    );
  }
}

class InvoiceCounter{
  String invNo;
  int count;

  InvoiceCounter({this.invNo, this.count});
}


class RequestHeader{
  String reqNo;
  String reqDiv;
  String entCode;
  String empCode;
  String name;
  DateTime returnDate; 
  String comment;

  RequestHeader({this.reqNo, this.reqDiv, this.entCode, this.empCode, this.name, this.returnDate, this.comment});

  factory RequestHeader.fromJson(Map<String, dynamic> json) {
    return RequestHeader(
      reqNo:json['reqNo'] as String,
      reqDiv: json['reqDiv'] as String,
      entCode: json['entCode'] as String,
      empCode: json['empCode'] as String,
      name:json['name'] as String,
      returnDate: DateTime.parse(json['returnDate'] as String),
      comment:json['comment'] as String
     
    );
  }
}

class RequestDetail{
  String reqNo;
  String facilityCode;
  String facilityName;
  String rfid;
  String facilityGrade;
  String assetCode;
  String facilitySpec;
  String plantCode;
  String plantName;
  String itemGroup;
  

  RequestDetail({this.reqNo, this.facilityCode, this.facilityName, this.rfid, this.facilityGrade, this.assetCode, this.facilitySpec, this.itemGroup, this.plantCode, this.plantName});
  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    return RequestDetail(
      reqNo: json['reqNo'] as String,
      facilityCode: json['facilityCode'] as String,
      facilityName: json['facilityName'] as String,
      rfid: json['rfid'] as String,
      facilityGrade: json['facilityGrade'] as String,
      assetCode: json['assetCode'] as String,
      facilitySpec: json['facilitySpec'] as String,
      plantCode: json['plantCode'] as String,
      plantName: json['plantName'] as String,
      itemGroup: json['itemGroup'] as String,
    );
  }
}

class ResultSaveRequest{
  String result;
  String reqNo;

  ResultSaveRequest({this.result, this.reqNo});

  factory ResultSaveRequest.fromJson(Map<String, dynamic> json){
    return ResultSaveRequest(
      result: json['result'] as String,
      reqNo: json['reqNo'] as String
    );
  }
}


class SendHeader{
  String invNo;
  String sendMethod;
  String sendCustCode;
  String sendCustName;
  DateTime sendDate;
  DateTime forecastDate; 
  String comment;

  SendHeader({this.invNo, this.sendMethod, this.sendCustCode, this.sendCustName, this.sendDate, this.forecastDate, this.comment});

  factory SendHeader.fromJson(Map<String, dynamic> json) {
    return SendHeader(
      invNo:json['invNo'] as String,
      sendMethod: json['sendMethod'] as String,
      sendCustCode: json['sendCustCode'] as String,
      sendCustName: json['sendCustName'] as String,
      sendDate:DateTime.parse(json['sendDate'] as String),
      forecastDate: DateTime.parse(json['forecastDate'] as String),
      comment:json['comment'] as String
     
    );
  }
}

class SendDetail{
  String reqNo;
  String entCode;
  String entName;
  String facilityCode;
  String facilityName;
  String rfid;
  String facilityGrade;
  String assetCode;
  String facilitySpec;
  String plantCode;
  String plantName;
  String itemGroup;
  String manager;
  String managerName;
  

  SendDetail({this.reqNo, this.entCode, this.entName, this.facilityCode, this.facilityName, this.rfid, this.facilityGrade, this.assetCode, this.facilitySpec, this.itemGroup, this.plantCode, this.plantName, this.manager, this.managerName});
  factory SendDetail.fromJson(Map<String, dynamic> json) {
    return SendDetail(
      reqNo: json['reqNo'] as String,
      entCode: json['entCode'] as String,
      entName: json['entName'] as String,
      facilityCode: json['facilityCode'] as String,
      facilityName: json['facilityName'] as String,
      rfid: json['rfid'] as String,
      facilityGrade: json['facilityGrade'] as String,
      assetCode: json['assetCode'] as String,
      facilitySpec: json['facilitySpec'] as String,
      plantCode: json['plantCode'] as String,
      plantName: json['plantName'] as String,
      itemGroup: json['itemGroup'] as String,
      manager: json['manager'] as String,
      managerName: json['managerName'] as String,
    );
  }
}

class ResultSaveSend{
  String result;
  String invNo;

  ResultSaveSend({this.result, this.invNo});

  factory ResultSaveSend.fromJson(Map<String, dynamic> json){
    return ResultSaveSend(
      result: json['result'] as String,
      invNo: json['invNo'] as String
    );
  }
}

class ReceiveHeader{
  /*
  {
    "recNo": "REC20200525001",
    "entCode": "KO532",
    "recInvNo": "",
    "receiveDate": "2020-05-25",
    "receiver": "K21203005",
    "receiverName": "김태원",
    "comment": "test"
  }
   */
  String recNo;
  String entCode;
  String recInvNo;
  DateTime receiveDate;
  String receiver;
  String receiverName;
  String comment;

  ReceiveHeader({this.recNo, this.entCode, this.recInvNo, this.receiveDate, this.receiver, this.receiverName});

  factory ReceiveHeader.fromJson(Map<String,dynamic> json){
    return ReceiveHeader(
      recNo: json['recNo'] as String,
      entCode: json['entCode'] as String,
      recInvNo: json['recInvNo'] as String,
      receiveDate: DateTime.parse(json['receiveDate'] as String),
      receiver: json['receiver'] as String,
      receiverName: json['receiverName'] as String,
    );
  }
}

class ReceiveDetail{
  /*
  {
    "recNo": "REC20200525001",
    "entCode": "KO532",
    "entName": "자화전자주식회사",
    "facilityCode": "JH-2003-0002",
    "invNo": "test1234",
    "recInvNo": "",
    "facilityName": "정량토출 시스템",
    "facilityNameKO": "정량토출 시스템",
    "facilityNameVN": "정량토출 시스템",
    "facilityNameCN": "정량토출 시스템",
    "facilitySpec": "",
    "assetCode": "DZA1948K",
    "facilityGrade": "Good",
    "setupLocation": "[JV101] A CleanRoom (OIS)",
    "setupLocationCode": "JV101A",
    "plantCode": "14",
    "itemGroup": "11",
    "receiveDate": "2020-05-25",
    "manager": "K21203005",
    "managerName": "김태원",
    "reqComment": "test1"
  }
  */
  String recNo;
  String entCode;
  String entName;
  String facilityCode;
  String invNo;
  String recInvNo;
  String facilityName;
  String facilityNameKO;
  String facilityNameVN;
  String facilityNameCN;
  String facilitySpec;
  String assetCode;
  String rfid;
  String facilityGrade;
  String setupLocation;
  String setupLocationCode;
  String plantCode;
  String itemGroup;
  DateTime receiveDate;
  String manager;
  String managerName;
  String reqComment;

  ReceiveDetail({ this.recNo,this.entCode, this.entName, this.facilityCode, this.invNo, this.recInvNo, this.facilityName, this.facilityNameKO, this.facilityNameVN,
    this.facilityNameCN, this.facilitySpec, this.assetCode, this.rfid, this.facilityGrade, this.setupLocation, this.setupLocationCode, this.plantCode, this.itemGroup, this.receiveDate, this.manager, this.managerName, this.reqComment});

  factory ReceiveDetail.fromJson(Map<String, dynamic> json){
    return ReceiveDetail(
      recNo: json['recNo'] as String,
      entCode: json['entCode'] as String,
      entName: json['entName'] as String,
      facilityCode: json['facilityCode'] as String,
      invNo: json['invNo'] as String,
      recInvNo: json['recInvNo'] as String,
      facilityName: json['facilityName'] as String,
      facilityNameKO: json['facilityNameKO'] as String,
      facilityNameVN: json['facilityNameVN'] as String,
      facilityNameCN: json['facilityNameCN'] as String,
      facilitySpec: json['facilitySpec'] as String,
      assetCode: json['assetCode'] as String,
      rfid:json['rfid'] as String,
      facilityGrade: json['facilityGrade'] as String,
      setupLocation: json['setupLocation'] as String,
      setupLocationCode: json['setupLocationCode'] as String,
      plantCode: json['plantCode'] as String,
      itemGroup: json['itemGroup'] as String,
      // receiveDate: DateTime.parse(json['receiveDate'] as String),
      manager: json['manager'] as String,
      managerName: json['managerName'] as String,
      reqComment:json['reqComment'] as String,

    );
  }
}

class ResultSaveReceive{
  /*
    {
    "result": "string",
    "recNo": "string"
  }
  */
  String result;
  String recNo;

  ResultSaveReceive({this.result, this.recNo});

  factory ResultSaveReceive.fromJson(Map<String, dynamic> json){
    return ResultSaveReceive(
      result: json['result'] as String,
      recNo: json['recNo'] as String,
    );
  }

}