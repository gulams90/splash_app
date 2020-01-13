import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/userTypeScreen.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';
import 'package:splash_app/utils/StatusUtils.dart';

import 'NewServiceScreen.dart';
import 'OrderViewScreen.dart';
import 'models/NameData.dart';
import 'models/OrderData.dart';

class PendingOrderList extends StatefulWidget {
  @override
  _PendingOrderListState createState() => new _PendingOrderListState();
}



class _PendingOrderListState extends State<PendingOrderList> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle styleNoRecord = TextStyle(fontFamily: 'Montserrat',color: Colors.grey , fontSize: 16.0,fontWeight: FontWeight.bold);

  final database = FirebaseDatabase.instance;
  String strOrgId;
  List<OrderData> alData=new List();
  StreamSubscription subscriptionEntryAdded;
  StreamSubscription subscriptionEntryChanged;

  List<OrderData> alDataAll=new List();
  static final String strTitle="Pending Services";
  Widget appBarTitle = new Text(strTitle, style: new TextStyle(color: Colors.white),);
  Icon actionIcon = new Icon(Icons.search, color: Colors.white,);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
//  List<String> _list;
  bool _IsSearching;
  String _searchText = "";
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
    _SearchListState();
    _IsSearching = false;
    getList();
  }

  void listItemClickEvent(OrderData mdata){

    var route=MaterialPageRoute(
        builder: (context) => OrderViewScreen(),
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
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId);
      Query qry=myRef.orderByChild("status").equalTo(StatusUtils.PENDING.toString());
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
      OrderData bd=OrderData.fromSnapshot(snapshot);
      print("on Entry Added : "+bd.orderNumber);
      alDataAll.add(bd);
      if(!_IsSearching) {
        alData.add(bd);
      }
    });
  }

  _onEntryChanged(Event event) {
    var oldEntry = alDataAll.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      print("on Entry Changed : ");
      alDataAll[alDataAll.indexOf(oldEntry)] = OrderData.fromSnapshot(event.snapshot);
      if(!_IsSearching){
        alData[alData.indexOf(oldEntry)] = OrderData.fromSnapshot(event.snapshot);
      }
    });
  }

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
          alData.clear();
          for(int i=0;i<alDataAll.length;i++){
            OrderData od=alDataAll[i];
            alData.add(od);
          }
          setState(() {
            alData;
          });

        });
      }
      else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
          String strSearchText=_searchText.toUpperCase();
          print("strSearchText : "+strSearchText);
          alData.clear();
          for(int i=0;i<alDataAll.length;i++){
            OrderData od=alDataAll[i];
            String strCustName=od.customerName.toUpperCase();
            String strCustMobile=od.customerMobile.toUpperCase();
            String strService=od.serviceTypeData.toUpperCase();
            String strOrderNo=od.orderNumber.toUpperCase();
            String strsearchData=strCustName+" "+strCustMobile+" "+strService+" "+strOrderNo;
            if(strsearchData.contains(strSearchText)){
              alData.add(od);
            }
          }

          setState(() {
            alData;
          });

        });
      }
    });
  }

//  void init() {
//    _list = List();
//    _list.add("Google");
//    _list.add("IOS");
//    _list.add("Andorid");
//    _list.add("Dart");
//    _list.add("Flutter");
//    _list.add("Python");
//    _list.add("React");
//    _list.add("Xamarin");
//    _list.add("Kotlin");
//    _list.add("Java");
//    _list.add("RxAndroid");
//  }

  @override
  Widget build(BuildContext context) {

    if(isFirst){
      isFirst=false;
      initData();
    }

    return new Scaffold(
      key: key,
      appBar: buildBar(context),
      body:Container(
        color: Colors.black12,
        child:alData.length==0?Center(
            child: Text("No Record Found.",style: styleNoRecord,textAlign: TextAlign.center,)): ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: alData.length,
          itemBuilder: (BuildContext context, int index) {
            OrderData md=alData[index];
            return Card(

                child: GestureDetector(
                    onTap: () {
                      listItemClickEvent(md);

                    },
                    child:Padding(
                        padding: const EdgeInsets.all(10),
                        child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15.0),
                              Text("Order No : "+md.orderNumber,style:style ,),
                              SizedBox(height: 10.0),
                              Text("Order Date : "+md.orderedDate,style:style ,),
                              SizedBox(height: 10.0),
                              Text("Customer Name : "+md.customerName,style:style ,),
                              SizedBox(height: 10.0),
                              Text("Customer Mobile : "+md.customerMobile,style:style ,),
                              SizedBox(height: 10.0),
                              md.statusName!=null?Text("Status : "+md.statusName,style:style ,):Text("Status : Pending",style:style ,),
//                        SizedBox(height: 10.0),
//                        Text("Status : "+md.status,style:style ,),
                              SizedBox(height: 15.0),
                            ]
                        )
                    )
//                    child:Text(md.name,style:style ,)
                )
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },),
      ),
    );
  }

//  List<ChildItem> _buildList() {
//    return _list.map((contact) => new ChildItem(contact)).toList();
//  }
//
//  List<ChildItem> _buildSearchList() {
//    if (_searchText.isEmpty) {
//      return _list.map((contact) => new ChildItem(contact))
//          .toList();
//    }
//    else {
//      List<String> _searchList = List();
//      for (int i = 0; i < _list.length; i++) {
//        String  name = _list.elementAt(i);
//        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
//          _searchList.add(name);
//        }
//      }
//      return _searchList.map((contact) => new ChildItem(contact))
//          .toList();
//    }
//  }


  Widget buildBar(BuildContext context) {
    return new AppBar(
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(icon: actionIcon, onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close, color: Colors.white,);
                this.appBarTitle = new TextField(
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Colors.white,

                  ),
                  decoration: new InputDecoration(
//                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                );
                _handleSearchStart();
              }
              else {
                _handleSearchEnd();
              }
            });
          },),
        ]
    );
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle =
      new Text(strTitle, style: new TextStyle(color: Colors.white),);
      _IsSearching = false;
      _searchQuery.clear();
    });
  }




//  @override
//  Widget build(BuildContext context) {
//
////    initData();
//
//    return new Scaffold(
//        appBar: AppBar(
//            automaticallyImplyLeading: true,
//            //`true` if you want Flutter to automatically add Back Button when needed,
//            //or `false` if you want to force your own back button every where
//            title: Text("Pending Services"),
//            leading: IconButton(icon:Icon(Icons.arrow_back),
//              onPressed:() => Navigator.pop(context, false),
//            )
//        ),
//
////      bottomNavigationBar: BottomNavigationBar(
////        currentIndex: 0, // this will be set when a new tab is tapped
////        items: [
////          BottomNavigationBarItem(
////            icon: new Icon(Icons.perm_identity),
////            title: new Text('Profile'),
////          ),
////          BottomNavigationBarItem(
////            icon: new Icon(Icons.power_settings_new),
////            title: new Text('Logout'),
////          ),
////        ],
////      ),
//        body:Container(
//          color: Colors.black12,
//          child:alData.length==0?Center(
//              child: Text("No Record Found.",style: styleNoRecord,textAlign: TextAlign.center,)): ListView.separated(
//            padding: const EdgeInsets.all(10),
//            itemCount: alData.length,
//            itemBuilder: (BuildContext context, int index) {
//              OrderData md=alData[index];
//              return Card(
//
//                  child: GestureDetector(
//                      onTap: () {
//                        listItemClickEvent(md);
//
//                      },
//                      child:Padding(
//                          padding: const EdgeInsets.all(10),
//                          child:Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.start,
//                              children: <Widget>[
//                                SizedBox(height: 15.0),
//                                Text("Order No : "+md.orderNumber,style:style ,),
//                                SizedBox(height: 10.0),
//                                Text("Order Date : "+md.orderedDate,style:style ,),
//                                SizedBox(height: 10.0),
//                                Text("Customer Name : "+md.customerName,style:style ,),
//                                SizedBox(height: 10.0),
//                                Text("Customer Mobile : "+md.customerMobile,style:style ,),
//                                SizedBox(height: 10.0),
//                                md.statusName!=null?Text("Status : "+md.statusName,style:style ,):Text("Status : Pending",style:style ,),
////                        SizedBox(height: 10.0),
////                        Text("Status : "+md.status,style:style ,),
//                                SizedBox(height: 15.0),
//                              ]
//                          )
//                      )
////                    child:Text(md.name,style:style ,)
//                  )
//              );
//            },
//            separatorBuilder: (context, index) {
//              return Divider();
//            },),
//        )
//    );
//
//  }
}
