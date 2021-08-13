class AsstInfo {
  String company;
  // ignore: non_constant_identifier_names
  String company_nm;
  // ignore: non_constant_identifier_names
  String asst_no;
  // ignore: non_constant_identifier_names
  String asst_nm;
  // ignore: non_constant_identifier_names
  String v_asst_nm;
  // ignore: non_constant_identifier_names
  String dept_cd;
  // ignore: non_constant_identifier_names
  String dept_nm;
  // ignore: non_constant_identifier_names
  double acq_loc_amt;
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  // ignore: non_constant_identifier_names
  double res_amt;
  // ignore: non_constant_identifier_names
  DateTime reg_dt;
  String spec;
  // ignore: non_constant_identifier_names
  String acct_cd;
  // ignore: non_constant_identifier_names
  String acct_nm;
  String maker;
  // ignore: non_constant_identifier_names
  String asset_state;
  String setareacode;
  String setarea;
  // ignore: non_constant_identifier_names
  String send_bp_nm;
  // ignore: non_constant_identifier_names
  String project_no;
  // ignore: non_constant_identifier_names
  String cust_bp_nm;
  // ignore: non_constant_identifier_names
  String asset_type;
  // ignore: non_constant_identifier_names
  String tax_flg;
  // ignore: non_constant_identifier_names
  DateTime tex_end_date;
  // ignore: non_constant_identifier_names
  DateTime manufacturing_date;
  // ignore: non_constant_identifier_names
  String serial_no;
  String cpu;
  String ram;
  String hdd;
  String cd;
  String monitor;
  // ignore: non_constant_identifier_names
  String user_cd;
  // ignore: non_constant_identifier_names
  String user_nm;
  // ignore: non_constant_identifier_names
  String mac_add;
  // ignore: non_constant_identifier_names
  String updt_user;
  bool result;

  AsstInfo(
      {this.company,
      // ignore: non_constant_identifier_names
      this.company_nm,
      // ignore: non_constant_identifier_names
      this.asst_no,
      // ignore: non_constant_identifier_names
      this.asst_nm,
      // ignore: non_constant_identifier_names
      this.v_asst_nm,
      // ignore: non_constant_identifier_names
      this.dept_cd,
      // ignore: non_constant_identifier_names
      this.dept_nm,
      // ignore: non_constant_identifier_names
      this.acq_loc_amt,
      // ignore: non_constant_identifier_names
      this.res_amt,
      // ignore: non_constant_identifier_names
      this.reg_dt,
      this.spec,
      // ignore: non_constant_identifier_names
      this.acct_cd,
      // ignore: non_constant_identifier_names
      this.acct_nm,
      this.maker,
      // ignore: non_constant_identifier_names
      this.asset_state,
      this.setareacode,
      this.setarea,
      // ignore: non_constant_identifier_names
      this.send_bp_nm,
      // ignore: non_constant_identifier_names
      this.project_no,
      // ignore: non_constant_identifier_names
      this.cust_bp_nm,
      // ignore: non_constant_identifier_names
      this.asset_type,
      // ignore: non_constant_identifier_names
      this.tax_flg,
      // ignore: non_constant_identifier_names
      this.tex_end_date,
      // ignore: non_constant_identifier_names
      this.manufacturing_date,
      // ignore: non_constant_identifier_names
      this.serial_no,
      this.cpu,
      this.ram,
      this.hdd,
      this.cd,
      this.monitor,
      // ignore: non_constant_identifier_names
      this.user_cd,
      // ignore: non_constant_identifier_names
      this.user_nm,
      // ignore: non_constant_identifier_names
      this.mac_add,
      // ignore: non_constant_identifier_names
      this.updt_user,
      this.result});

  factory AsstInfo.fromJson(Map<String, dynamic> json) {
    return AsstInfo(
        company: json['company'] as String,
        company_nm: json['company_nm'] as String,
        asst_no: json['asst_no'] as String,
        asst_nm: json['asst_nm'] as String,
        v_asst_nm: json['v_asst_nm'] as String,
        dept_cd: json['dept_cd'] as String,
        dept_nm: json['dept_nm'] as String,
        acq_loc_amt: json['acq_loc_amt'] as double,
        res_amt: json['res_amt'] as double,
        reg_dt: DateTime.tryParse(json['reg_dt'].toString()),
        spec: json['spec'] as String,
        acct_cd: json['acct_cd'] as String,
        acct_nm: json['acct_nm'] as String,
        maker: json['maker'] as String,
        asset_state: json['asset_state'] as String,
        setareacode: json['setareacode'] as String,
        setarea: json['setarea'] as String,
        send_bp_nm: json['send_bp_nm'] as String,
        project_no: json['project_no'] as String,
        cust_bp_nm: json['cust_bp_nm'] as String,
        asset_type: json['asset_type'] as String,
        tax_flg: json['tax_flg'] as String,
        tex_end_date: DateTime.tryParse(json['tex_end_date'].toString()),
        manufacturing_date:
            DateTime.tryParse(json['manufacturing_date'].toString()),
        serial_no: json['serial_no'] as String,
        cpu: json['cpu'] as String,
        ram: json['ram'] as String,
        hdd: json['hdd'] as String,
        cd: json['cd'] as String,
        monitor: json['monitor'] as String,
        user_cd: json['user_cd'] as String,
        user_nm: json['user_nm'] as String,
        mac_add: json['mac_add'] as String,
        result: json['result'] = false);
  }
  Map<String, dynamic> toJson() => {
        'company': company,
        'asst_no': asst_no,
        'spec': spec,
        'maker': maker,
        'setareacode': setareacode,
        'setarea': setarea,
        'manufacturing_date': manufacturing_date.toString(),
        'serial_no': serial_no,
        'cpu': cpu,
        'ram': ram,
        'hdd': hdd,
        'cd': cd,
        'monitor': monitor,
        'user_cd': user_cd,
        'mac_add': mac_add,
        'updt_user': updt_user
      };

  Map<String, dynamic> toMap() => {
        'company': company,
        'asst_no': asst_no,
        'spec': spec,
        'maker': maker,
        'setareacode': setareacode,
        'setarea': setarea,
        'manufacturing_date': manufacturing_date.toString(),
        'serial_no': serial_no,
        'cpu': cpu,
        'ram': ram,
        'hdd': hdd,
        'cd': cd,
        'monitor': monitor,
        'user_cd': user_cd,
        'mac_add': mac_add,
        'updt_user': updt_user
      };
}
