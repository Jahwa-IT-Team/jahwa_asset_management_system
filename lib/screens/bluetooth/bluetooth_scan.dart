import 'dart:async';

import 'package:btprotocol/btprotocol.dart';
import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class BluetoothScanPage extends StatefulWidget {
  BluetoothScanPage({Key key}) : super(key: key);

  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  UserRepository $userRepository;
  //static const platform = const MethodChannel('jahwa.co.kr/bluetooth');
  // Get battery level.
  //String _bluetoothScan = 'Not Device List.';
  //Btprotocol btprotocol = new Btprotocol();

  @override
  Widget build(BuildContext context) {
    if ($userRepository == null) {
      $userRepository = Provider.of<UserRepository>(context, listen: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'bluetooth_scan_page_title')),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: () => Btprotocol.instance.getListPairedDevice(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(Duration(seconds: 2)).asyncMap(
                      (_) => Btprotocol.instance.getListPairedDevice()),
                  initialData: [],
                  builder: (c, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                              //strokeWidth: 3.0,
                            ),
                            height: 30.0,
                            width: 30.0,
                          ),
                        ));
                        break;
                      case ConnectionState.done:
                      case ConnectionState.active:
                        return Column(
                          children: snapshot.data
                              .map((d) => ListTile(
                                    title: Text(d.name),
                                    subtitle: Text(d.address),
                                    trailing: ElevatedButton(
                                      child: Text("Connect"),
                                      onPressed: () => {
                                        $userRepository.changeBluetooth(d),
                                        Navigator.pop(context)
                                      },
                                    ),
                                  ))
                              .toList(),
                        );
                        break;
                      default:
                        return Container();
                    }
                  }),
            ],
          ),
        ),
      ),
      // floatingActionButton: StreamBuilder<bool>(
      //   stream: Btprotocol.instance.isScanning,
      //   initialData: true,
      //   builder: (c, snapshot){
      //     if(snapshot.data){
      //       return FloatingActionButton(
      //         child: Icon(Icons.stop),
      //         onPressed: () =>_scanStop,
      //         backgroundColor: Colors.red,
      //       );
      //     }else{
      //       return FloatingActionButton(
      //         child: Icon(Icons.search) ,
      //         onPressed: () => _scanStart().timeout(Duration(seconds: 4)),
      //         backgroundColor: Colors.green,
      //       );
      //     }
      //   },
      // ),
    );
  }

  // Future<void> _scanStop() async {
  //   debugPrint("Bluetooth Scan Stop()");
  //   //Btprotocol.setBluetoothScanStop
  // }

  // Future<void> _scanStart() async {
  //   debugPrint("Bluetooth Scan Start()");
  //   String test = await Btprotocol.platformVersion;
  //   debugPrint(test);
  //   String test1 = await Btprotocol.test;
  //   debugPrint(test1);

  //   List<dynamic> list = await Btprotocol.instance.getListPairedDevice();
  //   debugPrint(list.toString());
  //   // String batteryLevel = await Btprotocol.getBluetoothScan.then((_) {
  //   //   setState(() {});
  //   //   debugPrint(_);
  //   //   return _;
  //   // });
  //   // try {
  //   //   final String result = await platform.invokeMethod('getBluetoothScan');
  //   //   batteryLevel = 'Android Result : $result % .';
  //   // } on PlatformException catch (e) {
  //   //   batteryLevel = "Failed to get battery level: '${e.message}'.";
  //   // }

  //   // setState(() {
  //   //   //_bluetoothScan = batteryLevel;
  //   // });
  // }

}
