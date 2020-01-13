
import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';
import 'ForgotPassword.dart';
import 'homeScreen.dart';
import 'registerCompany.dart';
import 'package:splash_app/serviceTypeList.dart';
import 'package:splash_app/serviceTypeScreen.dart';
import 'package:splash_app/statusScreen.dart';
import 'package:splash_app/userTypeList.dart';
import 'package:splash_app/userTypeScreen.dart';
import 'AccessRights.dart';
import 'CancelledOrderHistory.dart';
import 'ChangePassword.dart';
import 'HistoryMenuScreen.dart';
import 'LoginScreen.dart';
import 'MyAccount.dart';
import 'NewServiceScreen.dart';
import 'OrderViewScreen.dart';
import 'OrdersList.dart';
import 'PendingOrderList.dart';
import 'StatusList.dart';
import 'UserList.dart';
import 'UserScreen.dart';
import 'branchList.dart';
import 'branchScreen.dart';
import 'masterScreen.dart';

void main() {
  runApp(new MaterialApp(
    theme: new ThemeData(
      primaryColor:  Color(0xff191654),
      primaryColorDark: Color(0xff191654),
      accentColor: Color(0xff191654),
//        191654
      // Define the default font family.
      fontFamily: 'Montserrat',

      // Define the default TextTheme. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic,color: Colors.white),
        body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),

        primaryTextTheme: TextTheme(
            title: TextStyle(
                color: Colors.white
            )
        ),

    primaryIconTheme: IconThemeData(color: Colors.white)

    ),
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/homeScreen': (BuildContext context) => new homeScreen(),
      '/LoginScreen': (BuildContext context) => new LoginScreen(),
      '/registerCompany': (BuildContext context) => new registerCompany(),
      '/masterScreen': (BuildContext context) => new masterScreen(),
      '/userTypeScreen': (BuildContext context) => new userTypeScreen(),
      '/userTypeList': (BuildContext context) => new userTypeList(),
      '/StatusList': (BuildContext context) => new StatusList(),
      '/statusScreen': (BuildContext context) => new statusScreen(),
      '/serviceTypeList': (BuildContext context) => new serviceTypeList(),
      '/serviceTypeScreen': (BuildContext context) => new serviceTypeScreen(),
      '/branchList': (BuildContext context) => new branchList(),
      '/branchScreen': (BuildContext context) => new branchScreen(),
      '/AccessRights': (BuildContext context) => new AccessRights(),
      '/UserList': (BuildContext context) => new UserList(),
      '/UserScreen': (BuildContext context) => new UserScreen(),
      '/MyAccount': (BuildContext context) => new MyAccount(),
      '/ChangePassword': (BuildContext context) => new ChangePassword(),
      '/NewServiceScreen': (BuildContext context) => new NewServiceScreen(),
      '/OrdersList': (BuildContext context) => new OrdersList(),
      '/OrderViewScreen': (BuildContext context) => new OrderViewScreen(),
      '/HistoryMenuScreen': (BuildContext context) => new HistoryMenuScreen(),
      '/PendingOrderList': (BuildContext context) => new PendingOrderList(),
      '/CancelledOrderHistory': (BuildContext context) => new CancelledOrderHistory(),
      '/ForgotPassword': (BuildContext context) => new ForgotPassword()

    },
  ));
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _message = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) =>
      PreferenceUtils.addStringToSF(PreferenceUtils.PREF_USERNAME, token));

  }



  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isLogin=prefs.getBool(PreferenceUtils.PREF_LOGIN_STATUS);
    if(isLogin!=null) {
      if (isLogin) {
        Navigator.of(this.context).pushReplacementNamed("/homeScreen");
      } else {
        Navigator.of(context).pushReplacementNamed('/LoginScreen');
      }
    }else{
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }

  }

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      _register();
      getMessage();
    }
    startTime();
  }

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:Container(
//          color: Theme.of(context).primaryColor,
          color: Colors.white,
          child:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Image.asset('images/ic_logo.png',width: 120,height: 120,color: Colors.cyanAccent,),
            new RawMaterialButton(
              onPressed: () {},
              child: Image.asset('images/ic_logo.png',width: 120,height: 120,color: Colors.white,),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.black,
              padding: const EdgeInsets.all(15.0),
            ),
            SizedBox(height: 25.0),
            Text("iMount",style: TextStyle(fontFamily: 'Montserrat',fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor,fontSize: 28.0),)
          ],
        )

      )),
    );
  }
}