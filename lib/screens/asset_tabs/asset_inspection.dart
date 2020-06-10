import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AssetInspectionPage extends StatefulWidget{

  @override
  _AssetInspectionPageState createState() => _AssetInspectionPageState();

}

class _AssetInspectionPageState extends State<AssetInspectionPage>{
  //final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController textAssetNoController = TextEditingController();
  UserRepository $userRepository; 
  
  @override
  Widget build(BuildContext context){
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    return Container(
      child: getListView($userRepository.connectionInfo.company)
    );
  } 
}


Future getInspectionMasterData(String company) async { 
  String url = 'https://japi.jahwa.co.kr/api/InspectionMaster/company/'+ company;
  //String url = 'https://japi.jahwa.co.kr/api/InspectionMaster';
  http.Response response = await http.get( Uri.encodeFull(url), 
  headers: {"Accept": "application/json"}); 

  return jsonDecode(response.body); 
}

Future getInspectionMasterProgress(String id) async { 
  String url = 'https://japi.jahwa.co.kr/api/InspectionMaster/StatusByMaster/'+id;
  http.Response response = await http.get( Uri.encodeFull(url), 
  headers: {"Accept": "application/json"}); 

  return jsonDecode(response.body); 
}

Widget getLinearProgressIndicator(String id){
  return FutureBuilder(
    future: getInspectionMasterProgress(id),
    builder: (context, snapshot) {
      try{
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData != null){
          int totalCount = snapshot.data[0]['total_count'] == null ? 0 : snapshot.data[0]['total_count'] ;
          int completedCount = snapshot.data[0]['completed_count'] == null ? 0 : snapshot.data[0]['completed_count'];

          double value = completedCount/totalCount;
          String percent = (value*100).toInt().toString() + '%';

          print(value);
          // return LinearProgressIndicator(
          //   value: value ,
          //   //valueColor: ,
          //   //backgroundColor: Colors.blueAccent,
          // );
          return LinearPercentIndicator(
                    //width: 100.0,
                    animation: true,
                    lineHeight: 15.0,
                    percent: value,
                    //animationDuration: 1000,
                    center: Text(percent, style: TextStyle(color: Colors.white,fontSize: 12, fontWeight: FontWeight.bold),),
                    progressColor: Colors.blue,
                  );
        }else{
          //return LinearPercentIndicator(animation: true,lineHeight: 15.0,);
          return LinearProgressIndicator();
        }
      }catch(_){
        return LinearPercentIndicator(animation: true,lineHeight: 15.0,);
      }
      
    },
  );
}

Widget getListView(String company) {
  return FutureBuilder(
    future: getInspectionMasterData(company),
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
              String id = snapshot.data[index]['id'].toString();
              String company = snapshot.data[index]['company'].toString();
              String subject = snapshot.data[index]['subject'].toString();
              String startDate = snapshot.data[index]['startDate'].toString();
              String endDate = snapshot.data[index]['endDate'].toString();
              return new GestureDetector(
                onTap: ()=> Navigator.pushNamed(context, assetInspectionQRScanRoute, arguments: id),
                child: Card(
                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.green[400]),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                      
                      title: Text(
                        "["+company+"] "+subject,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                      subtitle: Column(
                        children: <Widget>[
                          SizedBox(height: 5,),
                          Text(startDate + " ~ " + endDate, style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5,),
                          getLinearProgressIndicator(id),
                        ],
                      ),
                      trailing:
                          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
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

