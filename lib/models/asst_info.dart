
class AsstInfo {
  String company;
  String company_nm;
  String asst_no;
  String asst_nm;
  String v_asst_nm;
  String dept_cd;
  String dept_nm;
  double acq_loc_amt;
  String res_amt;
  DateTime reg_dt;
  String spec;
  String acct_cd;
  String acct_nm;
  String maker;
  String asset_state;
  String setareacode;
  String setarea;
  String send_bp_nm;
  String project_no;
  String cust_bp_nm;
  String asset_type;
  String tax_flg;
  DateTime tex_end_date;
  DateTime manufacturing_date;
  String serial_no;
  String cpu;
  String ram;
  String hdd;
  String cd;
  String monitor;
  String user_cd;
  String user_nm;
  String mac_add;
  String updt_user;
  bool result;

  AsstInfo(
      { this.company,
        this.company_nm,
        this.asst_no,
        this.asst_nm,
        this.v_asst_nm,
        this.dept_cd,
        this.dept_nm,
        this.acq_loc_amt,
        this.res_amt,
        this.reg_dt,
        this.spec,
        this.acct_cd,
        this.acct_nm,
        this.maker,
        this.asset_state,
        this.setareacode,
        this.setarea,
        this.send_bp_nm,
        this.project_no,
        this.cust_bp_nm,
        this.asset_type,
        this.tax_flg,
        this.tex_end_date,
        this.manufacturing_date,
        this.serial_no,
        this.cpu,
        this.ram,
        this.hdd,
        this.cd,
        this.monitor,
        this.user_cd,
        this.user_nm,
        this.mac_add,
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
        res_amt: json['res_amt'] as String,
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
        manufacturing_date: DateTime.tryParse(json['manufacturing_date'].toString()),
        serial_no: json['serial_no'] as String,
        cpu: json['cpu'] as String,
        ram: json['ram'] as String,
        hdd: json['hdd'] as String,
        cd: json['cd'] as String,
        monitor: json['monitor'] as String,
        user_cd: json['user_cd'] as String,
        user_nm: json['user_nm'] as String,
        mac_add: json['mac_add'] as String,
        result: json['result'] = false
    );
  }
  Map<String, dynamic> toJson() => {
    'company': company,
    'asst_no':asst_no,
    'spec':spec,
    'maker':maker,
    'setareacode':setareacode,
    'setarea':setarea,
    'manufacturing_date':manufacturing_date.toString(),
    'serial_no':serial_no,
    'cpu':cpu,
    'ram':ram,
    'hdd':hdd,
    'cd':cd,
    'monitor':monitor,
    'user_cd':user_cd,
    'mac_add':mac_add,
    'updt_user':updt_user
  };

  Map<String, dynamic> toMap() => {
    'company': company,
    'asst_no':asst_no,
    'spec':spec,
    'maker':maker,
    'setareacode':setareacode,
    'setarea':setarea,
    'manufacturing_date':manufacturing_date.toString(),
    'serial_no':serial_no,
    'cpu':cpu,
    'ram':ram,
    'hdd':hdd,
    'cd':cd,
    'monitor':monitor,
    'user_cd':user_cd,
    'mac_add':mac_add,
    'updt_user':updt_user
  };
}



