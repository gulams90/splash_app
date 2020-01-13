

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:splash_app/models/SMSData.dart';
import 'package:http/http.dart'  as Http;
import 'CommonUtils.dart';
import 'DatabaseUtils.dart';
import 'MessageStatus.dart';
import 'SMSUtils.dart';

class MessageAPI{
   MessageAPI(var context,bool isPop,FirebaseDatabase database,ProgressDialog pr,String id,String title,String message,String status,String orgId,String type,String countryCode,String mobile,String smsSender){
     SMSData sdata=new SMSData( id, title, message, status, orgId, type, countryCode, mobile, smsSender);
     saveSMS(context,isPop,sdata, database, pr);
  }

  static void saveSMS(var context,bool isPop,final SMSData sdata,FirebaseDatabase database,ProgressDialog pr) {
    try {
      String table = DatabaseUtils.TBL_SMS_HISTORY;

      final DatabaseReference myRef = database.reference().child(table);

      String id = myRef
          .push()
          .key;
      sdata.id = id;

      int time = new DateTime.now().millisecondsSinceEpoch;
      String strDate = CommonUtils.getSimpleDateFormatServer(DateTime.now());
      String month = CommonUtils.getSimpleMonthFormatServer(DateTime.now());
      String monthFilter = CommonUtils.getSMSMonthFilterText(
          sdata.orgId, month);

      sdata.date = strDate;
      sdata.time = time;
      sdata.monthFilter = monthFilter;

//      CommonUtils.showProgressBar(pr);
      myRef.child(id).set(sdata.toJson()).whenComplete(() {
        print('SMS History Table whenComplete');
        String msg = sdata.title + "\n" + sdata.message;
        sendSMSMessage(context,database,sdata,isPop, sdata.countryCode, sdata.mobile, msg, sdata.smsSender, pr);
      }).catchError((e) => print(e));
    } catch (e) {
      print(e.toString());
    }
  }

  static void sendSMSMessage(var context,FirebaseDatabase database,SMSData sdata,bool isPop,String countryCode,String mobile,String message,String from,ProgressDialog pr) async{

    try {


      String strSMSSender=null;

      if(from!=null&&from.length>0){
        strSMSSender=from;
      }else{
        strSMSSender= SMSUtils.SENDER;
      }

      var queryParameters = {
        'country': countryCode,
        'sender': strSMSSender,
        'route': SMSUtils.ROUTE.toString(),
        'mobiles': mobile,
        'authkey': SMSUtils.AUTH_KEY,
        'message': message,
      };

//      Map<String, String> headers = new Map();
//      headers.putIfAbsent('Accept', () => 'application/json');

      var uri =Uri.http(SMSUtils.BASE_URL,SMSUtils.UNENCODED_URL, queryParameters);
      Http.Response response = await Http.get(uri);

      print('SMS Responses: ${response.statusCode}');
      print('SMS Response: ${response.body}');

      if(response.statusCode==200){
        updateSMSStatus(context,isPop,database,sdata,MessageStatus.DELIVERED);
      }else{
        if(isPop){
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      }

//      CommonUtils.hideProgressBar( pr);



    } catch (e) {
      print(e.toString());
    }
  }


    static void updateSMSStatus(var context,bool isPop,FirebaseDatabase database,final SMSData sdata,String status){
     try {
       final DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_SMS_HISTORY).child(sdata.id);

       myRef.child("status").set(status).whenComplete(() {
         print('SMS History Table Status Updated');

         if(isPop){
           if (Navigator.canPop(context)) {
             Navigator.pop(context);
           }
         }
       }).catchError((e) => print(e));
     } catch (e) {
       print(e);
     }

   }


}