
import 'package:firebase_database/firebase_database.dart';

class UserData{

   String id;
   String name;
   String userId;
   String email;
   String countryCode;
   String mobile;
   String fcmToken;
   String userType;
   String branchId;
   String branchName;
   String branchAddress;
   String password;
   bool notification;
   bool selected;
   String orgId;
   int deleted;
   int createdTime;
   int modifedTime;


   UserData(this.id,this.name,this.userId,this.email,this.countryCode,this.mobile,this.fcmToken,this.userType,this.branchId,this.branchName,this.branchAddress,this.password,this.notification,this.orgId,this.deleted,this.createdTime,this.modifedTime);



   UserData.fromSnapshot(DataSnapshot snapshot) :
         id = snapshot.value["id"],
         name = snapshot.value["name"],
         userId = snapshot.value["userId"],
         email = snapshot.value["email"],
         countryCode = snapshot.value["countryCode"],
         mobile = snapshot.value["mobile"],
         fcmToken = snapshot.value["fcmToken"],
         userType = snapshot.value["userType"],
         branchId = snapshot.value["branchId"],
         branchName = snapshot.value["branchName"],
         branchAddress = snapshot.value["branchAddress"],
         password = snapshot.value["password"],
         notification = snapshot.value["notification"],
         orgId = snapshot.value["orgId"],
         deleted = snapshot.value["deleted"],
         createdTime = snapshot.value["createdTime"],
         modifedTime = snapshot.value["modifedTime"];


   UserData.fromJson(Map<dynamic, dynamic> json):
         id = json["id"],
         name = json["name"],
         userId = json["userId"],
         email = json["email"],
         countryCode = json["countryCode"],
         mobile = json["mobile"],
         fcmToken = json["fcmToken"],
         userType = json["userType"],
         branchId = json["branchId"],
         branchName = json["branchName"],
         branchAddress = json["branchAddress"],
         password = json["password"],
         notification = json["notification"],
         orgId = json["orgId"],
         deleted = json["deleted"],
         createdTime = json["createdTime"],
         modifedTime = json["modifedTime"];



   toJson() {
     return {
       "id": id,
       "name": name,
       "userId": userId,
       "email": email,
       "countryCode": countryCode,
       "mobile": mobile,
       "fcmToken": fcmToken,
       "userType": userType,
       "branchId": branchId,
       "branchName": branchName,
       "branchAddress": branchAddress,
       "password": password,
       "notification": notification,
       "orgId": orgId,
       "deleted": deleted,
       "createdTime": createdTime,
       "modifedTime": modifedTime
     };
   }

}