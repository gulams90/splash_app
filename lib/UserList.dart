import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/userTypeScreen.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';

import 'UserScreen.dart';
import 'models/NameData.dart';
import 'models/UserData.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => new _UserListState();
}



class _UserListState extends State<UserList> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle styleNoRecord = TextStyle(fontFamily: 'Montserrat',color: Colors.grey , fontSize: 16.0,fontWeight: FontWeight.bold);

  final database = FirebaseDatabase.instance;
  String strOrgId;
  List<UserData> alData=new List();
  StreamSubscription subscriptionEntryAdded;
  StreamSubscription subscriptionEntryChanged;

  ProgressDialog pr;
  bool isFirst=true;

//  @override
//  void initState() {
//    super.initState();
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    pr = CommonUtils.getProgressDialog(context);
    getList();
  }

  void listItemClickEvent(UserData mdata){

    var route=MaterialPageRoute(
        builder: (context) => UserScreen(),
        // Pass the arguments as part of the RouteSettings. The
        // DetailScreen reads the arguments from these settings.
        settings: RouteSettings(
          arguments: mdata.id,
        ));

    Navigator.of(context).push(route);

//    Navigator.of(context).pushNamed("/userTypeScreen");
  }

  void getList(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qry=myRef.orderByChild("orgId").equalTo(strOrgId);
//      myRef.once().then((DataSnapshot snapshot) {
//        if (snapshot!=null) {
//          Map<dynamic, dynamic> values = snapshot.value;
//          if(values!=null) {
//            alData.clear();
//            values.forEach((key, values) {
//              if (values != null) {
//                NameData bd = NameData.fromJson(values);
//                if (bd != null) {
//                  print("from bd " + bd.name );
//                  alData.add(bd);
//
//                }
//              }
//            });
//
//
//            setState(() {
//              alData;
//            });
//
//          }
//
//        }
//      });

      subscriptionEntryAdded=qry.onChildAdded.listen(_onEntryAdded);
      subscriptionEntryChanged= qry.onChildChanged.listen(_onEntryChanged);

    } catch (e) {
      print(e.toString());
    }

  }

  _onEntryAdded(Event event) {
    setState(() {
      DataSnapshot snapshot=event.snapshot;
      UserData bd=UserData.fromSnapshot(snapshot);
      print("on Entry Added : "+bd.name);
      if(bd.userType!=null) {
        alData.add(bd);
      }
    });
  }

  _onEntryChanged(Event event) {
    var oldEntry = alData.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      print("on Entry Changed : ");
      alData[alData.indexOf(oldEntry)] = UserData.fromSnapshot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {

//    initData();

    if(isFirst){
      isFirst=false;
      initData();
    }

    return new Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text("Users"),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/UserScreen");
          },
          child: Icon(Icons.add,color: Colors.white,),
//        backgroundColor: Colors.black,
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
              UserData md=alData[index];
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
