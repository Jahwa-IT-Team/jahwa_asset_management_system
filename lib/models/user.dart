class ConnectionInfo{
  String company;
  
  ConnectionInfo({this.company});
}

class User {
  final String empNo;
  final String name;
  final String engName;
  final String company;
  final String deptCode;
  final String deptName;
  final String emailAddr;
  final String sectName;
  final String wkAreaName;
  final String rollPstnName;
  final String rollName;
  
  User({this.empNo, this.name, this.engName, this.company, this.deptCode, this.deptName, this.emailAddr, this.sectName, this.wkAreaName, this.rollPstnName, this.rollName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      empNo:json['emp_no'] as String,
      name:json['name'] as String,
      engName: json['eng_name'] as String,
      company: json['company'] as String,
      deptCode: json['dept_cd'] as String,
      deptName: json['dept_nm'] as String,
      emailAddr: json['email_addr'] as String,
      sectName: json['sect_name'] as String,
      wkAreaName: json['wk_area_name'] as String,
      rollPstnName: json['roll_pstn_name'] as String,
      rollName: json['roll_name'] as String,
    );
  }
}

