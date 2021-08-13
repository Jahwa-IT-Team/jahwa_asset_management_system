import 'dart:async';

import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/models/rfid_info.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class BluetoothReaderPage extends StatefulWidget {
  final String address;
  BluetoothReaderPage({Key key, @required this.address}) : super(key: key);

  @override
  _BluetoothReaderPageState createState() => _BluetoothReaderPageState();
}

class _BluetoothReaderPageState extends State<BluetoothReaderPage> {
  ScrollController scrollController;
  bool dialVisible = true;
  UserRepository $userRepository;
  int connected = 1;
  List<RFIDAssetInfo> rfidAssetInfos;
  int rfidPower = 0;

  @override
  void initState() {
    Btprotocol.instance.disconnectDevice();
    Btprotocol.instance.connectDevice(widget.address).then((value) {
      Btprotocol.instance.clearData();
      setState(() {
        if (value == 0) {
          connected = 0;
        } else {
          connected = -1;
        }

        getPower();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    Btprotocol.instance.disconnectDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ($userRepository == null) {
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    if (connected == 0) {
      debugPrint("Bluetooth 연결 성공");
      Btprotocol.instance.clearData();
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated(context, 'bluetooth_reader_page_title')),
          backgroundColor: Colors.green,
        ),
        body: getListView(),
        floatingActionButton: buildSpeedDial(),
      );
    } else if (connected == 1) {
      debugPrint("Bluetooth 연결 중");
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated(context, 'bluetooth_reader_page_title')),
          backgroundColor: Colors.green,
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
        )),
        floatingActionButton: buildSpeedDial(),
      );
    } else {
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
        SpeedDialChild(
          child: Icon(Icons.exposure_neg_1, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => setMinusPower(),
          label: '-1',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.plus_one, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => setPlusPower(),
          label: '+1',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.clear_all, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => Btprotocol.instance.clearData(),
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

  Widget initStreamBuilder() {
    return StreamBuilder<int>(
      stream: Btprotocol.instance
          .connectDevice($userRepository.bluetoothDevice.address)
          .asStream(),
      //initialData: 0,
      builder: (c, snapshot) {
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
            ));
            break;
          case ConnectionState.done:
          case ConnectionState.active:
            if (snapshot.data == 0) {
              //Bluetooth 연결
              connected = 0;
              debugPrint("Bluetooth 연결 성공 :" + snapshot.data.toString());
              return getListView();
            } else {
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

  Widget getListView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          StreamBuilder<List<RFIDAssetInfo>>(
            //stream: Stream.periodic(Duration(seconds: 1)).asyncMap((_) => dataRead()),
            stream:
                Btprotocol.instance.onChangeState.asyncMap((_) => dataRead()),
            initialData: [],
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                case ConnectionState.active:
                  return Column(
                      children: rfidAssetInfos
                          .map((d) => ListTile(
                                title: Text(d.tag),
                              ))
                          .toList());
                  break;
                default:
                  return Container();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  List<RFIDAssetInfo> convertData(List<String> tagList) {
    List<RFIDAssetInfo> list = [];
    debugPrint("tagList length : ${tagList.length.toString()}");
    if (tagList.length > 0) {
      for (String tagId in tagList) {
        //debugPrint("Tag Id(device) : $tagId");
        var rfid = new RFIDAssetInfo(tag: tagId);
        //debugPrint("Tag Id(mobile) : ${rfid.tag}");
        list.add(rfid);
      }
    }
    rfidAssetInfos = list;

    return rfidAssetInfos;
  }

  Future<void> setMinusPower() async {
    Btprotocol.instance.setPower(rfidPower - 10);
  }

  Future<void> setPlusPower() async {
    Btprotocol.instance.setPower(rfidPower + 10);
  }

  Future<int> getPower() async {
    return await Btprotocol.instance.initPower().then((_) {
      return Future.delayed(Duration(seconds: 2)).then((_) {
        return Btprotocol.instance.getPower;
      });
    });
  }

  Future<List<RFIDAssetInfo>> dataRead() async {
    List<RFIDAssetInfo> list = [];
    List<SharkDataInfo> tagList = await Btprotocol.instance.getListTag;
    // List<SharkDataInfo> tagList = [];
    // deviceDataList.forEach((e) {
    //   tagList.add(SharkDataInfo(type: e.substring(0,1), tagData:e.substring(1)));
    // });

    rfidPower = await Btprotocol.instance.getPower;

    debugPrint("tagList length : ${tagList.length.toString()}");
    if (tagList.length > 0) {
      for (SharkDataInfo data in tagList) {
        //debugPrint("Tag Id(device) : $tagId");
        var rfid = new RFIDAssetInfo(tag: data.tagData);
        //debugPrint("Tag Id(mobile) : ${rfid.tag}");
        list.add(rfid);
      }
    }
    rfidAssetInfos = list;
    // setState(() {
    //   rfidAssetInfos = list;
    // });

    return rfidAssetInfos;
  }
}
