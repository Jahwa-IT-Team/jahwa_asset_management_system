import 'package:flutter/material.dart';
//import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';


import 'facility_location_change.dart';
import 'facility_location_inspaction.dart';
import 'facility_location_search.dart';



class FacilityLocationTabs extends StatefulWidget {
  FacilityLocationTabs({Key key}) : super(key: key);

  @override
  _FacilityLocationTabsState createState() => _FacilityLocationTabsState();
}

class _FacilityLocationTabsState extends State<FacilityLocationTabs> with SingleTickerProviderStateMixin {
  
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
        title: Text(getTranslated(context, 'facility_location_tabs_title')),
        backgroundColor: Colors.deepPurple,
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
        color: Colors.deepPurple,
        //height: 100,
        child: TabBar(
          unselectedLabelColor: Colors.white38,
          //labelColor: Colors.amber[300],
          controller: ctr,
          tabs: <Tab>[
            Tab(
              icon: Icon(Icons.search),
              text: getTranslated(context, 'facility_location_tabs_search'),
            ),
            Tab(
              icon: Icon(Icons.storage),
              text: getTranslated(context, 'facility_location_tabs_inspaction'),
            ),
            Tab(
              icon: Icon(Icons.cached),
              text: getTranslated(context, 'facility_location_tabs_change'),
            ),
          ],
        ),
        
      ),
      body: TabBarView(
        controller: ctr,
        children: <Widget>[
          new FacilityLocationSearchPage(),
          new FacilityLocationInspactionPage(),
          new FacilityLocationChangePage(),
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

