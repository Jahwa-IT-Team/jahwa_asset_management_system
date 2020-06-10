//import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/models/facility_trade.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_receive_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_request_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_send_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/facility_trade_bluetooth_reader.dart';
import 'package:jahwa_asset_management_system/widgets/custom_widget.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../../routes.dart';

class FacilityTradeRequestDetailViewPage extends StatefulWidget {
  final PageType pageType;
  FacilityTradeRequestDetailViewPage({Key key, @required this.pageType}) : super(key: key);

  @override
  _FacilityTradeRequestDetailViewPageState createState() => _FacilityTradeRequestDetailViewPageState();
}

class _FacilityTradeRequestDetailViewPageState extends State<FacilityTradeRequestDetailViewPage>{
  ScrollController scrollController = ScrollController();
  bool dialVisible = true;
  bool _showMaterialonIOS = true;
  bool isSearch = false;
  UserRepository $userRepository; 
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  FacilityTradeRequestRepository $facilityTradeRequestRepository;
  FacilityTradeSendRepository $facilityTradeSendRepository;
  FacilityTradeReceiveRepository $facilityTradeReceiveRepository;
  


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if($facilityTradeCommonRepository == null){
      $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen: true);
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

    return buildRequestPage();
  }

  Widget buildRequestPage(){
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'facility_trade_request_detail_view_page')),
        backgroundColor: Colors.indigo,
      ),
      body:Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if(isSearch) Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  //filterSearchResults(value);
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
            //getRequestListView(),
            if(widget.pageType == PageType.Request) Expanded(child: getRequestListView(),) ,
            if(widget.pageType == PageType.Send) Expanded(child: getSendListView(),),
            if(widget.pageType == PageType.Receive) Expanded(child: getReceiveListView(),),
            SizedBox(height: 70,),
          ],
        ),
      ),
      floatingActionButton:FloatingActionButton.extended(
        onPressed: () {

          if($userRepository.bluetoothDevice == null || $userRepository.bluetoothDevice.address == null || $userRepository.bluetoothDevice.address == ""){
            customAlertOK(context,getTranslated(context, 'device_not_found'), getTranslated(context, 'device_not_found_desc'))
              .show()
              .then((value) => Navigator.pushNamed(context, bluetoothScanRoute));
            
          }else{
            Navigator.pushNamed(context, facilityTradeBluetoothReaderRoute, arguments: FacilityTradeBluetoothReaderArguments(address:$userRepository.bluetoothDevice.address,pageType: widget.pageType));
          }
        },
        label: Text('Add(RFID)'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget getRequestListView(){
    return ListView.builder(
      //shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
      itemCount: $facilityTradeRequestRepository.requestDetailList.length,
      itemBuilder: (context, index){
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,0.0),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              // title: Text(
              //   "test",
              //   style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
              //   textAlign: TextAlign.center,
              // ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CardSettingsSection(
                    showMaterialonIOS: _showMaterialonIOS,
                    header: CardSettingsHeader(
                      label: "[${$facilityTradeRequestRepository.requestDetailList[index].facilityCode}]" ,
                      showMaterialonIOS: _showMaterialonIOS,
                      labelAlign: TextAlign.center,
                      color: Colors.indigoAccent,
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_name'),
                    content: Text($facilityTradeRequestRepository.requestDetailList[index].facilityName)
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_spec'),
                    content: Text($facilityTradeRequestRepository.requestDetailList[index].facilitySpec)
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_asst_no'),
                    content: Text($facilityTradeRequestRepository.requestDetailList[index].assetCode)
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_grade'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.gradeData,
                      value: $facilityTradeRequestRepository.requestDetailList[index].facilityGrade,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.gradeData),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeRequestRepository.requestDetailList[index].facilityGrade = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'plant'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.plantData,
                      value: $facilityTradeRequestRepository.requestDetailList[index].plantCode,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.plantData),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeRequestRepository.requestDetailList[index].plantCode = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'item_group'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.itemGroupData,
                      value: $facilityTradeRequestRepository.requestDetailList[index].itemGroup,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.itemGroupData
                            .toList()
                            .where((e)=>(e.value.toString().toLowerCase().substring(0,3).contains($facilityTradeRequestRepository.requestDetailList[index].plantCode.toLowerCase())))
                            .toList()
                          ),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeRequestRepository.requestDetailList[index].itemGroup = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FlatButton(
                              onPressed: (){$facilityTradeRequestRepository.removeRequestDetailOne($facilityTradeRequestRepository.requestDetailList[index]);},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, 'remove'),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            )
                          )
                        ),
                    ],),
                  ),
                ]
              )
            )
          )
        );
      }
    );
  }

  Widget getSendListView(){
    return ListView.builder(
      itemCount: $facilityTradeSendRepository.sendDetailList.length,
      itemBuilder: (context, index){
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,0.0),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              // title: Text(
              //   "test",
              //   style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
              //   textAlign: TextAlign.center,
              // ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CardSettingsSection(
                    showMaterialonIOS: _showMaterialonIOS,
                    header: CardSettingsHeader(
                      label: "[${$facilityTradeSendRepository.sendDetailList[index].facilityCode}]" ,
                      showMaterialonIOS: _showMaterialonIOS,
                      labelAlign: TextAlign.center,
                      color: Colors.indigoAccent,
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_name'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].facilityName,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_request_number'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].reqNo,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_spec'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].facilitySpec,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_asst_no'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].assetCode,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_request_company_type'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].entName,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_request_person_name'),
                    content: Text($facilityTradeSendRepository.sendDetailList[index].managerName,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FlatButton(
                              onPressed: (){$facilityTradeSendRepository.removeSendDetailOne($facilityTradeSendRepository.sendDetailList[index]);},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, 'remove'),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            )
                          )
                        ),
                    ],),
                  ),
                ]
              )
            )
          )
        );
      }
    );
  }

  Widget getReceiveListView(){
    return ListView.builder(
      itemCount: $facilityTradeReceiveRepository.receiveDetailList.length,
      itemBuilder: (context, index){
        return Card(
          elevation: 5.0,
          margin: new EdgeInsets.fromLTRB(15.0,10.0,15.0,0.0),
          child: Container(
            decoration: BoxDecoration(
              //border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(0.0)))),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              // title: Text(
              //   "test",
              //   style: TextStyle(color: Colors.black, fontSize: 16,fontWeight:(FontWeight.bold), ),
              //   textAlign: TextAlign.center,
              // ),
              
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CardSettingsSection(
                    showMaterialonIOS: _showMaterialonIOS,
                    header: CardSettingsHeader(
                      label: "[${$facilityTradeReceiveRepository.receiveDetailList[index].facilityCode}]" ,
                      showMaterialonIOS: _showMaterialonIOS,
                      labelAlign: TextAlign.center,
                      color: Colors.indigoAccent,
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_name'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].facilityName,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_send_invoice_no'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].invNo,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_spec'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].facilitySpec,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_asst_no'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].assetCode,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_request_company_type'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].entName,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_trade_request_person_name'),
                    content: Text($facilityTradeReceiveRepository.receiveDetailList[index].managerName,),
                  ),
                  customCardField(
                    label: getTranslated(context, 'facility_grade'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.gradeData,
                      value: $facilityTradeReceiveRepository.receiveDetailList[index].facilityGrade,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.gradeData),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeReceiveRepository.receiveDetailList[index].facilityGrade = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'asset_info_label_setarea'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.getSetupLocationData($facilityTradeReceiveRepository.receiveDetailList[index].entCode),
                      value: $facilityTradeReceiveRepository.receiveDetailList[index].setupLocationCode,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.getSetupLocationData($facilityTradeReceiveRepository.receiveDetailList[index].entCode)),
                          hideHeader: true,
                          textAlign: TextAlign.left,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeReceiveRepository.receiveDetailList[index].setupLocationCode = picker.getSelectedValues()[0];
                            $facilityTradeReceiveRepository.receiveDetailList[index].setupLocation = $facilityTradeCommonRepository.getSetupLocationName($facilityTradeReceiveRepository.receiveDetailList[index].entCode, picker.getSelectedValues()[0]);
                            
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'plant'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.plantData,
                      value: $facilityTradeReceiveRepository.receiveDetailList[index].plantCode,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.plantData),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeReceiveRepository.receiveDetailList[index].plantCode = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  customCardField(
                    label: getTranslated(context, 'item_group'),
                    content: customDropdown(
                      data: $facilityTradeCommonRepository.itemGroupData,
                      value: $facilityTradeReceiveRepository.receiveDetailList[index].itemGroup,
                      onTap: (){
                        debugPrint("Grade onTap:");
                        Picker(
                          adapter: PickerDataAdapter(data: $facilityTradeCommonRepository.itemGroupData
                            .toList()
                            .where((e)=>(e.value.toString().toLowerCase().substring(0,3).contains($facilityTradeReceiveRepository.receiveDetailList[index].plantCode.toLowerCase())))
                            .toList()
                          ),
                          hideHeader: true,
                          title: new Text("Please Select"),
                          onConfirm: (Picker picker, List value) {
                            print(picker.getSelectedValues()[0].toString());
                            $facilityTradeReceiveRepository.receiveDetailList[index].itemGroup = picker.getSelectedValues()[0];
                            setState(() {
                              
                            });
                          }
                        ).showDialog(context);
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FlatButton(
                              onPressed: (){$facilityTradeReceiveRepository.removeReceiveDetailOne($facilityTradeReceiveRepository.receiveDetailList[index]);},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, 'remove'),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            )
                          )
                        ),
                    ],),
                  ),
                ]
              )
            )
          )
        );
      }
    );
  }

  
}
