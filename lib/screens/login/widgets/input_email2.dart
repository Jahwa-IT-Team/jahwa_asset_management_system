import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';

class InputEmail2 extends StatefulWidget {
  @override
  _InputEmail2State createState() => _InputEmail2State();
}

class _InputEmail2State extends State<InputEmail2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
            validator: (val) {
              if (val.isEmpty) {
                return getTranslated(context, 'required_field');
                // return DemoLocalization.of(context).translate('required_fiedl');
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: getTranslated(context, 'name'),
              hintText: getTranslated(context, 'name_hint'),
            ),
          ),
      ),
    );
  }
}