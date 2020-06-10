import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';


class InputPassword extends StatefulWidget {
  @override
  _InputPasswordState createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          style: TextStyle(
            color: Colors.white,
          ),
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'login_password'),
            hintText: getTranslated(context, 'login_password_hint'),
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}