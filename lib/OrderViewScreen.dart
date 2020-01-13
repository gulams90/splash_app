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
import 'package:splash_app/utils/StatusUtils.dart';

import 'models/CompanyData.dart';
import 'models/NameData.dart';
import 'models/OrderData.dart';
import 'models/UserData.dart';
import 'utils/LicenseUtils.dart';
import 'dart:convert';


class OrderViewScreen extends StatefulWidget {
  @override
  _OrderViewScreenState createState() => new _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleTitle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0, fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final nameController = TextEditingController();
  OrderData orderData;
  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strUserId;
  String strEditId;
  String strTitle="View Service";
  ProgressDialog pr;
  bool isFirst=true;
  bool isButtonShow=false;
  String strServiceName="";

//  @override
//  void initState() {
//    super.initState();
//    print("UserTypeScreen initState................");
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strUserId=prefs.getString(PreferenceUtils.PREF_USERID);
    strEditId= ModalRoute.of(context).settings.arguments;
    pr = CommonUtils.getProgressDialog(context);
    if(strEditId!=null) {
      getEditDetails(strEditId);
    }
  }


  void updateCancelStatus() {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId).child(orderData.id);

    DateTime dt=new DateTime.now();
    String updatedDate=CommonUtils.getSimpleDateFormatServer(dt);

    Map<String,dynamic> hs=new Map();
    hs['status']=StatusUtils.CANCELLED.toString();
    hs['statusName']=StatusUtils.CANCELLED_TEXT;
    hs['targetDate']=updatedDate;

    CommonUtils.showProgressBar( pr);
    _companyRef.update(hs).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);
      setState(() {
        isButtonShow=false;
      });
    }).catchError((e) => print(e));

  }

  void updateCompleteStatus() {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId).child(orderData.id);

    DateTime dt=new DateTime.now();
    String updatedDate=CommonUtils.getSimpleDateFormatServer(dt);

    Map<String,dynamic> hs=new Map();
    hs['status']=StatusUtils.COMPLETED.toString();
    hs['statusName']=StatusUtils.COMPLETED_TEXT;
    hs['targetDate']=updatedDate;

    CommonUtils.showProgressBar( pr);
    _companyRef.update(hs).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);
      setState(() {
        isButtonShow=false;
      });
    }).catchError((e) => print(e));

  }


  void goBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
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

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId).child(strId);

      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          OrderData bd = OrderData.fromSnapshot(snapshot);

          if(bd!=null){
            setState(() {
              orderData=bd;
              if(orderData.status==StatusUtils.PENDING.toString()){
                isButtonShow=true;
              }else{
                isButtonShow=false;
              }
              strServiceName=orderData.serviceTypeData;
            });
          }
        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  void cancelOperation(){

    try {

      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation',style: styleTitle,),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure want to cancel?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  updateCancelStatus();
                  Navigator.of(context).pop();

                },
              ),

            ],
          );
        },
      );

    } catch (e) {
      print(e.toString());
    }

  }



  void completeOperation(){

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation',style: styleTitle,),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure want to complete?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  updateCompleteStatus();
                  Navigator.of(context).pop();

                },
              ),

            ],
          );
        },
      );


    } catch (e) {
      print(e.toString());
    }

  }




  @override
  Widget build(BuildContext context) {


    if(isFirst){
      isFirst=false;
      initData();
    }


    final cancellButton = Material(
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
          cancelOperation();

        },
        child: Text("Cancel",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    final completeButton = Material(
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
          completeOperation();

        },
        child: Text("Completed",
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
      body:orderData!=null?
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
                SizedBox(height: 15.0),
                strServiceName!=null?Text(strServiceName,style:styleTitle ,):Text("Service : --",style:styleTitle ,),
                SizedBox(height: 10.0),
                Text("Order No : "+orderData.orderNumber,style:style ,),
                SizedBox(height: 10.0),
                Text("Order Date : "+orderData.orderedDate,style:style ,),
                SizedBox(height: 10.0),
                orderData.description.length>0?Text("Description : "+orderData.description,style:style ,):Text("Description : --",style:style ,),
                SizedBox(height: 10.0),
                orderData.statusName!=null?Text("Status : "+orderData.statusName+" on "+orderData.targetDate,style:style ,):Text("Status : Pending",style:style ,),
                SizedBox(height: 15.0),
                Text("Customer Details",style:styleTitle ,),
                SizedBox(height: 10.0),
                Text("Name : "+orderData.customerName,style:style ,),
                SizedBox(height: 10.0),
                Text("Mobile : "+orderData.customerMobile,style:style ,),
                SizedBox(height: 10.0),
                orderData.customerEmail!=null?Text("Email : "+orderData.customerEmail,style:style ,):Text("Email : --",style:style ,),
                SizedBox(height: 10.0),
                orderData.customerAddress!=null?Text("Address : "+orderData.customerAddress,style:style ,):Text("Address : --",style:style ,),
                SizedBox(height: 20.0),
                Visibility(
                  child: cancellButton,
                  visible: isButtonShow,
                ),
                SizedBox(height: 15.0),
                Visibility(
                  child: completeButton,
                  visible: isButtonShow,
                ),
            //                        SizedBox(height: 10.0),
            //                        Text("Status : "+md.status,style:style ,),
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ):Text("No data found.",style:style ,)

    );
  }



}