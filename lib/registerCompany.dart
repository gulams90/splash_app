import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:splash_app/utils/CommonUtils.dart';
import 'package:splash_app/utils/DatabaseUtils.dart';
import 'models/CompanyData.dart';
import 'models/UserData.dart';
import 'utils/LicenseUtils.dart';


class registerCompany extends StatefulWidget {

  @override
  _RegisterScreenState createState() => new _RegisterScreenState();
}



class _RegisterScreenState extends State<registerCompany> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
  TextStyle styleAppName = TextStyle(
      fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle buttonStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0);
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0));

//  File _image;
//
//  Future getImage() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
//
//    setState(() {
//      _image = image;
//    });
//  }


//  Future<bool> checkAndRequestCameraPermissions() async {
//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
//    if (permission != PermissionStatus.granted) {
//      Map<PermissionGroup, PermissionStatus> permissions =
//      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
//      return permissions[PermissionGroup.camera] == PermissionStatus.granted;
//    } else {
//      return true;
//    }
//  }
//
//  Future _getPhoto() async {
//    if (await checkAndRequestCameraPermissions()) {
//      var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
//
//      if (imageFile != null) {
//        setState(() {
//          _image = imageFile;
//        });
//
//      }
//    }
//  }


//  Future<bool> checkAndRequestCameraPermissions() async {
//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//    if (permission != PermissionStatus.granted) {
//      Map<PermissionGroup, PermissionStatus> permissions =
//      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
//      return permissions[PermissionGroup.storage] == PermissionStatus.granted;
//    } else {
//      return true;
//    }
//  }
//
//  Future _getPhoto() async {
//    if (await checkAndRequestCameraPermissions()) {
//
//      var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
//
//      if (imageFile != null) {
//        setState(() {
//          _image = imageFile;
//        });
//
//      }
//    }
//  }





  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  bool isName = true;
  bool isMobile = true;
  bool isEmail = true;
  bool isPassword = true;
  bool isAddress = true;
  bool isCity = true;
  bool isState = true;
  bool isCountry = true;
  bool _obscureText=true;
  bool isPasswordVisible=true;

  String strTitle="Register";

  var _emailError="";
  var _mobileError="";
  var _passwordError="";

  var isMobileNumberAvailable=0;
  ProgressDialog pr;
  bool isFirst=true;

  int createdTime;
  CompanyData companyData;


//  SharedPreferences prefs =  SharedPreferences.getInstance() as SharedPreferences;

//  final databaseReference = Firestore.instance;
  final database = FirebaseDatabase.instance;


//  @override
//  void initState() {
//    super.initState();
//    print("regCompany initState................");
//    initData();
//  }

  initData() async {
    print("regCompany initData................");
    pr = CommonUtils.getProgressDialog(context);
    String strEditId= ModalRoute.of(context).settings.arguments;

    if(strEditId!=null) {
      setState(() {
        strTitle="Company Info";
        isPasswordVisible=false;
      });

      getCompanyDetails(strEditId);
    }
  }

  void registerRequest(var name,var countryCode,var mobile,var email,var password,var address,var city,var state,var country) async {
    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_COMPANY);

    String id=null;
    if(companyData!=null){
      id=companyData.id;
    }else{
      id= _companyRef.push().key;
    }

    final String orgId=id;

    if(companyData!=null){
      saveCompanyInfo(_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country,companyData.logo );
    }else{
      saveCompanyInfo(_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country,null );
    }

//    if(_image!=null){
//      uploadCompanyLogo(_image,_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country);
//    }else{
//      if(companyData!=null){
//        saveCompanyInfo(_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country,companyData.logo );
//      }else{
//        saveCompanyInfo(_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country,null );
//      }
//
//    }


  }


//  void uploadCompanyLogo(File flimage, DatabaseReference _companyRef,String orgId,var name,var countryCode,var mobile,var email,var password,var address,var city,var state,var country) async {
//    CommonUtils.showProgressBar( pr);
//
//    String strPath=flimage.path;
//    String fname=strPath.substring(strPath.lastIndexOf("/"));
//    StorageReference riversRef = FirebaseStorage.instance.ref().child("iMount/"+orgId+"/images/"+fname);
//    final StorageUploadTask task =await riversRef.putFile(flimage);
//    StorageTaskSnapshot taskSnapshot = await task.onComplete;
//    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//
//    CommonUtils.hideProgressBar( pr);
//    if(downloadUrl!=null){
//      saveCompanyInfo(_companyRef,orgId,name,countryCode,mobile,email,password,address,city,state,country,downloadUrl );
//    }
//
//  }

  void saveCompanyInfo(DatabaseReference _companyRef,String orgId,var name,var countryCode,var mobile,var email,var password,var address,var city,var state,var country,String logo) async  {


//    String id=_companyRef.push().key;

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    if(createdTime==0){
      createdTime=modifedTime;
    }

    int licenseinfo=LicenseUtils.ACTIVATED;

    if(companyData!=null){
      licenseinfo=companyData.license;
    }


    CompanyData bd=new CompanyData(orgId, name, email, mobile, address, city, state, country, countryCode, logo, orgId, 0, createdTime, modifedTime, licenseinfo);
//    var future= _companyRef.child(orgId).set(bd.toJson());
    CommonUtils.showProgressBar( pr);
    _companyRef.child(orgId).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
       if(companyData==null){
        saveBranchInfo(orgId, name, countryCode, mobile, email, password, address, city, state, country, null);
       }else{
         goBack();
       }
    }).catchError((e) => print(e));

//    future.then((value) {
//      print('completed with value');
//    }, onError: (error) {
//      print('completed with error $error');
//    });

//   _companyRef.child(orgId).set(bd.toJson()).whenComplete(action()) {
//      return this.then((v) {
//        var f2 = action();
//        if (f2 is Future) return f2.then((_) => v);
//        return v
//      }, onError: (e) {
//        var f2 = action();
//        if (f2 is Future) return f2.then((_) { throw e; });
//        throw e;
//      });


    //    await databaseReference.collection("books")
//        .document("1")
//        .setData({
//      'title': 'Mastering Flutter',
//      'description': 'Programming Guide for Dart'
//    });

//    DocumentReference ref = await Firestore.instance.collection("company")
//     .add({
//      'name': name,
//      'countryCode': countryCode,
//      'mobile': mobile,
//      'email': email,
//      'password': password,
//      'address': address,
//      'city': city,
//      'state': state,
//      'country': country,
//    });
//
//
//
//    print(ref.documentID);
  }


  void saveBranchInfo(String orgId,var name,var countryCode,var mobile,var email,var password,var address,var city,var state,var country,String logo) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_BRANCH);
    String id=_companyRef.push().key;

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    if(createdTime==0){
      createdTime=modifedTime;
    }

    int licenseinfo=LicenseUtils.ACTIVATED;

    if(companyData!=null){
      licenseinfo=companyData.license;
    }


    CompanyData bd=new CompanyData(id, name, email, mobile, address, city, state, country, countryCode, logo, orgId, 0, createdTime, modifedTime, licenseinfo);
//    var future= _companyRef.child(orgId).set(bd.toJson());
    CommonUtils.showProgressBar( pr);
    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      saveUserInfo(bd, orgId, name, countryCode, mobile, email, password, address, city, state, country);
    }).catchError((e) => print(e));

  }


  void saveUserInfo(CompanyData bdata,String orgId,var name,var countryCode,var mobile,var email,var password,var address,var city,var state,var country) async  {

    DatabaseReference _companyRef = database.reference().child(DatabaseUtils.TBL_USER);
    String id=_companyRef.push().key;

    int modifedTime=new DateTime.now().millisecondsSinceEpoch;

    if(createdTime==0){
      createdTime=modifedTime;
    }

    String fcmToken=null;
//    String password=random();
    UserData bd=new UserData(id, "Admin", null, email, countryCode, mobile, fcmToken, null, null, null, null, password,true, orgId, 0, createdTime, modifedTime);
    CommonUtils.showProgressBar( pr);
    _companyRef.child(id).set(bd.toJson()).whenComplete(() {
      CommonUtils.hideProgressBar( pr);
      goBack();

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
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_USER);
      Query qref=myRef.orderByChild("mobile").equalTo(mobile);

      qref.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          print("snap.hasData " + " " + mobile);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          bool isMobileExist = false;
          if(values!=null) {
            values.forEach((key, values) {
              if (values != null) {
                print("key " + key);
                print("val " + values["mobile"]);
                UserData bd = UserData.fromJson(values);
                if (bd != null) {
                  print("from bd " + bd.mobile + " " + mobile);

                  if (bd.mobile == mobile) {
                    //Add
                    if (companyData == null) {
                      isMobileNumberAvailable = 1;
                      isMobileExist = true;
                      setState(() {
                        isMobile = false;
                        _mobileError =
                        "Mobile already exist with different account.";
                      });
                    }
                  } else {

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


  void checkMobileNumberExist(){

    try {
//        setState(() {isMobile = true;});
      var mobile = mobileController.text.trim();
      isMobileNumberAvailable=0;
      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_COMPANY);
      Query qref=myRef.orderByChild("mobile").equalTo(mobile);

      qref.once().then((DataSnapshot snapshot) {

        if (snapshot!=null) {
          print("snap.hasData " + " " + mobile);
          print("snap.hasData " + " " + snapshot.key);

          Map<dynamic, dynamic> values = snapshot.value;
          bool isMobileExist = false;
          if(values!=null){

          values.forEach((key, values) {
            if (values != null) {
              print("key " + key);
              print("val " + values["mobile"]);
              CompanyData bd = CompanyData.fromJson(values);
              if (bd != null) {
                print("from bd " + bd.mobile + " " + mobile);

                if (bd.mobile == mobile) {
                  //Edit
                  if (companyData != null) {
                    if (bd.id != companyData.id) {
                      isMobileNumberAvailable = 1;
                      isMobileExist = true;
                      setState(() {
                        isMobile = false;
                        _mobileError =
                        "Mobile already exist with different account.";
                      });
                    }
                  }
                  //Add
                  else {
                    isMobileNumberAvailable = 1;
                    isMobileExist = true;
                    setState(() {
                      isMobile = false;
                      _mobileError =
                      "Mobile already exist with different account.";
                    });
                  }
                } else {

                }
              }
            }

            // here insert all the user into a list
//            userList.add(values["name"];
          });
        }
//        });


          if (!isMobileExist) {
            if (companyData == null) {
              checkMobileNumberExistUser();
            }
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

  void getCompanyDetails(String strOrgId){

    try {

      DatabaseReference myRef = database.reference().child(DatabaseUtils.TBL_COMPANY).child(strOrgId);


//        CommonUtils.showProgressBar(pr);

//      pr.show();
      myRef.once().then((DataSnapshot snapshot) {
        CommonUtils.hideProgressBar( pr);
        if (snapshot!=null) {
          CompanyData bd = CompanyData.fromSnapshot(snapshot);

          if(bd!=null){
            companyData=bd;
            print(bd.name);
            setTextFieldValue(bd.name, nameController);
            setTextFieldValue(bd.mobile, mobileController);
            setTextFieldValue(bd.email, emailController);
            setTextFieldValue(bd.address, addressController);
            setTextFieldValue(bd.city, cityController);
            setTextFieldValue(bd.state, stateController);
            setTextFieldValue(bd.country, countryController);

          }

//          print("snap.hasData " + " " + mobile);
//          print("snap.hasData " + " " + snapshot.key);
//
//          Map<dynamic, dynamic> values = snapshot.value;
//          bool isMobileExist = false;
//          if(values!=null){
//
//            values.forEach((key, values) {
//              if (values != null) {
//                print("key " + key);
//                print("val " + values["mobile"]);
//                CompanyData bd = CompanyData.fromJson(values);
//                if (bd != null) {
//                  print("from bd " + bd.mobile + " " + mobile);
//
//                  if (bd.mobile == mobile) {
//                    //Edit
//                    if (companyData != null) {
//                      if (bd.id != companyData.id) {
//                        isMobileNumberAvailable = 1;
//                        isMobileExist = true;
//                        setState(() {
//                          isMobile = false;
//                          _mobileError =
//                          "Mobile already exist with different account.";
//                        });
//                      }
//                    }
//                    //Add
//                    else {
//                      isMobileNumberAvailable = 1;
//                      isMobileExist = true;
//                      setState(() {
//                        isMobile = false;
//                        _mobileError =
//                        "Mobile already exist with different account.";
//                      });
//                    }
//                  } else {
//
//                  }
//                }
//              }
//
//            });
//          }

        }
      });

    } catch (e) {
      print(e.toString());
    }

  }

  login() {
    var name = nameController.text.trim();
    var mobile = mobileController.text.trim();
    var emailId = emailController.text.trim();
    var password = passwordController.text.trim();
    var address = addressController.text.trim();
    var city = cityController.text.trim();
    var state = stateController.text.trim();
    var country = countryController.text.trim();



    if (name.length > 0 &&mobile.length > 0&&mobile.length== 10 &&isMobileNumberAvailable==0&&emailId.length > 0 && EmailValidator.Validate(emailId)
        &&address.length > 0&&city.length>0&&state.length>0&&country.length>0) {

      if(companyData!=null){
        registerRequest(name,CommonUtils.defaultCountryCode,mobile,emailId,password,address,city,state,country);
      }else{
        if(password.length >=6){
        registerRequest(name,CommonUtils.defaultCountryCode,mobile,emailId,password,address,city,state,country);
        }else{
          if (password.length < 6) {
            setState(() {isPassword = false;
            _passwordError="Minimum 6 digit";
            });
          }
        }
      }

//
//      Fluttertoast.showToast(
//          msg: emailController.text + " " + passwordController.text,
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIos: 1,
//          backgroundColor: Colors.red,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
    } else {
      if (name.length == 0) {
        setState(() {isName = false;});
      }

      if (mobile.length == 0) {
        setState(() {isMobile = false;
        _mobileError="Enter mobile number";});
      }else if(mobile.length != 10){
        setState(() {isMobile = false;
        _mobileError="Enter 10 digit mobile number";});
      }

      if (emailId.length == 0) {
        setState(() {isEmail = false;
        _emailError="Enter email id";});
      }else if(!EmailValidator.Validate(emailId)){
        setState(() {isEmail = false;
        _emailError="Enter valid email id";});
      }



      if (address.length == 0) {
        setState(() {isAddress = false;});
      }

      if (city.length == 0) {
        setState(() {isCity = false;});
      }

      if (state.length == 0) {
        setState(() {isState = false;});
      }

      if (country.length == 0) {
        setState(() {isCountry = false;});
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
            checkMobileNumberExist();

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
          labelText: "Email",
          errorText: isEmail ? null : _emailError,
          border:outlineInputBorder),
    );


    final passwordField = TextField(
      onChanged: (value) {
        setState(() {isPassword = true;});
      },
      controller: passwordController,
      obscureText: _obscureText,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Password",
          errorText: isPassword ? null : _passwordError,
          suffixIcon: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              semanticLabel: _obscureText ? 'show password' : 'hide password',
            ),
          ),
          border:outlineInputBorder),
    );


    final addressField = TextField(
      onChanged: (value) {
        setState(() {isAddress = true;});
      },
      controller: addressController,
      obscureText: false,
      style: style,
      maxLines: 3,
      minLines: 3,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Address",
          errorText: isAddress ? null : "Enter address",
          border:outlineInputBorder),
    );


    final cityField = TextField(
      onChanged: (value) {
        setState(() {isCity = true;});
      },
      controller: cityController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "City",
          errorText: isCity ? null : "Enter city",
          border:outlineInputBorder),
    );

    final stateField = TextField(
      onChanged: (value) {
        setState(() {isState = true;});
      },
      controller: stateController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "State",
          errorText: isState ? null : "Enter state",
          border:outlineInputBorder),
    );

    final countryField = TextField(
      onChanged: (value) {
        setState(() {isCountry = true;});
      },
      controller: countryController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: edgeInsets,
          labelText: "Country",
          errorText: isCountry ? null : "Enter country",
          border:outlineInputBorder),
    );




//    Future runnableMobile= new Future.delayed(const Duration(seconds: 3), () {
//
//      try{
//        var mobile = mobileController.text.trim();
//
//        if(mobile.length==10){
//          checkMobileNumberExist();
//
//        }else{
//          setState(() {isMobile = false;
//          _mobileError="Enter 10 digit mobile number";});
//        }
//      }catch (e){
//        print(e.toString());
//      }
//    });








    final loginButon = Material(
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
          login();

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
//                GestureDetector(
//                        onTap: () {
//                          //Insert event to be fired up when button is clicked here
//                          //in this case, this increments our `countValue` variable by one.
////                          setState(() => countValue += 1);
////                        showToast("Clicked Image...");
//                        _getPhoto();
//                        },
//                child:_image!=null?Image.file(_image,width: 125.0,height: 125.0): Image.asset("images/ola.jpg",width: 125.0,height: 125.0)),
//                SizedBox(height: 5.0),
//                Text("Select Company Logo",style: style),
//                SizedBox(height: 5.0),
//                Text("Recommended : 512 px * 512 px",style: style),
//                SizedBox(height: 30.0),
                nameField,
                SizedBox(height: 15.0),
//                rowMobile,
                mobileField,
                SizedBox(height: 15.0),
                emailField,
                SizedBox(height: 15.0),
                Visibility(
                  child:passwordField,
                  visible: isPasswordVisible,
                ),

                SizedBox(height: 15.0),
                addressField,
                SizedBox(height: 15.0),
                cityField,
                SizedBox(height: 15.0),
                stateField,
                SizedBox(height: 15.0),
                countryField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
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