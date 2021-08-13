// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
//import 'package:jahwa_asset_management_system/models/language.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//Import Login Widgets
import 'package:jahwa_asset_management_system/screens/login/widgets/login_title.dart';
import 'package:jahwa_asset_management_system/models/language.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  // Getting value from TextField widget.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  ProgressDialog pr;
  String _langCode = "";

  String validateEmail(String value) {
    if (!value.contains('@')) {
      return getTranslated(context, 'login_validateEmail');
    }
    return null;
  }

  String validatePasswrd(String value) {
    if (value.length < 6) {
      return getTranslated(context, 'login_validatePassword');
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    pr.style(
      message: getTranslated(context, 'Login'),
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Colors.white]),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    PopupMenuButton<String>(
                      // overflow menu
                      onSelected: changeLanguage,
                      icon: new Icon(Icons.language, color: Colors.black45),
                      itemBuilder: (BuildContext context) {
                        return Language.languageList()
                            .map<PopupMenuItem<String>>((Language choice) {
                          return PopupMenuItem<String>(
                            value: choice.languageCode,
                            child: Text(choice.flag + " " + choice.name),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                LoginTitle(),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _key,
                  child: Column(
                    children: <Widget>[
                      inputEmail(),
                      //Input Password
                      inputPassword(),
                      //Button Login
                      submitLogin(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //로그인 E-Mail 주소 텍스트 박스
  Widget inputEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 50, right: 50),
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          controller: emailController,
          style: TextStyle(
            color: Colors.green[400],
          ),
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.blue,
            labelText: getTranslated(context, 'login_email'),
            hintText: getTranslated(context, 'login_email_hint'),
            labelStyle: TextStyle(
              color: Colors.black54,
            ),
            hintStyle: TextStyle(
              color: Colors.green[300],
            ),
          ),
        ),
      ),
    );
  }

  //로그인 패스워드 텍스트 박스
  Widget inputPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          controller: passwordController,
          style: TextStyle(
            color: Colors.green[400],
          ),
          validator: validatePasswrd,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'login_password'),
            hintText: getTranslated(context, 'login_password_hint'),
            labelStyle: TextStyle(
              color: Colors.black54,
            ),
            hintStyle: TextStyle(
              color: Colors.green[300],
            ),
          ),
        ),
      ),
    );
  }

  Widget submitLogin() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 50, left: 50),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black87,
          //     blurRadius: 3.0, // has the effect of softening the shadow
          //     spreadRadius: 0.5, // has the effect of extending the shadow
          //     offset: Offset(
          //       2.0, // horizontal, move right 10
          //       2.0, // vertical, move down 10
          //     ),
          //   ),
          // ],
          color: Colors.blue,
          borderRadius: BorderRadius.circular(3),
        ),
        child: TextButton(
          onPressed: () {
            if (_key.currentState.validate()) {
              pr.show();
              print(
                  "Email : ${emailController.text}, Password : ${passwordController.text}");
              UserRepository $userRepository = Provider.of<UserRepository>(
                  _key.currentContext,
                  listen: false);
              $userRepository
                  .signIn(emailController.text, passwordController.text)
                  .then((value) {
                pr.hide();
                if (value) {
                  //Login Success
                  print("Login Success");
                  Navigator.popAndPushNamed(context, homeRoute);
                } else {
                  //Login Fail
                  print("Login Fail");
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "Error",
                    desc: "Login Fail.",
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
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                getTranslated(context, 'login_button_text'),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
