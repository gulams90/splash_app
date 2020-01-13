import 'package:firebase_database/firebase_database.dart';

class OrderStatusData{
   String id;
   String statusId;
   String statusName;
   String description;
   String serviceName;
   String userId;
   int time;


  OrderStatusData(this.id,this.statusId,this.statusName,this.description,this.serviceName,this.userId,this.time);

   OrderStatusData.fromSnapshot(DataSnapshot snapshot) :
         id = snapshot.value["id"],
         statusId = snapshot.value["statusId"],
         statusName = snapshot.value["statusName"],
         description = snapshot.value["description"],
         serviceName = snapshot.value["serviceName"],
         userId = snapshot.value["userId"],
         time = snapshot.value["time"];


   OrderStatusData.fromJson(Map<dynamic, dynamic> json):
         id = json["id"],
         statusId = json["statusId"],
         statusName = json["statusName"],
         description = json["description"],
         serviceName = json["serviceName"],
         userId = json["userId"],
         time = json["time"];



   toJson() {
     return {
       "id": id,
       "statusId": statusId,
       "statusName": statusName,
       "description": description,
       "serviceName": serviceName,
       "userId": userId,
       "time": time
     };
   }

}