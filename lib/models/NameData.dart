import 'package:firebase_database/firebase_database.dart';

class NameData{

   String id;
   String name;
   String values;
   bool selected;
   bool status;
   String orgId;
   int deleted;
   int createdTime;
   int modifedTime;


  NameData(this.id,this.name,this.values,this.status,this.orgId,this.deleted,this.createdTime,this.modifedTime);


   NameData.fromSnapshot(DataSnapshot snapshot) :
         id = snapshot.value["id"],
         name = snapshot.value["name"],
         values = snapshot.value["values"],
         status = snapshot.value["status"],
         orgId = snapshot.value["orgId"],
         deleted = snapshot.value["deleted"],
         createdTime = snapshot.value["createdTime"],
         modifedTime = snapshot.value["modifedTime"];

   NameData.fromJson(Map<dynamic, dynamic> json):
         id = json["id"],
         name = json["name"],
         values = json["values"],
         status = json["status"],
         orgId = json["orgId"],
         deleted = json["deleted"],
         createdTime = json["createdTime"],
         modifedTime = json["modifedTime"];


   toJson() {
     return {
       "id": id,
       "name": name,
       "values": values,
       "status": status,
       "orgId": orgId,
       "deleted": deleted,
       "createdTime": createdTime,
       "modifedTime": modifedTime
     };
   }

}