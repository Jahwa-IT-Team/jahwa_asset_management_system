
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../main.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  UserRepository $userRepository; 
  String _langCode = "";
  bool showNewstVersion = false;
  bool isCheckdVersion = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState(){
    initPackageInfo();

    super.initState();
  }

  /// initState 이후 실행
  /// 데이터에 의존하는 객체(InheritedWidget) 호출 시 마다 실행
  @override
  void didChangeDependencies() {
    getLanguageCode().then((langCode) {
      setState(() {
        this._langCode = langCode;
      });
    });
    super.didChangeDependencies();
  }

  Future<void> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void changeLanguage(String languageCode) async {
    await setLocale(languageCode).then((_locale) {
      MyApp.setLocale(context, _locale);
      getLanguageCode().then((langCode) {
        setState(() {
          this._langCode = langCode;
          debugPrint("Change Language : $_langCode");
        });
      });
    });
  }

  /// App버전 체크 및 Alert 
  Future<void> checkAppVersion() async{
    if($userRepository != null){
      int check = await $userRepository.checkAppVersion();
      
      if(check > 0){
        //서버에 최신 버전 존재
        showNewstVersion = true;
        alertNewestVersion();
      }else if(check < 0){
        //서버에 연결 실패 또는 오류
        showNewstVersion = false;
      }else{
        //현재 최신 버전 설치
        showNewstVersion = false;
      }

      isCheckdVersion = true;
    }

    print('버전 체크');
    
  }

  void onItemTapped(int index){
    setState((){
      _index = index;

      switch (index) {
        case 0:
          //Navigator.pushReplacementNamed(context, homeRoute);
          //_value = "Current value is : ${_index.toString()}";
          break;
        case 1:
          _index = 0;
          Navigator.pushNamed(context, assetTabsRoute);
          break;
        case 2:
          _index = 0;
          //alertComingSoon();
          Navigator.pushNamed(context, facilityLocationTabsRoute);
          break;
        case 3:
          _index = 0;
          //comingSoon();
          Navigator.pushNamed(context, facilityTradeTabsRoute);
          break;
        default:
      }
    });
  }

  Future<bool> alertComingSoon(){
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "Coming Soon...",
      desc: "서비스 준비중입니다.",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Future<bool> alertNewestVersion(){
    return Alert(
      context: context,
      closeFunction: () => launchDownloadURL(),
      type: AlertType.info,
      title: "New Version",
      desc: getTranslated(context, 'newest_app_version_web_open_msg'),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => launchDownloadURL(),
          width: 120,
        )
      ],
    ).show();
  }

  Future launchDownloadURL() async {
    if(Foundation.kDebugMode){
      print('App in debug mode');
      Navigator.pop(context);
      return;
    }
    const url = 'https://japi.jahwa.co.kr/Download';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if($userRepository == null){
      $userRepository = Provider.of<UserRepository>(context, listen: true);

      if(!isCheckdVersion && Platform.isAndroid){
        checkAppVersion();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'home_page_title')),
        backgroundColor: Colors.green,
      ),
      body: getView(),
      bottomNavigationBar: new BottomNavigationBar(
        type : BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(getTranslated(context, 'home_page_tabs_asset_setting')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage), //storage  //find_in_page
            title: Text(getTranslated(context, 'home_page_tabs_asset_management')),
          ),
          if(Platform.isAndroid)
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            title: Text(getTranslated(context, 'home_page_tabs_facility_location')),
          ),
          if(Platform.isAndroid)
          BottomNavigationBarItem(
            icon: Icon(Icons.import_export),
            title: Text(getTranslated(context, 'home_page_tabs_facility_trade')),
          ),
        ],
        //fixedColor: Colors.blue,
        currentIndex: _index,
        backgroundColor: Colors.green,
        unselectedItemColor: Colors.greenAccent,
        selectedItemColor: Colors.white,
        onTap: onItemTapped,
      ),
    );
  }

  Widget getView(){
    return LayoutBuilder(
      builder: (context, constranints){
        //$userRepository = Provider.of<UserRepository>(context, listen: false);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constranints.maxHeight),
          //   child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // CircleAvatar(
                  //   radius: 60,
                  //   backgroundColor: Colors.green.shade800,
                    
                  //   child: ClipOval(
                  //     child: Stack(
                  //       children: <Widget>[
                  //         Icon(Icons.people,size: 120,),
                  //         //Image.network('https://via.placeholder.com/300'),
                  //         // Positioned(
                  //         //   bottom: 0,
                  //         //   right: 0,
                  //         //   left: 0,
                  //         //   height: 33,
                  //         //   child: GestureDetector(
                  //         //     onTap: (){
                  //         //       print('upload Clicked');
                  //         //     },
                  //         //     child: Container(
                  //         //       height: 20,
                  //         //       width: 30,
                  //         //       color: Color.fromRGBO(0, 0, 0, .74),
                  //         //       child: Center(
                  //         //         //child: Icon(Icons.photo_camera, color: Colors.grey),
                  //         //         //child: Text($userRepository.user.),
                  //         //       ),
                  //         //     ),
                  //         //   ),
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  //   //backgroundImage: AssetImage('images/protocoder.png'),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  SettingsSection(
                    title: getTranslated(context, 'app_info'),
                    tiles: [
                      SettingsTile(
                        title: getTranslated(context, 'app_version'),
                        subtitle: _packageInfo.version??'',
                        leading: Icon(Icons.verified_user),
                        onTap: () {},
                      ),
                      if(showNewstVersion) newestVersion(),
                    ],
                  ),
                  SettingsSection(
                    title: getTranslated(context, 'user_info'),
                    tiles: [
                      SettingsTile(
                        title: getTranslated(context, 'user_company'),
                        subtitle: $userRepository.user==null?'':$userRepository.user.company,
                        leading: Icon(Icons.account_balance),
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: getTranslated(context, 'user_name'),
                        subtitle: $userRepository.user==null?'':$userRepository.user.name,
                        leading: Icon(Icons.person),
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: getTranslated(context, 'user_dept'),
                        subtitle: $userRepository.user==null?'':$userRepository.user.deptName,
                        leading: Icon(Icons.work),
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: getTranslated(context, 'emp_no'),
                        subtitle: $userRepository.user==null?'':$userRepository.user.empNo,
                        leading: Icon(Icons.dialpad),
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: getTranslated(context, 'email_addr'),
                        subtitle: $userRepository.user==null?'':$userRepository.user.emailAddr,
                        leading: Icon(Icons.email),
                        onTap: () {},
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: getTranslated(context, 'config'),
                    tiles: [
                      SettingsTile(
                        title: getTranslated(context, 'change_language'),
                        subtitle: getLanguageName(_langCode),
                        leading: Icon(Icons.language),
                        onTap: () {showPickerLanguage(context);},
                      ),
                      SettingsTile(
                        title: getTranslated(context, 'change_company'),
                        subtitle: $userRepository.connectionInfo==null?'':$userRepository.connectionInfo.company,
                        leading: Icon(Icons.view_comfy),
                        onTap: () {showPickerCompany(context);},
                      ),
                    ],
                  ),
                  if(Platform.isAndroid)
                  SettingsSection(
                    title: getTranslated(context, 'device'),
                    tiles: [
                      SettingsTile(
                        title: 'Bluetooth',
                        subtitle: $userRepository.bluetoothDevice==null? 'None':$userRepository.bluetoothDevice.name,
                        leading: Icon(Icons.bluetooth),
                        onTap: () { Navigator.pushNamed(context, bluetoothScanRoute); },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: getTranslated(context, 'logout'),
                    tiles: [
                      SettingsTile(
                        title: getTranslated(context, 'logout'),
                        //subtitle: 'None',
                        leading: Icon(Icons.exit_to_app),
                        onTap: () {
                          $userRepository.signOut();
                          Navigator.popAndPushNamed(context, loginRoute);
                        },
                      ),
                    ],
                  ),
                ],
              ),
          //   ),
           ),
        );
      },
    );
    
  }

  

  showPickerLanguage(BuildContext context) {
    const PickerData = [["Korean","Vietnamese"]];
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: PickerData, isArray: true),
        hideHeader: true,
        title: new Text("Please Select"),
        onConfirm: (Picker picker, List value) {
          
          if(value.toString() == "[0]"){
            changeLanguage(KOREAN);
          }else if(value.toString() == "[1]"){
            changeLanguage(VIETNAMESE);
          }else{
            changeLanguage(KOREAN);
          }
          //print(value.toString());
          // print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  showPickerCompany(BuildContext context) {
    //const PickerData = [["KO532","VN532"]];
    //const Data = [PickerItem(text: "자화전자", value: Icons.add)];
    new Picker(
        //adapter: PickerDataAdapter<String>(pickerdata: PickerData, isArray: true),
        adapter: PickerDataAdapter(data: [
          PickerItem(text: Text("자화전자주식회사"),value: "KO532"),
          PickerItem(text: Text("JAHWA VINA CO LTD"),value: "VN532"),
          PickerItem(text: Text("惠州纳诺泰克合金科技有限公司"),value: "HZ532"),
          PickerItem(text: Text("天津磁化电子有限公司"),value: "TJ532"),
          PickerItem(text: Text("JH VINA CO LTD"),value: "JV532"),
          PickerItem(text: Text("JAHWA INDIA"),value: "IN532"),
          PickerItem(text: Text("주식회사나노테크"),value: "KO536"),
          PickerItem(text: Text("NT VINA CO LTD"),value: "VN536"),
          PickerItem(text: Text("NANOTECH VINA CO LTD"),value: "VN538"),
        ]),
        hideHeader: true,
        title: new Text("Please Select"),
        onConfirm: (Picker picker, List value) {
          //print(value.toString());
          //print();
          String company = picker.getSelectedValues()[0]?? 'KO532';
          $userRepository.changeConnectionCompany(company).then((_) {
            setState(() {
              debugPrint($userRepository.connectionInfo.company);
            });
          });
          
        }
    ).showDialog(context);
  }

  Widget newestVersion(){
    return SettingsTile(
        title: getTranslated(context, 'newest_app_version'),
        subtitle: $userRepository.appInfo==null?'':$userRepository.appInfo.versionName??'',
        leading: Icon(Icons.notifications_active),
        onTap: () {},
      );
  }

}

