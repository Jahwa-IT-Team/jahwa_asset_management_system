import 'package:flutter/material.dart';
//import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import './facility_trade_request.dart';
import './facility_trade_send.dart';
import './facility_trade_receive.dart';
import './facility_trade_rfid_registration.dart';



class FacilityTradTabs extends StatefulWidget {
  FacilityTradTabs({Key key}) : super(key: key);

  @override
  _FacilityTradTabsState createState() => _FacilityTradTabsState();
}

class _FacilityTradTabsState extends State<FacilityTradTabs> with SingleTickerProviderStateMixin {
  
  TabController ctr;
  
  @override
  void initState(){
    super.initState();
    ctr = new TabController(length: 4, vsync: this);
  }

  @override void dispose() { 
    ctr.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'facility_trade_tabs_title')),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.home), 
            onPressed: () {
              //Navigator.pop(context, homeRoute);
              //Navigator.popUntil(context, ModalRoute.withName(homeRoute));
              Navigator.pop(context);
             
            }
            ),
        ],
      ),
      
      bottomNavigationBar: Container(
        color: Colors.indigo,
        //height: 100,
        child: TabBar(
          unselectedLabelColor: Colors.white38,
          //labelColor: Colors.amber[300],
          controller: ctr,
          tabs: <Tab>[
            Tab(
              icon: Icon(Icons.input),
              text: getTranslated(context, 'facility_trade_request'),
            ),
            Tab(
              icon: Icon(Icons.send),
              text: getTranslated(context, 'facility_trade_send'),
            ),
            Tab(
              icon: Icon(Icons.receipt),
              text: getTranslated(context, 'facility_trade_receive'),
            ),
            Tab(
              icon: Icon(Icons.device_hub),
              text: getTranslated(context, 'facility_trade_rfid_registration'),
            ),
          ],
        ),
        
      ),
      body: TabBarView(
        controller: ctr,
        children: <Widget>[
          new FacilityTradeRequestPage(),
          new FacilityTradeSendPage(),
          new FacilityTradeReceivePage(),
          new FacilityTradeRFIDRegistrationPage(),
        ],
      ),
      
    );
  }
}

