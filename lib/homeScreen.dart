import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/models/MenuData.dart';
import 'registerCompany.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/MenuUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'models/UserData.dart';

class homeScreen extends StatefulWidget {
  @override
  _homeScreenState createState() => new _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  String strOrgId;
  String strUserd;
  List<MenuData> alData=new List();
  final database = FirebaseDatabase.instance;
  ProgressDialog pr;
  bool isFirst=true;


//  @override
//  void initState() {
//    super.initState();
//    print("UserTypeScreen initState................");
//    initData();
//  }

  initData() async {
    print("_homeScreenState initData................");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strUserd=prefs.getString(PreferenceUtils.PREF_USERID);
    pr = CommonUtils.getProgressDialog(context);
    getUserDetails(strUserd);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("_homeScreenState dispose................");
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    super.setState(fn);
    @override
    void dispose() {
      // TODO: implement dispose
      super.dispose();
      print("_homeScreenState setState................");
    }
  }



  void getUserDetails(String strId){

    try {
      print("_homeScreenState getUserDetails................");
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER).child(strId);
      CommonUtils.showProgressBar(pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {

          UserData bd = UserData.fromSnapshot(snapshot);

          if(bd!=null){
            String strUserType=bd.userType;
            if(strUserType!=null){
              getAccessRightsDetails(strUserType);
            }else{
              print("_homeScreenState getUserDetails else................");
//              alData = MenuUtils.getAllMenuList();
              setState(() {
                alData = MenuUtils.getAllMenuList();
              });
//              if(mounted) {
//                setState(() {
//                  alData = MenuUtils.getAllMenuList();
//                });
//              }else{
//                alData = MenuUtils.getAllMenuList();
//              }
            }
          }


        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  void getAccessRightsDetails(String strUserType){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_ACCESSRIGHTS).child(strOrgId).child(strUserType);
      CommonUtils.showProgressBar(pr);
      myRef.once().then((DataSnapshot snapshot) {
      CommonUtils.hideProgressBar(pr);

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
            List<MenuData> alMenu=MenuUtils.getAllMenuList();

            List<String> arValue=strAccessRights.split(",");

            for(int i=0;i<alMenu.length;i++){
              MenuData md=alMenu[i];
              String strId=md.id.toString();
              if(arValue.contains(strId)){
                alData.add(md);
              }
            }


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

  void gridItemClickEvent(MenuData mdata){

    if(mdata.id==MenuUtils.MENU_COMPANYINFO){

      var route=MaterialPageRoute(
          builder: (context) => registerCompany(),
          // Pass the arguments as part of the RouteSettings. The
          // DetailScreen reads the arguments from these settings.
          settings: RouteSettings(
            arguments: strOrgId,
          ));

      Navigator.of(context).push(route);

    }else if(mdata.id==MenuUtils.MENU_BRANCH){
      Navigator.of(context).pushNamed("/branchList");
    }else if(mdata.id==MenuUtils.MENU_MYACCOUNT){
      Navigator.of(context).pushNamed("/MyAccount");
    }else if(mdata.id==MenuUtils.MENU_MASTER){
      Navigator.of(context).pushNamed("/masterScreen");
    }else if(mdata.id==MenuUtils.MENU_USERS){
      Navigator.of(context).pushNamed("/UserList");
    }else if(mdata.id==MenuUtils.MENU_SERVICE_HISTORY){
      Navigator.of(context).pushNamed("/HistoryMenuScreen");
    }else if(mdata.id==MenuUtils.MENU_NEW_SERVICE){
      Navigator.of(context).pushNamed("/NewServiceScreen");
    }else if(mdata.id==MenuUtils.MENU_SETTINGS){

    }
  }



  @override
  Widget build(BuildContext context) {
    print("_homeScreenState build................");
    if(isFirst){
      isFirst=false;
      print("_homeScreenState build isFirst................");
      initData();
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('iMount'),
        titleSpacing: 0.0,
        leading: IconButton(icon:Image.asset('images/ic_logo.png',color: Colors.white,)),
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
              child: Text("No Record Found.",style: style,textAlign: TextAlign.center,)): GridView.count(

        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        physics: new NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
//        shrinkWrap: true,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 4.0,
        children:List.generate(alData.length, (index) {
          MenuData md=alData[index];
          return
            GestureDetector(
              onTap: () {
                gridItemClickEvent(md);

              },
            child:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(md.image,width: 60,height: 60),
                SizedBox(height: 10.0),
                Text(md.name,style:style ,)
              ],
            )
//            child: Text(
//              'Item $index',
//              style: Theme.of(context).textTheme.headline,
//            ),
          )
          );
        }),
      )
      ),
    );
  }
}
