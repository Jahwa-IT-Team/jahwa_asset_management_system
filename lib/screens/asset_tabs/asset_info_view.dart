import 'dart:async'; 
import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;

import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class AssetInfoViewPage extends StatefulWidget{
  final String assetNo;
  AssetInfoViewPage({Key key, @required this.assetNo}) : super(key: key);

  @override
  _AssetInfoViewPageState createState()=>_AssetInfoViewPageState();

}

class _AssetInfoViewPageState extends State<AssetInfoViewPage>{

  @override void initState() { 
    super.initState(); 
  }


  @override Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: new AppBar( 
        title: new Text(widget.assetNo), 
        backgroundColor: Colors.green,
      ), 
      body: getListView(widget.assetNo)
    ); 
  }

}


Future getData(String no) async { 
    String url = 'https://japi.jahwa.co.kr/api/Assets/'+no;
    http.Response response = await http.get( Uri.encodeFull(url), 
    headers: {"Accept": "application/json"}); 
    
    //print(response.body); 

    return jsonDecode(response.body); 
}

Widget getListView(String assetNo) {
  return FutureBuilder(
    future: getData(assetNo),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.none &&
          snapshot.hasData == null) {
        print('project snapshot data is: ${snapshot.data}');
        return Center(
            child: Text(getTranslated(context, 'asset_info_empty_value'))  //'자산 정보가 존재하지 않습니다.'
        );
      }else if(snapshot.connectionState == ConnectionState.done){
        //print('snapshot.data.length : ${snapshot.data.length}');
        if(snapshot.data.length > 0){
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
            ),
            itemCount: snapshot.data.length >= 1? snapshot.data[0].length : 0,
            itemBuilder: (context, index) {
              String jsonKey = snapshot.data[0].keys.elementAt(index);
              String jsonValue = snapshot.data[0][jsonKey]==null ? '' : snapshot.data[0][jsonKey].toString();
              return ListTile(
                //contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                title: Text(
                  getTranslated(context,'asset_info_label_'+jsonKey),
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Text(jsonValue,style: TextStyle())
                ),
              );
            },
          );
        }else{
          return Center(
            child: Text(getTranslated(context, 'asset_info_empty_value'))  //'자산 정보가 존재하지 않습니다.'
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
