
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils{
static final String PREF_COMPANYID="company_id",PREF_USERID="user_id",PREF_USERNAME="user_name",PREF_LOGIN_STATUS="login_status",PREF_FCM_TOKEN="fcm_token";
static SharedPreferences preference;
static getInstance() async {
  if(preference==null) {
    preference = await SharedPreferences.getInstance();
  }
}

static addStringToSF(String key,String val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, val);
}

static addIntToSF(String key,int val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, val);
}

static addDoubleToSF(String key,double val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(key, val);
}

static addBoolToSF(String key,bool val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, val);
}


static saveString(SharedPreferences prefs,String key,String val)  {
  prefs.setString(key, val);
}

static saveInt(SharedPreferences prefs,String key,int val)  {
  prefs.setInt(key, val);
}

static saveDouble(SharedPreferences prefs,String key,double val)  {
  prefs.setDouble(key, val);
}

static saveBoolean(SharedPreferences prefs,String key,bool val) {
  prefs.setBool(key, val);
}




}