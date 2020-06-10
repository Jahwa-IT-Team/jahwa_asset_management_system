import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class InputEmail extends StatefulWidget {
  @override
  _InputEmailState createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          style: TextStyle(
            color: Colors.white,
          ),
          validator: (val) {
            if (val.isEmpty) {
              return getTranslated(context, 'required_field');
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.blue,
            labelText: getTranslated(context, 'login_email'),
            hintText: getTranslated(context, 'login_email_hint'),
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}