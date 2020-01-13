import 'package:firebase_database/firebase_database.dart';

class SMSData{
   String id;
   String title;
   String message;
   String status;
   String orgId;
   String type;
   String countryCode;
   String mobile;
   String smsSender;
   int time;
   String date;
   String monthFilter;


  SMSData(this.id,this.title,this.message,this.status,this.orgId,this.type,this.countryCode,this.mobile,this.smsSender);

   SMSData.fromSnapshot(DataSnapshot snapshot) :
          id = snapshot.value["id"],
          title = snapshot.value["title"],
          message = snapshot.value["message"],
          status = snapshot.value["status"],
          orgId = snapshot.value["orgId"],
          type = snapshot.value["type"],
          countryCode = snapshot.value["countryCode"],
          mobile = snapshot.value["mobile"],
          smsSender = snapshot.value["smsSender"],
          time = snapshot.value["time"],
          date = snapshot.value["date"],
          monthFilter = snapshot.value["monthFilter"];


   SMSData.fromJson(Map<dynamic, dynamic> json):
          id = json["id"],
          title = json["title"],
          message = json["message"],
          status = json["status"],
          orgId = json["orgId"],
          type = json["type"],
          countryCode = json["countryCode"],
          mobile = json["mobile"],
          smsSender = json["smsSender"],
          time = json["time"],
          date = json["date"],
          monthFilter = json["monthFilter"];



   toJson() {
      return {
         "id": id,
         "title": title,
         "message": message,
         "status": status,
         "orgId": orgId,
         "type": type,
         "countryCode": countryCode,
         "mobile": mobile,
         "smsSender": smsSender,
         "time": time,
         "date": date,
         "monthFilter": monthFilter
      };
   }

}