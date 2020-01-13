import 'dart:async';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'package:splash_app/utils/MessageAPI.dart';
import 'package:splash_app/utils/PreferenceUtils.dart';
import 'package:splash_app/utils/SMSUtils.dart';
import 'package:splash_app/utils/StatusUtils.dart';
import 'package:splash_app/utils/MessageTextUtils.dart';
import 'package:splash_app/utils/MessageType.dart';
import 'package:splash_app/utils/MessageStatus.dart';

import 'models/CompanyData.dart';
import 'models/CustomerData.dart';
import 'models/NameData.dart';
import 'models/OrderData.dart';
import 'models/OrderStatusData.dart';
import 'models/UserData.dart';
import 'utils/LicenseUtils.dart';


class NewServiceScreen extends StatefulWidget {

  @override
  _NewServiceScreenState createState() => new _NewServiceScreenState();
}



class _NewServiceScreenState extends State<NewServiceScreen> {


  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleError = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0,color: Colors.red);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();


  bool isName = true;
  bool isMobile = true;
  bool isEmail = true;
  bool isAddress = true;
  bool isDescription = true;
  bool isServiceTypeError = false;
  bool isBranchError = false;

  String strTitle="Add Service";

  var _emailError="";
  var _mobileError="";

  var isMobileNumberAvailable=0;
  ProgressDialog pr;
  bool isFirst=true;

  List<NameData> alServiceType=new List();
  NameData selectedServiceTypeData;

  List<CompanyData> alBranch=new List();
  CompanyData selectedBranchData;

  List<UserData> alNewSMSUsers=new List();

  int createdTime;
  OrderData orderData;
  CompanyData companyData;
  CustomerData tempCustomerData;

  final database = FirebaseDatabase.instance;
  String strOrgId;
  String strUserId;
  String strEditId;

  StreamSubscription subscriptionEntryAdded;


//  @override
//  void initState() {
//    super.initState();
//    print("regCompany initState................");
//    initData();
//  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strOrgId=prefs.getString(PreferenceUtils.PREF_COMPANYID);
    strUserId=prefs.getString(PreferenceUtils.PREF_USERID);
    strEditId= ModalRoute.of(context).settings.arguments;
    pr = CommonUtils.getProgressDialog(context);
    if(strEditId!=null) {
      setState(() {
        strTitle="Edit Order";
      });
    }

    getCompanyDetails(strOrgId);
  }

  void getCompanyDetails(String strOrgId){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_COMPANY).child(strOrgId);
      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
//        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          CompanyData bd = CompanyData.fromSnapshot(snapshot);

          if(bd!=null){
            companyData=bd;
          }

        }
        getSMSUsersList();
        getServiceType();

      });

    } catch (e) {
      print(e.toString());
    }

  }

  void getSMSUsersList(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qry=myRef.orderByChild("orgId").equalTo(strOrgId);
      subscriptionEntryAdded=qry.onChildAdded.listen(_onEntryAdded);

    } catch (e) {
      print(e.toString());
    }

  }

  _onEntryAdded(Event event) {
    setState(() {
      DataSnapshot snapshot=event.snapshot;
      UserData bd=UserData.fromSnapshot(snapshot);
//      print("on Entry Added : "+bd.name);
      if(bd.notification) {
        print("on Entry Added : "+bd.name);
        alNewSMSUsers.add(bd);
      }
    });
  }


  void getServiceType(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_SERVICETYPE).child(strOrgId);
//      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
//        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            alServiceType.clear();
            values.forEach((key, values) {
              if (values != null) {
                NameData bd = NameData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.name );
                  alServiceType.add(bd);

                }
              }
            });


            setState(() {
              alServiceType;
            });

          }

          getBranch();
//          if(strEditId!=null) {
//            getEditDetails(strEditId);
//          }

        }
      });

//      subscriptionEntryAdded=myRef.onChildAdded.listen(_onEntryAdded);
//      subscriptionEntryChanged= myRef.onChildChanged.listen(_onEntryChanged);

    } catch (e) {
      print(e.toString());
    }

  }


  void getBranch(){


    try {
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_BRANCH).child(strOrgId);
//      CommonUtils.showProgressBar( pr);
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            alBranch.clear();
            values.forEach((key, values) {
              if (values != null) {
                CompanyData bd = CompanyData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.name );
                  alBranch.add(bd);

                }
              }
            });


            setState(() {
              alBranch;
            });

          }

        }
      });

    } catch (e) {
      print(e.toString());
    }

  }



  void saveCustomerInfo(var name,var mobile,var email,var address,var description)   {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_CUSTOMER_INFO).child(strOrgId);

    String id=null;
    if(tempCustomerData!=null){
      id=tempCustomerData.id;
    }else{
      id= _companyRef.push().key;
    }

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    CustomerData cdata = new CustomerData(id, name, email, mobile, address, strOrgId, modifedTime);
    CommonUtils.showProgressBar( pr);
    _companyRef.child(id).set(cdata.toJson()).whenComplete(() {

      saveOrder(name, mobile, email, address, description,id);

    }).catchError((e) => print(e));

  }

  void saveOrder(var name,var mobile,var email,var address,var description,String strCustId)   {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId);

    DateTime dt=new DateTime.now();

    String orderDateCount=CommonUtils.getSimpleDateFormatServer(dt);
    String dateFilerCount = CommonUtils.getDateFilterText(strOrgId, orderDateCount);

    Query query=_companyRef.orderByChild("datefilter").equalTo(dateFilerCount);

    int count=0;
    int orderNumber=0;


    query.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            count=values.length;
          }

        }

        orderNumber=count+1;
        String strOrderNumber=orderNumber.toString();
        saveOrderInfo(name, mobile, email, address, description, strOrderNumber,strCustId);

      });

  }


  void saveOrderInfo(var name,var mobile,var email,var address,var description,String orderNumber,String strCustId)   {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_ORDERS).child(strOrgId);

    DateTime dt=new DateTime.now();

    String orderDateCount=CommonUtils.getSimpleDateFormatServer(dt);
    String dateFilerCount = CommonUtils.getDateFilterText(strOrgId, orderDateCount);

    String id=_companyRef.push().key;
    int modifiedTime=new DateTime.now().millisecondsSinceEpoch;

    double totalPrice=0;

    String orderDate=null;
    String dateFiler=null;
    String dateFilerCustomer=null;
    String strStatus=StatusUtils.PENDING.toString();
    String strStatusName=StatusUtils.PENDING_TEXT;
//    List<OrderStatusData> lsOrderStatus=null;


      dateFiler = CommonUtils.getDateFilterText(strOrgId, orderDate);
      dateFilerCustomer = CommonUtils.getDateFilterCustomerText(strOrgId, strCustId, orderDate);

     String forderno=orderNumber;


    String strFilter=CommonUtils.getOrderSearchFilterText(name,mobile,selectedServiceTypeData.name ,forderno);

    OrderData bd=new OrderData(id, orderNumber, selectedServiceTypeData.id, selectedServiceTypeData.name, selectedBranchData.id, selectedBranchData.name, 0, 0, strStatus,strStatusName, strOrgId, dateFiler, dateFilerCustomer, strCustId,
        name, email, mobile, address, description, orderDateCount, strFilter, strUserId, modifiedTime);
    bd.targetDate=orderDateCount;


    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      print("Order Save Data : "+bd.id);
      CommonUtils.showToast(CommonUtils.dataSavedSuccess);

      String strMsgText= MessageTextUtils.getNewOrderText(selectedServiceTypeData.name,forderno,name,mobile,address);
      for(int i=0;i<alNewSMSUsers.length;i++){
        UserData ud=alNewSMSUsers[i];
        print("SMS Data : "+ud.mobile);
        MessageAPI msgSMStoUser=MessageAPI(context,true,database,pr,null,MessageTextUtils.getCommonSubject(),strMsgText, MessageStatus.PENDING,strOrgId, MessageType.NEW_BOOKING,companyData.countryCode,ud.mobile,SMSUtils.SENDER);
      }

//      goBack();

    }).catchError((e) => print(e));

  }

  String random() {
    Random generator = new Random();

    int num = generator.nextInt(99999) + 99999;
    if (num < 100000 || num > 999999) {
      num = generator.nextInt(99999) + 99999;
      if (num < 100000 || num > 999999) {
        throw new Exception("Unable to generate PIN at this time..");
      }
    }
    return num.toString();
  }

  void goBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }


  void checkMobileNumberExistUser(){


    try {
      var mobile = mobileController.text.trim();
      isMobileNumberAvailable=0;
      tempCustomerData=null;
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_CUSTOMER_INFO).child(strOrgId);
      Query qref=myRef.orderByChild("mobile").equalTo(mobile);

      CommonUtils.showProgressBar( pr);
      qref.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          print("snap.hasData " + " " + mobile);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                print("key " + key);
                print("val " + values["mobile"]);
                CustomerData bd = CustomerData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.mobile + " " + mobile);

                  if (bd.mobile == mobile) {
                      isMobileNumberAvailable = 1;
                      tempCustomerData=bd;
                      setTextFieldValue(bd.name, nameController);
                      setTextFieldValue(bd.email, emailController);
                      setTextFieldValue(bd.address, addressController);

                  }
                }
              }
            });
          }

        }
      });

    } catch (e) {
      print(e.toString());
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


  validate() {
    var name = nameController.text.trim();
    var mobile = mobileController.text.trim();
    var emailId = emailController.text.trim();
    var address = addressController.text.trim();
    var description = descriptionController.text.trim();


    if (selectedServiceTypeData!=null&&selectedBranchData!=null&&name.length > 0 &&mobile.length > 0&&mobile.length== 10 &&description.length>0&&(emailId.length==0||(emailId.length > 0 && EmailValidator.Validate(emailId)))) {

        saveCustomerInfo(name,mobile,emailId,address,description);

    } else {

      if(selectedServiceTypeData==null){
        setState(() {
          isServiceTypeError=true;
        });
      }

      if(selectedBranchData==null){
        setState(() {
          isBranchError=true;
        });
      }

      if (name.length == 0) {
        setState(() {isName = false;});
      }

      if (description.length == 0) {
        setState(() {isDescription = false;});
      }

      if (mobile.length == 0) {
        setState(() {isMobile = false;
        _mobileError="Enter mobile number";});
      }else if(mobile.length != 10){
        setState(() {isMobile = false;
        _mobileError="Enter 10 digit mobile number";});
      }

      if(emailId.length >0&&!EmailValidator.Validate(emailId)){
        setState(() {isEmail = false;
        _emailError="Enter valid email id";});
      }



    }
  }


  @override
  Widget build(BuildContext context) {

//    PreferenceUtils.getInstance();

//    final String strOrgId = ModalRoute.of(context).settings.arguments;

//    MaterialPageRoute(
//        builder: (context) => DetailScreen(),
//        // Pass the arguments as part of the RouteSettings. The
//        // DetailScreen reads the arguments from these settings.
//        settings: RouteSettings(
//          arguments: todos[index],
//        )

    if(isFirst){
      isFirst=false;
      initData();
    }


    final nameField = TextField(
      onChanged: (value) {
        setState(() {isName = true;});
      },
      controller: nameController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Name",
          errorText: isName ? null : "Enter name",
          border:outlineInputBorder),
    );

//    void _onCountryChange(CountryCode countryCode) {
//      //Todo : manipulate the selected country code here
//      print("New Country selected: " + countryCode.toString());
//      defaultCountryCode=countryCode.toString();
//    }
//
//    final countryPickerField= CountryCodePicker(
//      onChanged:_onCountryChange,
//      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
//      initialSelection: 'IN',
//      favorite: [defaultCountryCode,'IN'],
//      // optional. Shows only country name and flag
//      showCountryOnly: false,
//      // optional. Shows only country name and flag when popup is closed.
//      showOnlyCountryWhenClosed: false,
//      // optional. aligns the flag and the Text left
//      alignLeft: false,
//
//
//    );



    final mobileField = TextField(
      onChanged: (value) {

        try{
          var mobile = mobileController.text.trim();

          if(mobile.length==10){
            setState(() {isMobile = true;});
            checkMobileNumberExistUser();

          }else{
            setState(() {isMobile = false;
            _mobileError="Enter 10 digit mobile number";});
          }
        }catch (e){
          print(e.toString());
        }


      },
      controller: mobileController,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Mobile Number",
          errorText: isMobile ? null : _mobileError,
          border:outlineInputBorder),
    );

//    final rowMobile= Row(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//      Container(
//          width: 75.0,
//          child: countryPickerField,
//          margin: EdgeInsets.fromLTRB(0, 0, 0, 5.0),
//          decoration:BoxDecoration(color: Colors.grey)
//
//        ),
//
//
//        Expanded(child:Container(
//          child: mobileField,
//          margin: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
//        )
//        )
//      ],
//    );


    final emailField = TextField(
      onChanged: (value) {
        setState(() {isEmail = true;});
      },
      controller: emailController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Email (Optional)",
          errorText: isEmail ? null : _emailError,
          border:outlineInputBorder),
    );

    final addressField = TextField(
      onChanged: (value) {
        setState(() {isAddress = true;});
      },
      controller: addressController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Address (Optional)",
          errorText: isAddress ? null : "Enter Address",
          border:outlineInputBorder),
    );

    final descriptionField = TextField(
      onChanged: (value) {
        setState(() {isDescription = true;});
      },
      controller:descriptionController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Description",
          errorText: isDescription ? null : "Enter Description",
          border:outlineInputBorder),
    );


    final ddServiceType=Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color: Theme.of(context).accentColor, style: BorderStyle.solid, width: 0.80),
      ),
      child:DropdownButton<NameData>(
      isExpanded: true,
      hint:  Text("Select Service Type"),
      value: selectedServiceTypeData,
      onChanged: (NameData Value) {
        print("OnChange : "+Value.name);
        setState(() {
          selectedServiceTypeData = Value;
          isServiceTypeError=false;
        });
      },
      items: alServiceType.map((NameData data) {
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

    final ddBranch=Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color: Theme.of(context).accentColor, style: BorderStyle.solid, width: 0.80),
      ),
      child:DropdownButton<CompanyData>(
      isExpanded: true,
      hint:  Text("Select Branch"),
      value: selectedBranchData,
      onChanged: (CompanyData Value) {
        print("OnChange : "+Value.name);
        setState(() {
          selectedBranchData = Value;
          isBranchError=false;
        });
      },
      items: alBranch.map((CompanyData data) {
        return  DropdownMenuItem<CompanyData>(
          value: data,
          child: Row(
            children: <Widget>[
              SizedBox(width: 10,),
              Text(
                data.name+" - "+data.city,
                style:  style,
              ),
            ],
          ),
        );
      }).toList(),
    ));

    final submitButton = Material(
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
          validate();

        },
        child: Text("Save",
            textAlign: TextAlign.center,
            style: buttonStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );


//    String strOrgId = prefs.getString(PreferenceUtils.PREF_COMPANYID);
//    if(strOrgId!=null) {
//      getCompanyDetails(strOrgId);
//    }





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
      body:
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20.0),
                ddServiceType,
                SizedBox(height: 5.0),
                Visibility(
                  child:Text("Select Service Type",style: styleError,),
                  visible: isServiceTypeError,
                ),
                SizedBox(height: 15.0),
                ddBranch,
                SizedBox(height: 5.0),
                Visibility(
                  child:Text("Select Branch",style: styleError,),
                  visible: isBranchError,
                ),
                SizedBox(height: 15.0),
                mobileField,
                SizedBox(height: 15.0),
                nameField,
                SizedBox(height: 15.0),
                emailField,
                SizedBox(height: 15.0),
                addressField,
                SizedBox(height: 15.0),
                descriptionField,
                SizedBox(
                  height: 35.0,
                ),
                submitButton,
                SizedBox(
                  height: 25.0,
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