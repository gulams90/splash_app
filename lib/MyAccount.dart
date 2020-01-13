import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/userTypeScreen.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';

import 'UserScreen.dart';
import 'models/NameData.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => new _MyAccountState();
}



class _MyAccountState extends State<MyAccount> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle styleNoRecord = TextStyle(fontFamily: 'Montserrat',color: Colors.grey , fontSize: 16.0,fontWeight: FontWeight.bold);

  final database = FirebaseDatabase.instance;
  String strOrgId,strUserId;
  List<NameData> alData=new List();

  String ID_MYPROFILE="1",ID_CHANGE_PASSWORD="2",ID_LOGOUT="3";

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strUserId=prefs.getString(PreferenceUtils.PREF_USERID);
    getList();
  }

  void listItemClickEvent(NameData mdata){

    if(mdata.id==ID_MYPROFILE){
      var route=MaterialPageRoute(
          builder: (context) => UserScreen(),
          // Pass the arguments as part of the RouteSettings. The
          // DetailScreen reads the arguments from these settings.
          settings: RouteSettings(
            arguments: strUserId,
          ));

      Navigator.of(context).push(route);

    }else if(mdata.id==ID_CHANGE_PASSWORD){
      Navigator.of(context).pushReplacementNamed("/ChangePassword");
    }else if(mdata.id==ID_LOGOUT){
      PreferenceUtils.addBoolToSF(PreferenceUtils.PREF_LOGIN_STATUS, false);
      Navigator.of(context).pushReplacementNamed("/LoginScreen");
    }



//    Navigator.of(context).pushNamed("/userTypeScreen");
  }

  void getList(){


    try {
        alData.add(new NameData(ID_MYPROFILE, "My Profile", null, true, strOrgId, 0, 0, 0));
        alData.add(new NameData(ID_CHANGE_PASSWORD, "Change Password", null, true, strOrgId, 0, 0, 0));
        alData.add(new NameData(ID_LOGOUT, "Logout", null, true, strOrgId, 0, 0, 0));

        setState(() {
          alData;
        });

    } catch (e) {
      print(e.toString());
    }

  }


  @override
  Widget build(BuildContext context) {

//    initData();

    return new Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text("My Account"),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),

//      bottomNavigationBar: BottomNavigationBar(
//        currentIndex: 0, // this will be set when a new tab is tapped
//        items: [
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.perm_identity),
//            title: new Text('Profile'),
//          ),
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.power_settings_new),
//            title: new Text('Logout'),
//          ),
//        ],
//      ),
        body:Container(
          color: Colors.white,
          child:alData.length==0?Center(
              child: Text("No Record Found.",style: styleNoRecord,textAlign: TextAlign.center,)): ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: alData.length,
            itemBuilder: (BuildContext context, int index) {
              NameData md=alData[index];
              return  GestureDetector(
                  onTap: () {
                    listItemClickEvent(md);

                  },
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 15.0),
                        Text(md.name,style:style ,),
                        SizedBox(height: 15.0),
                      ]
                  )
//                    child:Text(md.name,style:style ,)
              );

            },
            separatorBuilder: (context, index) {
              return Divider();
            },),
        )
    );

  }
}
