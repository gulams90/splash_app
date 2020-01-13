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


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final mobileController = TextEditingController();
  final newpwdController = TextEditingController();
  bool isMobile = true;
  bool isNewPwd = true;
  String _mobileError="This field should not be empty.";
  String _npError="This field should not be empty.";

  bool _obscureTextNewPwd=true;

  UserData userData;
  final database = FirebaseDatabase.instance;
  String strTitle="Reset Password";

  ProgressDialog pr;
  bool isFirst=true;


//  @override
//  void initState() {
//    super.initState();
//    print("UserTypeScreen initState................");
//    initData();
//  }

  initData() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
//    strUserId= prefs.getString(PreferenceUtils.PREF_USERID);
    pr = CommonUtils.getProgressDialog(context);
//    if(strUserId!=null) {
//      getEditDetails(strUserId);
//    }
  }


  void saveData(var mobileNumber,var newPwd) async  {


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qref=myRef.orderByChild("mobile").equalTo(mobileNumber);
      bool isLogin = false;
      CommonUtils.showProgressBar( pr);
      qref.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          print("snap.hasData " + " " + mobileNumber);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;

          UserData udata=null;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                print("key " + key);
                print("val " + values["mobile"]);
                UserData bd = UserData.fromJson(values);
                if (bd != null) {
//                  print("from bd " + bd.mobile + " " + mobile);

                  if (bd.mobile == mobileNumber) {
                    isLogin=true;
                    udata=bd;
                  } else {

                  }
                }
              }
            });
          }


          if(isLogin&&udata!=null){
            DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_USER).child(udata.id);

            _companyRef.child("password").set(newPwd).whenComplete(() {
              CommonUtils.hideProgressBar(pr);
              CommonUtils.showToast("Password Updated!");
              goBack();
            }).catchError((e) => print(e));

          }else{
            CommonUtils.hideProgressBar(pr);
            setState(() {
              isMobile = false;
              _mobileError="Mobile number not registered.";
            });
          }

        }
      });

    } catch (e) {
      print(e.toString());
    }




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



  validate() {
    var mobileNumber = mobileController.text.trim();
    var newpwd = newpwdController.text.trim();

    if (mobileNumber.length > 0 &&mobileNumber.length==10  &&newpwd.length>=6) {

      saveData(mobileNumber,newpwd);

    } else {
      if (mobileNumber.length == 0) {
        setState(() {
          isMobile = false;
          _mobileError="This field should not be empty.";
        });
      }else if(mobileNumber.length != 10){
        setState(() {
          isMobile = false;
          _mobileError="Enter valid mobile number";
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

    final mobileField = TextField(
      onChanged: (value) {
        setState(() {isMobile = true;});
      },
      controller: mobileController,
      obscureText: false,
      keyboardType: TextInputType.phone,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Mobile Number",
          errorText: isMobile ? null : _mobileError,
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
        child: Text("Reset Password",
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
                mobileField,
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