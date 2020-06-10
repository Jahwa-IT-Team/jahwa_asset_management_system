

import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

bool matchFn(item, keyword) {
  return (item.value
    .toString()
    .toLowerCase()
    .contains(keyword.toLowerCase()));
}

Widget customCardField({String label, Widget content}){
  
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom:
            BorderSide(width: 1.0, color: Colors.grey[300]),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        //verticalDirection:  direction,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              //padding: EdgeInsets.fromLTRB(14.0, 0.0, 0.0, 0.0),
              //child: label,
              child: Text(
                label, 
                softWrap: true, 
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),//Expanded(child: displayText) ,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Container(
                child: DefaultTextStyle(
                  child: content,
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
      ],)
    ),
  );
}

Widget customDropdown({Widget label, Function onTap, List<PickerItem> data, dynamic value, Widget hintValue}){
    
    Text displayText;
    //displayText = label;
    //textStyle = textStyle??TextStyle(fontSize: 13, color: Colors.black);

    if(data != null && value != null && value != ""){
      data.forEach((e) { 
        if(matchFn(e, value)) {
          displayText = e.text;
        }
      });
    }
    if(value == null || displayText == null || value == ""){
      displayText = hintValue??Text('Selected Item');
    }

    return InkWell(
      onTap:onTap,
      child: Row(
        //verticalDirection:  direction,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              //child: label,
              child: displayText,//Expanded(child: displayText) ,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Container(
                child: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
      ],)
      //child: label// Text($facilityTradeRequestRepository.requestDetailList[index].facilityGrade,),
    );
  }

  Alert customAlertOK(BuildContext context,String title, String desc){
    return Alert(
      context: context,
      type: AlertType.none,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed:  ()=> Navigator.pop(context),
          width: 120,
        )
      ],
    );
  }