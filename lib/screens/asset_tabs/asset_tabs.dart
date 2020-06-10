import 'package:flutter/material.dart';
//import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_search.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_inspection.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_dashboard.dart';

class AssetTabs extends StatefulWidget {
  AssetTabs({Key key}) : super(key: key);

  @override
  _AssetTabsState createState() => _AssetTabsState();
}

class _AssetTabsState extends State<AssetTabs> with SingleTickerProviderStateMixin {
  
  TabController ctr;

  @override
  void initState(){
    super.initState();
    ctr = new TabController(length: 3, vsync: this);
  }

  @override void dispose() { 
    ctr.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'asset_tabs_title')),
        backgroundColor: Colors.green,
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
        color: Colors.green,
        //height: 100,
        child: TabBar(
          unselectedLabelColor: Colors.greenAccent,
          //labelColor: Colors.amber[300],
          controller: ctr,
          tabs: <Tab>[
            Tab(
              icon: Icon(Icons.search),
              text: getTranslated(context, 'asset_tabs_search'),
            ),
            Tab(
              icon: Icon(Icons.storage),
              text: getTranslated(context, 'asset_tabs_inspaction'),
            ),
            Tab(
              icon: Icon(Icons.equalizer),
              text: getTranslated(context, 'asset_tabs_dashboard'),
            ),
          ],
        ),
        
      ),
      body: TabBarView(
        controller: ctr,
        children: <Widget>[
          new AssetSearchPage(),
          new AssetInspectionPage(),
          new AssetDashboardPage(),
        ],
      ),
      // bottomNavigationBar: new BottomNavigationBar(
      //   type : BottomNavigationBarType.fixed,
        
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       title: Text(getTranslated(context, 'asset_tabs_search')),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.storage),
      //       title: Text(getTranslated(context, 'asset_tabs_inspaction')),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.equalizer),
      //       title: Text(getTranslated(context, 'asset_tabs_table_chart')),
      //     ),
      //   ],
      //   currentIndex: _index,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

