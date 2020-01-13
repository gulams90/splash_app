import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/userTypeScreen.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/MenuUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';

import 'models/MenuData.dart';
import 'models/NameData.dart';

class AccessRights extends StatefulWidget {
  @override
  _AccessRightsState createState() => new _AccessRightsState();
}



class _AccessRightsState extends State<AccessRights> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle styleNoRecord = TextStyle(fontFamily: 'Montserrat',color: Colors.grey , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);

  final database = FirebaseDatabase.instance;
  String strOrgId;
  List<MenuData> alData=new List();
  List<NameData> alUserType=new List();
  StreamSubscription subscriptionEntryAdded;
  StreamSubscription subscriptionEntryChanged;
  ProgressDialog pr;
  bool isFirst=true;

  NameData selectedData;

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

//    setState(() {
//      alData=MenuUtils.getAllMenuList();
//      print("Data Size : "+alData.length.toString());
//    });
  }


  void getAccessRightsDetails(String strUserType){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_ACCESSRIGHTS).child(strOrgId).child(strUserType);
      CommonUtils.showProgressBar(pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        alData.clear();
        String strAccessRights;
        if (snapshot!=null) {
          if(snapshot.value!=null) {
            String bd = snapshot.value.toString();
            if (bd != null) {
              strAccessRights=bd;
              print("AccessRights : "+bd);
            }
          }
        }

      if(strAccessRights!=null) {
        setState(() {
          alData = MenuUtils.getAllMenuList();
          setAccessRightsValues(strAccessRights);

        });
      }else{
        setState(() {
          alData = MenuUtils.getAllMenuList();
        });
      }


      });

    } catch (e) {
      print(e.toString());
    }

  }


   void setAccessRightsValues(String accessMenus){

    try{
      if(accessMenus!=null){

        List<String> arValue=accessMenus.split(",");

        for(int i=0;i<alData.length;i++){
          MenuData md=alData[i];
          String strId=md.id.toString();
          if(arValue.contains(strId)){
            md.selected=true;
          }else{
            md.selected=false;
          }
        }

      }


//      bool isChanged=false;
//      if(accessMenus!=null){
//
//        List<String> arValue=accessMenus.split(",");
//
//        for(int i=0;i<alData.length;i++){
//          MenuData md=alData[i];
//          String strId=md.id.toString();
//          if(arValue.contains(strId)){
//            if(!md.selected){
//              isChanged=true;
//              md.selected=true;
//            }
//          }else{
//            if(md.selected){
//              isChanged=true;
//              md.selected=false;
//            }
//          }
//        }
//
//
//      }else{
//        for(int i=0;i<alData.length;i++){
//          MenuData md=alData[i];
//
//          if(!md.selected){
//            isChanged=true;
//            md.selected=true;
//          }
//
//        }
//      }
//
//      if(isChanged){
//
//      }

    }catch (e){

    }

  }


  void getList(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USERTYPE).child(strOrgId);
      CommonUtils.showProgressBar(pr);
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

        }
      });

//      subscriptionEntryAdded=myRef.onChildAdded.listen(_onEntryAdded);
//      subscriptionEntryChanged= myRef.onChildChanged.listen(_onEntryChanged);

    } catch (e) {
      print(e.toString());
    }

  }

//  _onEntryAdded(Event event) {
//    setState(() {
//      DataSnapshot snapshot=event.snapshot;
//      NameData bd=NameData.fromSnapshot(snapshot);
//      print("on Entry Added : "+bd.name);
//      alData.add(bd);
//    });
//  }
//
//  _onEntryChanged(Event event) {
//    var oldEntry = alData.singleWhere((entry) {
//      return entry.id == event.snapshot.key;
//    });
//
//    setState(() {
//      print("on Entry Changed : ");
//      alData[alData.indexOf(oldEntry)] = NameData.fromSnapshot(event.snapshot);
//    });
//  }

  void saveData(String userType,String value) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_ACCESSRIGHTS).child(strOrgId);
    CommonUtils.showProgressBar(pr);
    _companyRef.child(userType).set(value).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);
//      goBack();
    }).catchError((e) => print(e));

  }

  validate() {

    if (selectedData!=null) {
      String value="";

      for(int i=0;i<alData.length;i++){
        MenuData md=alData[i];
        if(md.selected){
          value+=md.id.toString()+",";
        }
      }

      if(value.endsWith(",")){
        value=value.substring(0,(value.length-1));
      }

      if(value.length>0) {
        print("Selected Access " + value);

        saveData(selectedData.id, value);
      }else{
        CommonUtils.showToast("Select atleast one access.");
      }
    } else {
      CommonUtils.showToast("Select User Type");
    }
  }

  void goBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }



  @override
  Widget build(BuildContext context) {

//    initData();

    if(isFirst){
      isFirst=false;
      initData();
    }

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
//          login();
        validate();

        },
        child: Text("Save",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
          getAccessRightsDetails(selectedData.id);
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

    return new Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text("Access Rights"),
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
        child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              SizedBox(height: 20.0),
              ddUserType,
              SizedBox(height: 20.0),
            Expanded(
                child:ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: alData.length,
            itemBuilder: (BuildContext context, int index) {
              MenuData md=alData[index];

              return  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5.0),
                        SwitchListTile(
                          title: Text(md.name,style: style,),
                          value: md.selected,
                          onChanged: (bool value) {
                            setState(() {
                              md.selected = value;
                            });
                          },
                        ),
                        SizedBox(height: 5.0),
                      ]
                  );
//                    child:Text(md.name,style:style ,)


            },
            separatorBuilder: (context, index) {
              return Divider();
            },)),
                SizedBox(height: 15.0),
                 submitButon,


      ]
      )
    )
    )

    );

  }
}
