
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

//import 'package:horizontal_data_table/horizontal_data_table.dart';

//import 'package:jahwa_asset_management_system/routes.dart';
//import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class AssetDashbaordDeptDetailArguments{
  final String masterId;
  final String deptCd;

  AssetDashbaordDeptDetailArguments(this.masterId, this.deptCd);
}

class AssetDashbaordDeptDetailPage extends StatefulWidget{
  final AssetDashbaordDeptDetailArguments args;
  

  AssetDashbaordDeptDetailPage({Key key, @required this.args}) : super(key: key);

  @override
  _AssetDashbaordDeptDetailPageState createState() => _AssetDashbaordDeptDetailPageState();

}

class _AssetDashbaordDeptDetailPageState extends State<AssetDashbaordDeptDetailPage>{
  //final GlobalKey<FormState> _key = GlobalKey<FormState>();

  ScanResult scanResult;
  String assetNo;

  dynamic globalData;

  bool asyncData = false;
  List<dynamic> globalSearchJsonData;
  List<dynamic> globalDBJsonData;

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    
  }
  
  @override Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: new AppBar( 
        title: new Text(getTranslated(context, 'asset_dashboard_dept_detail_title')), 
        backgroundColor: Colors.green,
      ),
      body: //getListView(),
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
               child: TextField(

                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  //controller: editingController,
                  decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)))),
                      cursorColor: Colors.green,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(1.0),
                  child:  getListView(),
                ),
              ),
            ],
          ),
        ),
      
    ); 
  }

  void filterSearchResults(String query) {
    setState((){
      globalSearchJsonData.clear();

      for(var item in globalDBJsonData){
        bool filter = false;
        if (item['asst_no'] != null && item['asst_no'].toString().toLowerCase().indexOf(query.toLowerCase()) > -1) {
          filter = true;
        }

        if (item['asst_nm'] != null && item['asst_nm'].toString().toLowerCase().indexOf(query.toLowerCase()) > -1) {
          filter = true;
        }

        if(filter){
          globalSearchJsonData.add(item);
        }
      }
    });

  }

  Future getInspectionMasterStatusByDept() async { 
    if(!asyncData){
      String masterId = widget.args.masterId;
      String deptCd = widget.args.deptCd;

      String url = 'https://japi.jahwa.co.kr/api/InspectionDetail/GetDepartmentByMasterAllList/$masterId/$deptCd';
      //print(url);
      http.Response response = await http.get( Uri.encodeFull(url), 
      headers: {"Accept": "application/json"}); 

      globalDBJsonData = jsonDecode(response.body); 
      globalSearchJsonData = jsonDecode(response.body); 
      asyncData = true;
    }

    return globalSearchJsonData;
  }

  Widget getListView() {
    return FutureBuilder(
      future: getInspectionMasterStatusByDept(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          print('project snapshot data is: ${snapshot.data}');
          return Center(
              child: Text(getTranslated(context, 'empty_value'))  //'자산 정보가 존재하지 않습니다.'
          );
        }else if(snapshot.connectionState == ConnectionState.done && snapshot.hasData != null){
          print('snapshot.data.length : ${snapshot.data.length}');
          if(snapshot.data.length > 0){
            List<DataRow> rows = [];

            for(int i=0; i<snapshot.data.length; i++){
              String sAsstNo = snapshot.data[i]['asst_no'].toString()??'';
              String sAsstNm = snapshot.data[i]['asst_nm'].toString()??'';
              String sInsectionYn = snapshot.data[i]['inspection_yn'].toString()??'';
              double dMediaSize = MediaQuery.of(context).size.width;
              rows.addAll([
                DataRow(
                  cells: [
                    DataCell(
                      Container(
                        color: Colors.pink,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: dMediaSize * 18 / 100,
                            minWidth: 20,
                          ),
                        child: Text(
                          sAsstNo,
                          textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: dMediaSize * 40 / 100,
                          minWidth: 20,
                        ),
                        child: Text(
                          sAsstNm,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        sInsectionYn,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
                ),
              ]);
            }
            return DataTable(
              columns: <DataColumn>[
                DataColumn(label: Text('No'),),
                DataColumn(label: Text('Name'),),
                DataColumn(label: Text('Y/N'),),
              ], 
              rows: rows,
            );
            
          }else{
            return Center(
              child: Text(getTranslated(context, 'empty_value'))  //'자산 정보가 존재하지 않습니다.'
            );
          }
        }else if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator()
          );
        }else{
          return Center();
        }
        
      },
    );
  }


}

