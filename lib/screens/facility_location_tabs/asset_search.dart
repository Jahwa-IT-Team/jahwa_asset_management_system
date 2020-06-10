import 'package:flutter/material.dart';

class AssetSearchPage extends StatefulWidget{

  @override
  _AssetSearchPageState createState() => _AssetSearchPageState();

}

class _AssetSearchPageState extends State<AssetSearchPage>{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Center( 
        child: Icon( 
          Icons.access_alarm, 
          size: 200, 
          color: Colors.red, 
        ),
      ),
    );
  } 
}