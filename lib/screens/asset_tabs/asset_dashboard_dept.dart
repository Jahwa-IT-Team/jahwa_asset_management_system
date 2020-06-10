
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_dashboard_dept_detail.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:jahwa_asset_management_system/routes.dart';
//import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class AssetDashbaordDeptPage extends StatefulWidget{
  final String masterId;

  AssetDashbaordDeptPage({Key key, @required this.masterId}) : super(key: key);

  @override
  _AssetDashbaordDeptPageState createState() => _AssetDashbaordDeptPageState();

}

class _AssetDashbaordDeptPageState extends State<AssetDashbaordDeptPage>{
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
        title: new Text(getTranslated(context, 'asset_dashboard_dept_title')), 
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
                child: getListView(),
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
        if (item['dept_nm'] != null && item['dept_nm'].toString().toLowerCase().indexOf(query.toLowerCase()) > -1) {
            globalSearchJsonData.add(item);
          }
      }

    });

  }

  Future getInspectionMasterStatusByDept() async { 
    if(!asyncData){
      String url = 'https://japi.jahwa.co.kr/api/InspectionMaster/StatusByDept/'+widget.masterId;
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
          //print('snapshot.data.length : ${snapshot.data.length}');
          if(snapshot.data.length > 0){
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                //String id = snapshot.data[index]['id'].toString();
                String company = snapshot.data[index]['company'].toString();
                String deptCode = snapshot.data[index]['dept_cd'].toString();
                String deptName = snapshot.data[index]['dept_nm'].toString();
                int totalCount = snapshot.data[index]['total_count'] == null ? 0 : snapshot.data[index]['total_count'] ;
                int completedCount = snapshot.data[index]['completed_count'] == null ? 0 : snapshot.data[index]['completed_count'];

                double value = completedCount/totalCount;
                if(value < 0){
                  value = 0;
                }else if(value > 1){
                  value = 1;
                }
                String percent = (value*100).toInt().toString() + '%';

                return new GestureDetector(
                  onTap: ()=> Navigator.pushNamed(context, assetDashboardDeptDetailRoute, arguments: AssetDashbaordDeptDetailArguments(widget.masterId, deptCode)),
                  child: Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.green[400]),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                        
                        title: Text(
                          "["+company+"] "+deptName,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                        subtitle: Column(
                          children: <Widget>[
                            SizedBox(height: 10,),
                            LinearPercentIndicator(
                              //width: 100.0,
                              animation: true,
                              lineHeight: 15.0,
                              percent: value,
                              //animationDuration: 1000,
                              center: Text(percent, style: TextStyle(color: Colors.white,fontSize: 12, fontWeight: FontWeight.bold),),
                              progressColor: Colors.blue,
                            ),
                            SizedBox(height: 10,),
                            Text('$completedCount / $totalCount', style: TextStyle(color: Colors.white,fontSize: 12, fontWeight: FontWeight.bold),),
                          ],
                        ),
                        trailing:
                            Icon(Icons.dashboard, color: Colors.white, size: 30.0)
                      ),
                    ),
                  ),
                );
              },
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


