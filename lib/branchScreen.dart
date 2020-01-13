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


class branchScreen extends StatefulWidget {
  @override
  _branchScreenState createState() => new _branchScreenState();
}

class _branchScreenState extends State<branchScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  bool isName = true;
  bool isMobile = true;
  bool isEmail = true;
  bool isAddress = true;
  bool isCity = true;
  bool isState = true;

  String _nameError="This field should not be empty.";
  var _emailError="";
  var _mobileError="";

  int createdTime;
  CompanyData nameData;
  CompanyData companyData;
  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strEditId;
  var isNameAvailable=0;
  String strTitle="Add Branch";
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
    strEditId= ModalRoute.of(context).settings.arguments;
    pr = CommonUtils.getProgressDialog(context);
    if(strEditId!=null) {
      setState(() {
        strTitle="Edit Branch";
      });
      getEditDetails(strEditId);
    }else{
      getCompanyDetails(strOrgId);
    }
  }


  void getCompanyDetails(String strOrgId){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_COMPANY).child(strOrgId);

      myRef.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          CompanyData bd = CompanyData.fromSnapshot(snapshot);

          if(bd!=null){
            companyData=bd;
            setTextFieldValue(bd.mobile, mobileController);
            setTextFieldValue(bd.email, emailController);
            setTextFieldValue(bd.city, cityController);
            setTextFieldValue(bd.state, stateController);
          }

        }
      });

    } catch (e) {
      print(e.toString());
    }

  }


  void saveData(var name,var mobile,var email,var address,var city,var state) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_BRANCH).child(strOrgId);

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

    CompanyData bd=null;
    //Add
    if(nameData==null){
      if(companyData!=null){
        bd=new CompanyData(id, name, email, mobile, address, city, state, companyData.country, CommonUtils.defaultCountryCode, null, strOrgId, 0, createdTime, modifedTime, LicenseUtils.ACTIVATED);
      }else{
        bd=new CompanyData(id, name, email, mobile, address, city, state, null, CommonUtils.defaultCountryCode, null, strOrgId, 0, createdTime, modifedTime, LicenseUtils.ACTIVATED);
      }

    }
    //Edit
    else{
      bd=new CompanyData(id, name, email, mobile, address, city, state, nameData.country, CommonUtils.defaultCountryCode, null, strOrgId, 0, createdTime, modifedTime, nameData.license);
    }



    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
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
      isNameAvailable=0;
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_BRANCH);
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
                      isNameAvailable = 1;
                      setState(() {
                        isName = false;
                        _nameError ="Already exist.";
                      });
                    }
                    //Edit
                    else{
                      if(bd.id!=nameData.id){
                        isNameAvailable = 1;
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

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_BRANCH).child(strOrgId).child(strId);

      myRef.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          CompanyData bd = CompanyData.fromSnapshot(snapshot);

          if(bd!=null){
            nameData=bd;
            createdTime=nameData.createdTime;
            setTextFieldValue(bd.name, nameController);
            setTextFieldValue(bd.mobile, mobileController);
            setTextFieldValue(bd.email, emailController);
            setTextFieldValue(bd.address, addressController);
            setTextFieldValue(bd.city, cityController);
            setTextFieldValue(bd.state, stateController);
          }


        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  validate() {

    var name = nameController.text.trim();
    var mobile = mobileController.text.trim();
    var emailId = emailController.text.trim();
    var address = addressController.text.trim();
    var city = cityController.text.trim();
    var state = stateController.text.trim();

    if (name.length > 0&&isNameAvailable==0 &&mobile.length > 0&&mobile.length== 10 &&emailId.length > 0 && EmailValidator.Validate(emailId)
        &&address.length > 0&&city.length>0&&state.length>0) {

      saveData(name,mobile,emailId,address,city,state);

    } else {
      if (name.length == 0) {
        setState(() {
          isName = false;
          _nameError="This field should not be empty.";
        });
      }else if(isNameAvailable==1){
        setState(() {
          isName = false;
          _nameError="Already exist.";
        });
      }

      if (mobile.length == 0) {
        setState(() {isMobile = false;
        _mobileError="Enter mobile number";});
      }else if(mobile.length != 10){
        setState(() {isMobile = false;
        _mobileError="Enter 10 digit mobile number";});
      }

      if (emailId.length == 0) {
        setState(() {isEmail = false;
        _emailError="Enter email id";});
      }else if(!EmailValidator.Validate(emailId)){
        setState(() {isEmail = false;
        _emailError="Enter valid email id";});
      }



      if (address.length == 0) {
        setState(() {isAddress = false;});
      }

      if (city.length == 0) {
        setState(() {isCity = false;});
      }

      if (state.length == 0) {
        setState(() {isState = false;});
      }



    }
  }

  @override
  Widget build(BuildContext context) {

//    PreferenceUtils.getInstance();

//    final String strOrgId = ModalRoute.of(context).settings.arguments;

//    MaterialPageRoute(
//        builder: (context) => DetailScreen(),
//        // Pass the arguments as part of the RouteSettings. The
//        // DetailScreen reads the arguments from these settings.
//        settings: RouteSettings(
//          arguments: todos[index],
//        )

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
          labelText: "Name",
          errorText: isName ? null : "Enter name",
          border:outlineInputBorder),
    );


    final mobileField = TextField(
      onChanged: (value) {

        try{
          var mobile = mobileController.text.trim();

          if(mobile.length==10){
            setState(() {isMobile = true;});
          }else{
            setState(() {isMobile = false;
            _mobileError="Enter 10 digit mobile number";});
          }
        }catch (e){
          print(e.toString());
        }


      },
      controller: mobileController,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Mobile Number",
          errorText: isMobile ? null : _mobileError,
          border:outlineInputBorder),
    );

    final emailField = TextField(
      onChanged: (value) {
        setState(() {isEmail = true;});
      },
      controller: emailController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Email",
          errorText: isEmail ? null : _emailError,
          border:outlineInputBorder),
    );



    final addressField = TextField(
      onChanged: (value) {
        setState(() {isAddress = true;});
      },
      controller: addressController,
      obscureText: false,
      style: style,
      maxLines: 3,
      minLines: 3,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Address",
          errorText: isAddress ? null : "Enter address",
          border:outlineInputBorder),
    );


    final cityField = TextField(
      onChanged: (value) {
        setState(() {isCity = true;});
      },
      controller: cityController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "City",
          errorText: isCity ? null : "Enter city",
          border:outlineInputBorder),
    );

    final stateField = TextField(
      onChanged: (value) {
        setState(() {isState = true;});
      },
      controller: stateController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "State",
          errorText: isState ? null : "Enter state",
          border:outlineInputBorder),
    );


    final loginButon = Material(
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


//    String strOrgId = prefs.getString(PreferenceUtils.PREF_COMPANYID);
//    if(strOrgId!=null) {
//      getCompanyDetails(strOrgId);
//    }





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
                SizedBox(height: 15.0),
//                rowMobile,
                mobileField,
                SizedBox(height: 15.0),
                emailField,
                SizedBox(height: 15.0),
                addressField,
                SizedBox(height: 15.0),
                cityField,
                SizedBox(height: 15.0),
                stateField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
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