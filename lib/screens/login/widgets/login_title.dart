import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class LoginTitle extends StatefulWidget {
  @override
  _LoginTitleState createState() => _LoginTitleState();
}

class _LoginTitleState extends State<LoginTitle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 0.0),
      child: Container(
        //color: Colors.green,
        //height: 260,
        //width: 250,
        
        alignment: Alignment.bottomRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset('lib/assets/image/logo.png', width: 350, fit: BoxFit.cover),
              padding: EdgeInsets.only(left: 2, right: 2, bottom: 10),
            ),
            //Image.asset("assets/image/logo.gif",fit: BoxFit.cover),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                getTranslated(context, 'login_title'),
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}