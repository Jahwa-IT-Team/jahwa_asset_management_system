
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