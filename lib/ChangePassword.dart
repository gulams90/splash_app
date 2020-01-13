import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';

import 'models/CompanyData.dart';
import 'models/NameData.dart';
import 'models/UserData.dart';
import 'utils/LicenseUtils.dart';


class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => new _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final oldpwdController = TextEditingController();
  final newpwdController = TextEditingController();
  bool isOldPwd = true;
  bool isNewPwd = true;
  String _opError="This field should not be empty.";
  String _npError="This field should not be empty.";

  bool _obscureTextOldPwd=true;
  bool _obscureTextNewPwd=true;

  UserData userData;
  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strUserId;
  String strTitle="Change Password";

  ProgressDialog pr;
  bool isFirst=true;


//  @override
//  void initState() {
//    super.initState();
//    print("UserTypeScreen initState................");
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strUserId= prefs.getString(PreferenceUtils.PREF_USERID);
    pr = CommonUtils.getProgressDialog(context);
    if(strUserId!=null) {
      getEditDetails(strUserId);
    }
  }


  void saveData(var newPwd) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_USER).child(strUserId);

    _companyRef.child("password").set(newPwd).whenComplete(() {
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);
      goBack();
    }).catchError((e) => print(e));

  }


  void goBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void setTextFieldValue(String value,TextEditingController controller){
    try{
      if(value!=null&&value.length>0){
        controller.text=value;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getEditDetails(String strId){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER).child(strId);

      myRef.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          UserData bd = UserData.fromSnapshot(snapshot);
          if(bd!=null){
            userData=bd;
          }
        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  validate() {
    var oldpwd = oldpwdController.text.trim();
    var newpwd = newpwdController.text.trim();

    if (oldpwd.length > 0 &&newpwd.length>=6) {

      if(oldpwd==userData.password) {
        saveData(newpwd);
      }else{
        setState(() {
          isOldPwd = false;
          _opError="Wrong password.";
        });
      }

    } else {
      if (oldpwd.length == 0) {
        setState(() {
          isOldPwd = false;
          _opError="This field should not be empty.";
        });
      }

      if (newpwd.length < 6) {
        setState(() {
          isNewPwd = false;
          _npError="Password must be greater than or eqaul to 6 digit.";
        });
      }

    }
  }


  @override
  Widget build(BuildContext context) {

    final oldpasswordField = TextField(
      onChanged: (value) {
        setState(() {isOldPwd = true;});
      },
      controller: oldpwdController,
      obscureText: _obscureTextOldPwd,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Old Password",
          errorText: isOldPwd ? null : _opError,
          suffixIcon: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onTap: () {
              setState(() {
                _obscureTextOldPwd = !_obscureTextOldPwd;
              });
            },
            child: Icon(
              _obscureTextOldPwd ? Icons.visibility : Icons.visibility_off,
              semanticLabel: _obscureTextOldPwd ? 'show password' : 'hide password',
            ),
          ),
          border:outlineInputBorder),
    );


    final newpasswordField = TextField(
      onChanged: (value) {
        setState(() {isNewPwd = true;});
      },
      controller: newpwdController,
      obscureText: _obscureTextNewPwd,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "New Password",
          errorText: isNewPwd ? null : _npError,
          suffixIcon: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onTap: () {
              setState(() {
                _obscureTextNewPwd = !_obscureTextNewPwd;
              });
            },
            child: Icon(
              _obscureTextNewPwd ? Icons.visibility : Icons.visibility_off,
              semanticLabel: _obscureTextNewPwd ? 'show password' : 'hide password',
            ),
          ),
          border:outlineInputBorder),
    );

    final submitButon = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Theme.of(context).accentColor,
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width,
        padding: edgeInsets,
        onPressed: () {
          validate();

        },
        child: Text("Update",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    if(isFirst){
      isFirst=false;
      initData();
    }

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(strTitle),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed:() => Navigator.pop(context, false),
          )
      ),
      body:
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                SizedBox(height: 20.0),
                oldpasswordField,
                SizedBox(height: 15.0),
                newpasswordField,
                SizedBox(
                  height: 35.0,
                ),
                submitButon,
                SizedBox(
                  height: 25.0,
                )
              ],
            ),
          ),
        ),
      ),

    );
  }



}