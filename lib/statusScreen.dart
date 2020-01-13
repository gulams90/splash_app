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


class statusScreen extends StatefulWidget {
  @override
  _statusScreenState createState() => new _statusScreenState();
}

class _statusScreenState extends State<statusScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final nameController = TextEditingController();
  bool isName = true;
  String _nameError="This field should not be empty.";

  int createdTime;
  NameData nameData;
  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strEditId;
  var isMobileNumberAvailable=0;
  String strTitle="Add Status";
  ProgressDialog pr;
  bool isFirst=true;
  bool statusValue=false;

//  @override
//  void initState() {
//    super.initState();
//    print("UserTypeScreen initState................");
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strEditId= ModalRoute.of(context).settings.arguments;
    pr = CommonUtils.getProgressDialog(context);
    if(strEditId!=null) {
      setState(() {
        strTitle="Edit Status";
      });
      getEditDetails(strEditId);
    }
  }


  void saveData(var name) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_STATUS).child(strOrgId);

    String id=null;
    if(nameData!=null){
      id=nameData.id;
    }else{
      id= _companyRef.push().key;
    }

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    if(createdTime==0){
      createdTime=modifedTime;
    }


    NameData bd=new NameData(id, name, null, statusValue, strOrgId, 0, createdTime, modifedTime);
    CommonUtils.showProgressBar( pr);
    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);
      goBack();
    }).catchError((e) => print(e));

  }



  String random() {
    Random generator = new Random();

    int num = generator.nextInt(99999) + 99999;
    if (num < 100000 || num > 999999) {
      num = generator.nextInt(99999) + 99999;
      if (num < 100000 || num > 999999) {
        throw new Exception("Unable to generate PIN at this time..");
      }
    }
    return num.toString();
  }

  void goBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }


  void checkNameExist(){


    try {
      var name = nameController.text.trim();
      isMobileNumberAvailable=0;
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_STATUS);
      Query qref=myRef.orderByChild("name").equalTo(name);
      qref.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          print("snap.hasData " + " " + name);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                NameData bd = NameData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.name + " " + name);

                  if (bd.name == name) {

                    //Add
                    if(nameData==null){
                      isMobileNumberAvailable = 1;
                      setState(() {
                        isName = false;
                        _nameError ="Already exist.";
                      });
                    }
                    //Edit
                    else{
                      if(bd.id!=nameData.id){
                        isMobileNumberAvailable = 1;
                        setState(() {
                          isName = false;
                          _nameError ="Already exist.";
                        });
                      }
                    }



                  } else {

                  }
                }
              }
            });
          }

        }
      });

    } catch (e) {
      print(e.toString());
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

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_STATUS).child(strOrgId).child(strId);
      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          NameData bd = NameData.fromSnapshot(snapshot);

          if(bd!=null){
            nameData=bd;
            setTextFieldValue(bd.name, nameController);
            setState(() {
              statusValue=bd.status;
            });
            createdTime=nameData.createdTime;
          }


        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  validate() {
    var name = nameController.text.trim();

    if (name.length > 0 &&isMobileNumberAvailable==0) {

      saveData(name);

    } else {
      if (name.length == 0) {
        setState(() {
          isName = false;
          _nameError="This field should not be empty.";
        });
      }else if(isMobileNumberAvailable==1){
        setState(() {
          isName = false;
          _nameError="Already exist.";
        });
      }



    }
  }


  @override
  Widget build(BuildContext context) {


    if(isFirst){
      isFirst=false;
      initData();
    }



    final nameField = TextField(
      onChanged: (value) {
        try{
          var name = nameController.text.trim();

          if(name.length>0){
            checkNameExist();
          }
        }catch (e){
          print(e.toString());
        }

      },
      controller: nameController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Status Name",
          errorText: isName ? null : _nameError,
          border:outlineInputBorder),
    );


//    final chkStatus=Column(
//      mainAxisAlignment: MainAxisAlignment.start,
//      children: <Widget>[
//        Text("Is Active?",style: style,),
//        Checkbox(
//          value: statusValue,
//          onChanged: (bool value) {
//            setState(() {
//              statusValue = value;
//            });
//          },
//        ),
//      ],
//    );

    final chkStatus=CheckboxListTile(
                      title: Text("Is Active?",style: style,),
                      value: statusValue,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool value) {
                        setState(() {
                          statusValue = value;
                        });
                      },
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
        child: Text("Save",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

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
                nameField,
                SizedBox(height: 20.0),
                chkStatus,
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