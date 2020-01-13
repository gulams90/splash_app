import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:splash_app/models/SMSData.dart';

import 'DatabaseUtils.dart';

class CommonUtils{
  static final String defaultCountryCode="91";
  static final String dataSavedSuccess="Data Saved Successfully!";

  static String getSimpleDateFormatServer(DateTime dtime){
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dtime);
    return formattedDate;
  }
  static String getSimpleMonthFormatServer(DateTime dtime){
    String formattedDate = DateFormat('MMM').format(dtime);
    return formattedDate;
  }

  static ProgressDialog getProgressDialog(context){
    ProgressDialog pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs:false);
//    ProgressDialog pr = new ProgressDialog(context);
    return pr;
  }

  static void showProgressBar(ProgressDialog pr){
      if(pr!=null) {
        pr.show();
      }
  }

  static void hideProgressBar(ProgressDialog pr){
    Future.delayed(Duration(seconds: 0)).then((onValue){
      if(pr!=null&&pr.isShowing()) {
        pr.hide();
      }
    }
    );

  }

   static String getDateFilterText(String strOrgId,String strDate){
    String filter=null;
    try{
      filter=strOrgId+"_"+strDate;

    }catch (e){
    print(e.toString());
    }
    return filter;

  }

   static String getDateFilterCustomerText(String strOrgId,String strCustomerId,String strDate){
    String filter=null;
    try{
      filter=strOrgId+"_"+strCustomerId+"_"+strDate;

    }catch (e){
      print(e.toString());
    }
    return filter;

  }

   static String getOrderSearchFilterText(String strCustomerName,String strCustomerMobile,String strServiceName,String strOrderNumber){
    String filter=null;
    try{
      filter=strCustomerName+"_"+strCustomerMobile+"_"+strServiceName+"_"+strOrderNumber;

    }catch (e){
      print(e.toString());
    }
    return filter;

  }

  static showToast(var message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

   static String getSMSMonthFilterText(String strOrgId,String month){
    String strFilter=null;
    if(strOrgId!=null&&strOrgId.length>0){
      strFilter=strOrgId+"_"+month;
    }else{
      strFilter=month;
    }
    return strFilter;
  }




}