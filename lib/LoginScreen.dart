//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';

import 'models/UserData.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextStyle styleFooter = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets=EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder=OutlineInputBorder(borderRadius: BorderRadius.circular(10.0));

  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  bool isMobile = true;
  bool isPassword = true;
  bool _obscureText = true;
  String strMobileError="Enter mobile number";

//  SharedPreferences prefs =  SharedPreferences.getInstance() as SharedPreferences;
  final database = FirebaseDatabase.instance;
//  final databaseReference = Firestore.instance;

  ProgressDialog pr;
  bool isFirst=true;
  SharedPreferences prefs;

  initData() async {
    prefs = await SharedPreferences.getInstance();
    bool isLogin=prefs.getBool(PreferenceUtils.PREF_LOGIN_STATUS);
    pr = CommonUtils.getProgressDialog(context);
//    if(isLogin) {
//      Navigator.of(this.context).pushReplacementNamed("/HomeScreen");
//    }
  }

  void loginRequest(String mobile,String password) {


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qref=myRef.orderByChild("mobile").equalTo(mobile);
      CommonUtils.showProgressBar( pr);
      qref.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          print("snap.hasData " + " " + mobile);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          bool isLogin = false;
          UserData udata=null;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                print("key " + key);
                print("val " + values["mobile"]);
                UserData bd = UserData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.mobile + " " + mobile);

                  if (bd.mobile == mobile&&bd.password==password) {
                    isLogin=true;
                    udata=bd;
                  } else {

                  }
                }
              }
            });
          }


          if(isLogin&&udata!=null){
            PreferenceUtils.saveBoolean(prefs,PreferenceUtils.PREF_LOGIN_STATUS, true);
            PreferenceUtils.saveString(prefs,PreferenceUtils.PREF_COMPANYID, udata.orgId);
            PreferenceUtils.saveString(prefs,PreferenceUtils.PREF_USERID, udata.id);
            PreferenceUtils.saveString(prefs,PreferenceUtils.PREF_USERNAME, udata.name);
            Navigator.of(this.context).pushReplacementNamed("/homeScreen");
//            Navigator.of(this.context).pushReplacementNamed("/HomeScreen");

          }else{
            setState(() {
              isMobile = false;
              strMobileError="Invalid mobile or password";
            });
          }

        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  void login(){
    var mobileNumber=mobileController.text.trim();
    var password=passwordController.text.trim();

    if(mobileNumber.length>0&&mobileNumber.length==10&&password.length>0){
      loginRequest(mobileNumber, password);
//        showToast(mobileController.text+" "+passwordController.text);
    }else{
      if(mobileNumber.length==0){
        isMobile=false;
        strMobileError="Enter mobile number";
        setState(() {});
      }if(mobileNumber.length!=10){
        isMobile=false;
        strMobileError="Enter valid mobile number";
        setState(() {});
      }
      if(password.length==0){
        isPassword=false;
        setState(() {});
      }
    }

  }


  @override
  Widget build(BuildContext context) {


    if(isFirst){
      isFirst=false;
      initData();
    }

    TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 25.0,fontWeight:FontWeight.bold,color: Theme.of(context).primaryColor);

    final emailField = TextField(
      onChanged: (value){
        isMobile = true;
        setState(() {});
      },
      controller: mobileController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Mobile",
          errorText: isMobile?null:strMobileError,
          border: outlineInputBorder),
    );


    final passwordField = TextField(
      onChanged: (value){
        isPassword = true;
        setState(() {});
      },
      controller: passwordController,
      obscureText: _obscureText,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Password",
          errorText: isPassword?null:"Enter password",
          suffixIcon: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              semanticLabel: _obscureText ? 'show password' : 'hide password',
            ),
          ),
          border:outlineInputBorder),
    );

    final loginButon = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Theme.of(context).accentColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: edgeInsets,
        onPressed: (){
          login();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

//    final containerNewUser=Expanded(
//        child:Container(
//        alignment: FractionalOffset.bottomCenter,
//        color: Colors.white,
//      child:Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: [
//          Text("New.Register Here.",textAlign: TextAlign.left),
//
//          Text("Forgot Password?",textAlign: TextAlign.right)
//        ],)
//    ));


    final containerNewUser=Expanded(
        child:Container(
            alignment: FractionalOffset.bottomCenter,
            color: Colors.white,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                    child:Text("New?Register Here.",textAlign: TextAlign.left,style: styleFooter,),
                  onPressed: (){
//                    showToast("New User Register");
                    Navigator.of(this.context).pushNamed("/registerCompany");
                  },
                ),
                FlatButton(
                  child: Text("Forgot Password?",textAlign: TextAlign.right,style: styleFooter),
                  onPressed: (){
                    Navigator.of(this.context).pushNamed("/ForgotPassword");
                  },
                ),

              ],)
        ));

//      bool isLogin=prefs.getBool(PreferenceUtils.PREF_LOGIN_STATUS);
//
//      if(isLogin){
//        Navigator.of(this.context).pushReplacementNamed("/HomeScreen");
//      }

    return Scaffold(
      body: Center(

        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30.0),
//                SizedBox(
//                  height: 130.0,
//                  child: Image.asset('images/ic_logo.png',
//                    width: 120,
//                    height: 120,
//                    color: Theme.of(context).primaryColor,
//                    fit: BoxFit.contain,
//                  ),
//                ),
                new RawMaterialButton(
                  onPressed: () {},
                  child: Image.asset('images/ic_logo.png',width: 80,height: 80,color: Colors.white,),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.black,
                  padding: const EdgeInsets.all(10.0),
                ),
                SizedBox(height: 10.0),
                Text("iMount",style:styleAppName),
                SizedBox(height: 30.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 25.0,
                ),
                containerNewUser,
                SizedBox(
                  height: 15.0,
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
