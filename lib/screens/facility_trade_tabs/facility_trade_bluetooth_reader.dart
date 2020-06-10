import 'dart:async';

import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_receive_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_request_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_send_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FacilityTradeBluetoothReaderArguments{
  final String address;
  final PageType pageType;

  FacilityTradeBluetoothReaderArguments({@required this.address,@required this.pageType});
}

class FacilityTradeBluetoothReaderPage extends StatefulWidget {
  final FacilityTradeBluetoothReaderArguments screenArguments;
  FacilityTradeBluetoothReaderPage({Key key, @required this.screenArguments}) : super(key: key);

  @override
  _FacilityTradeBluetoothReaderPageState createState() => _FacilityTradeBluetoothReaderPageState();
}

class _FacilityTradeBluetoothReaderPageState extends State<FacilityTradeBluetoothReaderPage>{
  ScrollController scrollController;
  bool dialVisible = true;
  UserRepository $userRepository; 
  FacilityTradeRequestRepository $facilityTradeRequestRepository;
  FacilityTradeSendRepository $facilityTradeSendRepository;
  FacilityTradeReceiveRepository $facilityTradeReceiveRepository;
  int connected = 1;
  int rfidPower = 0;
  String title;

  @override
  void initState() {
    Btprotocol.instance.disconnectDevice();  
    Btprotocol.instance.connectDevice(widget.screenArguments.address).then((value) {
      setState(() {
        if(value ==0){
          connected = 0;
        }else{
          connected = -1;
        }
      });
    });

    Future.delayed(Duration(seconds: 1)).then((_){
      Btprotocol.instance.clearData();
    });
    
    Btprotocol.instance.onChangeState.listen((event) {dataRead();});
    super.initState();
  }

  @override
  void dispose(){
    Btprotocol.instance.clearData();
    Btprotocol.instance.disconnectDevice();  
    if($facilityTradeRequestRepository != null) $facilityTradeRequestRepository.clearRequestScanList(false);
    if($facilityTradeSendRepository != null) $facilityTradeSendRepository.clearSendScanList(false);
    if($facilityTradeReceiveRepository != null) $facilityTradeReceiveRepository.clearReceiveScanList(false);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }
    if($facilityTradeRequestRepository == null){
      $facilityTradeRequestRepository = Provider.of<FacilityTradeRequestRepository>(context, listen: true);
    }
    if($facilityTradeSendRepository == null){
      $facilityTradeSendRepository = Provider.of<FacilityTradeSendRepository>(context, listen: true);
    }

    if($facilityTradeReceiveRepository == null){
      $facilityTradeReceiveRepository = Provider.of<FacilityTradeReceiveRepository>(context, listen: true);
    }
    
    switch (widget.screenArguments.pageType) {
      case PageType.Request :
        title = getTranslated(context, 'rfid_scan') +" - "+getTranslated(context, 'facility_trade_request');
        break;
      case PageType.Send:
        title = getTranslated(context, 'rfid_scan') +" - "+getTranslated(context, 'facility_trade_send');
        break;
      case PageType.Receive:
        title = getTranslated(context, 'rfid_scan') +" - "+getTranslated(context, 'facility_trade_receive');
        break;
      default:
        title = getTranslated(context, 'rfid_scan');
        break;
    }

    if(connected==0){
      debugPrint("Bluetooth 연결 성공");
      //Btprotocol.instance.clearData();
      //Btprotocol.instance.setPower(300);
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.indigo,
        ),
        body:Container(
          child: Column(children:<Widget>[
            if(widget.screenArguments.pageType == PageType.Request) Expanded(child: getListView1(),),
            if(widget.screenArguments.pageType == PageType.Send) Expanded(child: getListView2(),),
            if(widget.screenArguments.pageType == PageType.Receive) Expanded(child: getListView3(),),
          ],)
        ,) ,
        floatingActionButton: buildSpeedDial(),
      );
    }else if(connected==1){
      debugPrint("Bluetooth 연결 중");
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated(context, 'bluetooth_reader_page_title')),
          backgroundColor: Colors.indigo,
        ),
        //body:initStreamBuilder(),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: SizedBox(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                //strokeWidth: 3.0,
              ),
              height: 30.0,
              width: 30.0,
            ),
          ) 
        ),
        floatingActionButton: buildSpeedDial(),
      );
    }else{
      debugPrint("Bluetooth 연결 실패");
      return Center();
    }
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        // SpeedDialChild(
        //   child: Icon(Icons.exposure_neg_1, color: Colors.white),
        //   backgroundColor: Colors.deepOrange,
        //   onTap: () => setMinusPower(),
        //   label: '-1',
        //   labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //   labelBackgroundColor: Colors.deepOrangeAccent,
        // ),
        // SpeedDialChild(
        //   child: Icon(Icons.plus_one, color: Colors.white),
        //   backgroundColor: Colors.green,
        //   onTap: () => setPlusPower(),
        //   label: '+1',
        //   labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //   labelBackgroundColor: Colors.green,
        // ),
        SpeedDialChild(
          child: Icon(Icons.clear_all, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => _clearScanRFID() ,
          labelWidget: Container(
            color: Colors.blue,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(6),
            child: Text('Clear All'),
          ),
        ),
      ],
    );
  }

  void _clearScanRFID(){
    debugPrint("clearScanRFID");
    Btprotocol.instance.clearData();
    $facilityTradeRequestRepository.clearRequestScanList(true);
    $facilityTradeSendRepository.clearSendScanList(true);
    $facilityTradeReceiveRepository.clearReceiveScanList(true);
  }

  Widget initStreamBuilder(){
    return StreamBuilder<int>(
      stream: Btprotocol.instance.connectDevice($userRepository.bluetoothDevice.address).asStream(),
      //initialData: 0,
      builder: (c, snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    //strokeWidth: 3.0,
                  ),
                  height: 30.0,
                  width: 30.0,
                ),
              ) 
            );
            break;
          case ConnectionState.done:
          case ConnectionState.active :
            if(snapshot.data == 0){
              //Bluetooth 연결
              connected = 0;
              debugPrint("Bluetooth 연결 성공 :" + snapshot.data.toString());
              return getListView();
            }else{
              //Bluetooth 연결 실패
              connected = -1;
              debugPrint("Bluetooth 연결 실패 : " + snapshot.data.toString());
            }
            return Center();
            break;
          default:
            return Center();
            break;
        }
      },
    );
  }
  
  Widget getListView(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          //getListView1(),
          StreamBuilder<List<RequestDetail>>(
            //stream: Stream.periodic(Duration(seconds: 1)).asyncMap((_) => dataRead()),
            stream: Btprotocol.instance.onChangeState.asyncMap((_) => dataRead()),
            initialData: [],
            builder: (context,snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                case ConnectionState.active :
                  return Column();
                  break;
                default:
                  return Container();
                  break;
              }
            },
          ),
      ],),
    );
  }

  Widget getListView1(){
    return ListView.builder(
      itemCount: $facilityTradeRequestRepository.requestScanRFIDDetailList.length,
      itemBuilder: (context, index){
        RequestDetail detail = $facilityTradeRequestRepository.requestScanRFIDDetailList[index];
        double lastCard = 10.0;
        if($facilityTradeRequestRepository.requestScanRFIDDetailList.length == (index+1))
        {
          lastCard = 70.0;
        }
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,lastCard),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              title: Text(
                "[${detail?.facilityCode??getTranslated(context, 'not_registered')}]${detail?.facilityName??detail.rfid}",
                style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
                textAlign: TextAlign.center,
              ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,30.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_spec'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.facilitySpec??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'rfid'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.rfid??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_asst_no'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.assetCode??'',)),
                    ],),
                  ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context,'facility_grade'),style: TextStyle(color: Colors.black87),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.facilityGrade
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context, 'plant'),style: TextStyle(color: Colors.black87,),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.plantName
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context, 'item_group'),style: TextStyle(color: Colors.black87),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.itemGroup
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  new Divider(),
                  _buildRequestButton(detail),
                          
                  ////
              ],),
            ),
          ),
        );
      }
    );
  }

  Widget getListView2(){
    return ListView.builder(
      itemCount: $facilityTradeSendRepository.sendScanRFIDDetailList.length,
      itemBuilder: (context, index){
        SendDetail detail = $facilityTradeSendRepository.sendScanRFIDDetailList[index];
        double lastCard = 10.0;
        if($facilityTradeSendRepository.sendScanRFIDDetailList.length == (index+1))
        {
          lastCard = 70.0;
        }
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,lastCard),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              title: Text(
                "[${detail?.facilityCode??getTranslated(context, 'not_registered')}]${detail?.facilityName??detail.rfid}",
                style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
                textAlign: TextAlign.center,
              ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,30.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_spec'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.facilitySpec??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'rfid'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.rfid??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_asst_no'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.assetCode??'',)),
                    ],),
                  ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context,'facility_grade'),style: TextStyle(color: Colors.black87),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.facilityGrade
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context, 'plant'),style: TextStyle(color: Colors.black87,),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.plantName
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  // new Divider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       new Expanded(child: new Text(getTranslated(context, 'item_group'),style: TextStyle(color: Colors.black87),)),
                  //       new Expanded(
                  //         child: new TextField(
                  //           decoration: InputDecoration(
                  //             labelText: detail?.itemGroup
                  //           ),
                  //         ),
                  //       ),
                  //   ],),
                  // ),
                  new Divider(),
                  _buildSendButton(detail),
                          
                  ////
              ],),
            ),
          ),
        );
      }
    );
  }

  Widget getListView3(){
    return ListView.builder(
      itemCount: $facilityTradeReceiveRepository.receiveScanRFIDDetailList.length,
      itemBuilder: (context, index){
        ReceiveDetail detail = $facilityTradeReceiveRepository.receiveScanRFIDDetailList[index];
        double lastCard = 10.0;
        if($facilityTradeReceiveRepository.receiveScanRFIDDetailList.length == (index+1))
        {
          lastCard = 70.0;
        }
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,lastCard),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              title: Text(
                "[${detail?.facilityCode??getTranslated(context, 'not_registered')}]${detail?.facilityName??detail.rfid}",
                style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
                textAlign: TextAlign.center,
              ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,30.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_spec'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.facilitySpec??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'rfid'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.rfid??'',)),
                    ],),
                  ),
                  new Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,15.0,0.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(child: new Text(getTranslated(context, 'asset_info_label_asst_no'),style: TextStyle(color: Colors.black87),)),
                        new Expanded(child: new Text(detail?.assetCode??'',)),
                    ],),
                  ),
                  new Divider(),
                  _buildReceiveButton(detail),
                          
                  ////
              ],),
            ),
          ),
        );
      }
    );
  }


  Widget _buildRequestButton(RequestDetail detail){
    if(detail.facilityCode != null && !$facilityTradeRequestRepository.requestDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //설비번호가 있고 요청 내역에 없는 스캔 자료
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){
                    {
                      $facilityTradeRequestRepository.addRequestDetailList(detail);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                      Text(
                        getTranslated(context, 'Add'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if(detail.facilityCode == null || detail.facilityCode == ''){
      //설비 정보가 없는 경우, 미등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'not_registered'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if($facilityTradeRequestRepository.requestDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //이미 등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'additional_completion'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else{
      return Container();
    }
  }

  Widget _buildSendButton(SendDetail detail){
    if(detail.facilityCode != null && !$facilityTradeSendRepository.sendDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //설비번호가 있고 요청 내역에 없는 스캔 자료
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){
                    {
                      $facilityTradeSendRepository.addSendDetailList(detail);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                      Text(
                        getTranslated(context, 'Add'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if(detail.facilityCode == null || detail.facilityCode == ''){
      //설비 정보가 없는 경우, 미등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'not_registered'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if($facilityTradeSendRepository.sendDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //이미 등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'additional_completion'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else{
      return Container();
    }
  }

  Widget _buildReceiveButton(ReceiveDetail detail){
    if(detail.facilityCode != null && !$facilityTradeReceiveRepository.receiveDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //설비번호가 있고 요청 내역에 없는 스캔 자료
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){
                    {
                      $facilityTradeReceiveRepository.addReceiveDetailList(detail);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                      Text(
                        getTranslated(context, 'Add'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if(detail.facilityCode == null || detail.facilityCode == ''){
      //설비 정보가 없는 경우, 미등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'not_registered'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else if($facilityTradeReceiveRepository.receiveDetailList.any((item) => item.facilityCode == detail.facilityCode)){
      //이미 등록
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(child: new Text('')),
            new Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                  onPressed: (){ },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'additional_completion'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                )
              )
            ),
        ],),
      );
    }else{
      return Container();
    }
  }

  Future<void> setMinusPower() async {
    Btprotocol.instance.setPower(rfidPower - 10);
  }

  Future<void> setPlusPower() async {
    Btprotocol.instance.setPower(rfidPower + 10);
  }

  Future<int> getPower() async{
    return await Btprotocol.instance.initPower().then((_){
      return Future.delayed(Duration(seconds: 2)).then((_) {
        return Btprotocol.instance.getPower;
      });
    });
  }


  Future<List<RequestDetail>> dataRead() async {
    List<SharkDataInfo> tagList = await Btprotocol.instance.getListTag;
    // List<SharkDataInfo> tagList = [];
    // deviceDataList.forEach((e) {
    //   debugPrint("bluetooth data => ${e.substring(0,1)} ,${e.substring(1)}");
    //   tagList.add(SharkDataInfo(type: e.substring(0,1), tagData:e.substring(1)));
    // });
    //rfidPower = await Btprotocol.instance.getPower;

    debugPrint("tagList length : ${tagList.length.toString()}");
    if(tagList.length > 0){
      
      switch(widget.screenArguments.pageType){
        case PageType.Request:
          for(SharkDataInfo data in tagList){
            $facilityTradeRequestRepository.addRequestScanRFIDDetailList(RequestDetail(rfid:data.tagData));
          }
          break;
        case PageType.Send:
          for(SharkDataInfo data in tagList){
            $facilityTradeSendRepository.addSendScanRFIDDetailList(SendDetail(rfid:data.tagData));
          }
          break;
        case PageType.Receive:
          for(SharkDataInfo data in tagList){
            $facilityTradeReceiveRepository.addReceiveScanRFIDDetailList(ReceiveDetail(rfid:data.tagData));
          }
          break;
        default:
          break;
      }
    }
    return [];
  }
}
