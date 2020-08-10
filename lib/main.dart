import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'provider/facility_trade_common_repository.dart';
import 'provider/facility_trade_request_repository.dart';
import 'provider/facility_trade_send_repository.dart';
import 'provider/facility_trade_receive_repository.dart';
import "provider/user_repository.dart";
import 'util/localization/language_constants.dart';


//void main() => runApp(MyApp());
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  //runApp(MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRepository(),),
        ChangeNotifierProvider(create: (_) => FacilityTradeCommonRepository(),),
        ChangeNotifierProvider(create: (_) => FacilityTradeRequestRepository(),),
        ChangeNotifierProvider(create: (_) => FacilityTradeSendRepository(),),
        ChangeNotifierProvider(create: (_) => FacilityTradeReceiveRepository(),),
        ChangeNotifierProvider(create: (_) => FacilityLocationRepository(),),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute; // = isLogged ? errorRoute:loginRoute;
  Locale _locale;
  bool checkLoginInfo = false;
  bool checkAutoLogin = false;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
   
    FacilityTradeCommonRepository $facilityTradeCommonRepository = Provider.of<FacilityTradeCommonRepository>(context, listen:true);
    if(!$facilityTradeCommonRepository.firstInit){
      $facilityTradeCommonRepository.init();
    }
    
    if(this.checkAutoLogin == false){
      UserRepository $userRepository = Provider.of<UserRepository>(context, listen: false);
        $userRepository.autoLogin().then((value){
          print("Auto Check $value");
          if(value){
            initialRoute = homeRoute;
          }else{
            initialRoute = loginRoute;
          }
          print("InitalRoute1 : $initialRoute");
          
          setState(() {
            this.checkLoginInfo = true;
          });
        });
        checkAutoLogin = true;
    }
    if (this._locale == null || this.checkLoginInfo == false) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Jahwa Asset Management",
        theme: ThemeData(primarySwatch: Colors.green, textTheme: TextTheme(headline6: TextStyle(color: Colors.white))),
        locale: _locale,
        supportedLocales: [
          Locale("ko",""),
          Locale("vi", ""),
        ],
        localizationsDelegates: [
          Localization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
                debugPrint("*language locale is null!!!");
                    return supportedLocales.first;
          }
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        onGenerateRoute: CustomRouter.generatedRoute,
        initialRoute: initialRoute, // loginRoute,
        
      );
    }
  }
}
