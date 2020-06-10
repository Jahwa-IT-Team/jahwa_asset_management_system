import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
//언어코드 참조
//https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html
const String KOREAN = 'ko';
const String VIETNAMESE = 'vi';


Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "ko";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case KOREAN:
      return Locale(KOREAN, '');
    case VIETNAMESE:
      return Locale(VIETNAMESE, '');
    default:
      return Locale(KOREAN, '');
  }
}

Future<String> getLanguageCode() async{
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(LAGUAGE_CODE) ?? "ko";
}

Future<String> getLanguageCodeWithCountryCode() async{
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String rtnCode = "ko-KR";
  switch (_prefs.getString(LAGUAGE_CODE)) {
    case 'ko':
      rtnCode = "ko-KR";
      break;
    case 'vi':
      rtnCode = "vi-VN";
      break;
    case 'zh':
      rtnCode = "zh-CN";
      break;
    default:
      rtnCode = "ko-KR";
      break;
  }
  return rtnCode;
}

String getLanguageName(String languageCode){
  switch (languageCode) {
    case KOREAN:
      return 'Korean';
    case VIETNAMESE:
      return 'Vietnamese';
    default:
      return 'Korean';
  }
}

String getTranslated(BuildContext context, String key) {
  try{
    String text = Localization.of(context).translate(key);
    if(text != null){
      return text;
    }else{
      return key;
    }
  }catch (_){
    return key;
  }
}