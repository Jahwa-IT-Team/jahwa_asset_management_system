import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:jahwa_asset_management_system/models/app_info.dart';
import "package:jahwa_asset_management_system/models/user.dart";
import 'package:btprotocol/btprotocol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

// Uninitialized: 사용자가 로그인했는지 확인합니다. 이 상태에서는 스플래시 화면이 표시됩니다.
// Unauthenticated: 사용자가 인증되지 않았습니다. 이 상태에서는 자격 증명을 입력하기위한 로그인 페이지가 표시됩니다.
// Authenticating: 사용자가 로그인 버튼을 눌렀으며 사용자를 인증하고 있습니다. 이 상태에서는 진행률 표시 줄이 표시됩니다.
// Authenticated: 사용자가 인증되었습니다. 이 상태에서는 홈페이지가 표시됩니다.
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
const SHARED_USER_EMAIL = 'userEmail';
const SHARED_USER_PASSWD = 'userPassword';
const SHARED_LOGIN_CHECK = 'userLoginCheck';
const SHARED_CONNECTING_COMPANY = 'userConnectingCompany';

class UserRepository with ChangeNotifier {
  AppInfo _appInfo;
  Status _status = Status.Uninitialized;
  User _user;
  ConnectionInfo _connectionInfo;
  BluetoothDevice _bluetoothDevice;

  AppInfo get appInfo => _appInfo;
  Status get status => _status;
  User get user => _user;
  ConnectionInfo get connectionInfo => _connectionInfo;
  BluetoothDevice get bluetoothDevice => _bluetoothDevice;

  Future setLoginInfo(String email, String password, bool check) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(SHARED_USER_EMAIL, email);
    await _prefs.setString(SHARED_USER_PASSWD, password);
    await _prefs.setBool(SHARED_LOGIN_CHECK, check);
  }

  Future resetLoginInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    //String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "ko";
    await _prefs.remove(SHARED_USER_EMAIL);
    await _prefs.remove(SHARED_USER_PASSWD);
    await _prefs.setBool(SHARED_LOGIN_CHECK, false);
  }

  Future<bool> autoLogin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool check = _prefs.getBool(SHARED_LOGIN_CHECK) ?? false;

    print("Check Login Info...: $check");

    if (check) {
      String email = _prefs.getString(SHARED_USER_EMAIL);
      String password = _prefs.getString(SHARED_USER_PASSWD);
      return await signIn(email, password);
    } else {
      return false;
    }

    //return false;
  }

  /// 버전 체크
  /// -1 : 서버 버전 체크 오류
  /// 0 : 설치 버전 = 최신버전
  /// 1 : 설치 버전 < 최신버전
  Future<int> checkAppVersion() async {
    final PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    var url = 'https://japi.jahwa.co.kr/Download/GetAppVer';

    try {
      return await http
          .get(Uri.encodeFull(url),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<int>((http.Response response) {
            if (response.statusCode != 200 || response.body == null) {
              return -1;
            }
            if (response.statusCode == 200) {
              Iterable responseJson = jsonDecode(response.body);
              List<AppInfo> svrVerList =
                  responseJson.map((e) => AppInfo.fromJson(e)).toList();

              if (Platform.isAndroid) {
                _appInfo = svrVerList
                    .firstWhere((e) => e.platform.toUpperCase() == 'ANDROID');
              } else if (Platform.isIOS) {
                _appInfo = svrVerList
                    .firstWhere((e) => e.platform.toUpperCase() == 'IOS');
              } else {
                return 0;
              }

              debugPrint(
                  "Auto Version Check : ${appInfo.isAutoVersionCheck}, Server Version : ${appInfo.versionName}, Server Build : ${appInfo.versionCode} , Install Version : ${_packageInfo.version}, Install Build : ${_packageInfo.buildNumber}");

              if (!appInfo.isAutoVersionCheck) {
                return 0;
              }

              if (appInfo.versionName == _packageInfo.version &&
                  appInfo.versionCode.toString() == _packageInfo.buildNumber) {
                return 0;
              } else {
                return 1;
              }
            } else {
              return -1;
            }
          });
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      //await _auth.signInWithEmailAndPassword(email: email, password: password);

      // SERVER LOGIN API URL
      var url = 'https://japi.jahwa.co.kr/api/Auth/Login';

      // Store all data with Param Name.
      var data = {'id': email, 'password': password};

      print("SignIn Post Data  : ${json.encode(data)}");

      return await http
          .post(Uri.encodeFull(url),
              body: json.encode(data),
              headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15))
          .then<bool>((http.Response response) {
            print("Result SignIn : ${response.body}, (${response.statusCode})");
            if (response.statusCode != 200 || response.body == null) {
              return false;
            }
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body);
              _onAuthStateChanged(User.fromJson(responseJson));
              setLoginInfo(email, password, true);
              _initConnectionInfo();
              return true;
            } else {
              return false;
            }
          });
    } catch (e) {
      print(e.toString());
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _user = null;
    _status = Status.Unauthenticated;
    resetLoginInfo();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future changeConnectionCompany(String company) async {
    await _onChangeCompany(ConnectionInfo(company: company));
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
      resetLoginInfo();
    } else {
      _user = user;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<void> _initConnectionInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String company =
        _prefs.getString(SHARED_CONNECTING_COMPANY) ?? _user.company;

    _onChangeCompany(ConnectionInfo(company: company));
  }

  Future<void> _onChangeCompany(ConnectionInfo connection) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (connection == null) {
      _connectionInfo = null;
      await _prefs.remove(SHARED_CONNECTING_COMPANY);
    } else {
      _connectionInfo = connection;
      await _prefs.setString(SHARED_CONNECTING_COMPANY, connection.company);
    }
    notifyListeners();
  }

  Future<void> changeBluetooth(BluetoothDevice device) async {
    _bluetoothDevice = device;
    notifyListeners();
  }

  Future<void> _onChangeAppInfo(AppInfo info) async {
    if (info == null) {
      _appInfo = null;
    } else {
      _appInfo = info;
    }
    notifyListeners();
  }
}
