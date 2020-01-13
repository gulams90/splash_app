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


class UserScreen extends StatefulWidget {

  @override
  _UserScreenState createState() => new _UserScreenState();
}



class _UserScreenState extends State<UserScreen> {


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


  bool isName = true;
  bool isMobile = true;
  bool isEmail = true;
  bool _obscureText=true;
  bool statusValue=false;

  String strTitle="Add User";

  var _emailError="";
  var _mobileError="";

  var isMobileNumberAvailable=0;
  ProgressDialog pr;
  bool isFirst=true;
  List<NameData> alUserType=new List();
  NameData selectedData;

  int createdTime;
  UserData userData;

  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strEditId;

  bool isUserTypeVisible=true;

//  @override
//  void initState() {
//    super.initState();
//    print("regCompany initState................");
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strEditId= ModalRoute.of(context).settings.arguments;
    pr = CommonUtils.getProgressDialog(context);
    if(strEditId!=null) {
      setState(() {
        strTitle="Edit User";
      });
    }

    getUserType();
  }

  void getUserType(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USERTYPE).child(strOrgId);
      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            alUserType.clear();
            values.forEach((key, values) {
              if (values != null) {
                NameData bd = NameData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.name );
                  alUserType.add(bd);

                }
              }
            });


            setState(() {
              alUserType;
            });

          }
          if(strEditId!=null) {
            getEditDetails(strEditId);
          }

        }
      });

//      subscriptionEntryAdded=myRef.onChildAdded.listen(_onEntryAdded);
//      subscriptionEntryChanged= myRef.onChildChanged.listen(_onEntryChanged);

    } catch (e) {
      print(e.toString());
    }

  }



  void saveUserInfo(var name,var mobile,var email,var password) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_USER);

    String id=null;
    String fcmToken=null;
    if(userData!=null){
      id=userData.id;
      fcmToken=userData.fcmToken;
    }else{
      id= _companyRef.push().key;
    }

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    if(createdTime==0){
      createdTime=modifedTime;
    }


//    String password=random();
    UserData bd=null;
    if(selectedData!=null){
      bd=new UserData(id, name, null, email, CommonUtils.defaultCountryCode, mobile, fcmToken, selectedData.id, null, null, null, password,statusValue, strOrgId, 0, createdTime, modifedTime);
    }else{
      bd=new UserData(id, name, null, email, CommonUtils.defaultCountryCode, mobile, fcmToken, null, null, null, null, password,statusValue, strOrgId, 0, createdTime, modifedTime);
    }


    CommonUtils.showProgressBar( pr);
    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
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


  void checkMobileNumberExistUser(){


    try {
      var mobile = mobileController.text.trim();
      isMobileNumberAvailable=0;
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qref=myRef.orderByChild("mobile").equalTo(mobile);

      qref.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          print("snap.hasData " + " " + mobile);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          bool isMobileExist = false;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                print("key " + key);
                print("val " + values["mobile"]);
                UserData bd = UserData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.mobile + " " + mobile);

                  if (bd.mobile == mobile) {
                    //Add
                    if (userData == null) {
                      isMobileNumberAvailable = 1;
                      isMobileExist = true;
                      setState(() {
                        isMobile = false;
                        _mobileError =
                        "Mobile already exist with different account.";
                      });
                    }
                  } else {
                      if(userData.id!=bd.id){
                        isMobileNumberAvailable = 1;
                        isMobileExist = true;
                        setState(() {
                          isMobile = false;
                          _mobileError =
                          "Mobile already exist with different account.";
                        });
                      }
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

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER).child(strId);
      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          UserData bd = UserData.fromSnapshot(snapshot);

          if(bd!=null){
            userData=bd;
            print(bd.name);
            createdTime=userData.createdTime;
            setTextFieldValue(bd.name, nameController);
            setTextFieldValue(bd.mobile, mobileController);
            setTextFieldValue(bd.email, emailController);

            if(bd.notification){
              setState(() {
                statusValue=true;
              });
            }

            if(userData.userType!=null){
            for(int i=0;i<alUserType.length;i++){
              NameData nd=alUserType[i];
            if(nd.id==userData.userType){
              setState(() {
                selectedData=nd;
              });

            }

            }
            }


            if(userData.userType==null){
              setState(() {
                isUserTypeVisible=false;
              });

            }

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


    if (name.length > 0 &&mobile.length > 0&&mobile.length== 10 &&isMobileNumberAvailable==0&&(emailId.length==0||(emailId.length > 0 && EmailValidator.Validate(emailId)))) {

      //Edit
      if(userData!=null){
        saveUserInfo(name,mobile,emailId,userData.password);
      }
      //Add
      else{
//        String password=random();
        String password="123456";
        if(selectedData != null) {
          saveUserInfo(name, mobile, emailId, password);
        }else{
          CommonUtils.showToast("Select User type!");
        }
      }

    } else {
      if (name.length == 0) {
        setState(() {isName = false;});
      }

      if (mobile.length == 0) {
        setState(() {isMobile = false;
        _mobileError="Enter mobile number";});
      }else if(mobile.length != 10){
        setState(() {isMobile = false;
        _mobileError="Enter 10 digit mobile number";});
      }

       if(emailId.length >0&&!EmailValidator.Validate(emailId)){
        setState(() {isEmail = false;
        _emailError="Enter valid email id";});
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
        setState(() {isName = true;});
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

//    void _onCountryChange(CountryCode countryCode) {
//      //Todo : manipulate the selected country code here
//      print("New Country selected: " + countryCode.toString());
//      defaultCountryCode=countryCode.toString();
//    }
//
//    final countryPickerField= CountryCodePicker(
//      onChanged:_onCountryChange,
//      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
//      initialSelection: 'IN',
//      favorite: [defaultCountryCode,'IN'],
//      // optional. Shows only country name and flag
//      showCountryOnly: false,
//      // optional. Shows only country name and flag when popup is closed.
//      showOnlyCountryWhenClosed: false,
//      // optional. aligns the flag and the Text left
//      alignLeft: false,
//
//
//    );



    final mobileField = TextField(
      onChanged: (value) {

        try{
          var mobile = mobileController.text.trim();

          if(mobile.length==10){
            setState(() {isMobile = true;});
            checkMobileNumberExistUser();

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

//    final rowMobile= Row(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//      Container(
//          width: 75.0,
//          child: countryPickerField,
//          margin: EdgeInsets.fromLTRB(0, 0, 0, 5.0),
//          decoration:BoxDecoration(color: Colors.grey)
//
//        ),
//
//
//        Expanded(child:Container(
//          child: mobileField,
//          margin: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
//        )
//        )
//      ],
//    );


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


    final ddUserType=Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color: Theme.of(context).accentColor, style: BorderStyle.solid, width: 0.80),
      ),
      child:DropdownButton<NameData>(
      isExpanded: true,
      hint:  Text("Select User Type"),
      value: selectedData,
      onChanged: (NameData Value) {
        print("OnChange : "+Value.name);
        setState(() {
          selectedData = Value;
        });
      },
      items: alUserType.map((NameData data) {
        return  DropdownMenuItem<NameData>(
          value: data,
          child: Row(
            children: <Widget>[
              SizedBox(width: 10,),
              Text(
                data.name,
                style:  style,
              ),
            ],
          ),
        );
      }).toList(),
    ));

    final chkStatus=CheckboxListTile(
      title: Text("Enable Notification?",style: style,),
      value: statusValue,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool value) {
        setState(() {
          statusValue = value;
        });
      },
    );

    final submitButton = Material(
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
                chkStatus,
                SizedBox(height: 15.0),
                Visibility(
                  child:ddUserType,
                  visible: isUserTypeVisible,
                ),

                SizedBox(
                  height: 35.0,
                ),
                submitButton,
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


//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text('HomeScreen'),
//      ),
//      body: new Center(
//        child: new Text('Welcome to Home.!'),
//      ),
//    );
//  }

}