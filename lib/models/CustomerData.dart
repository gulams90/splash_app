import 'package:firebase_database/firebase_database.dart';

class CustomerData{

  String id;
  String name;
  String email;
  String mobile;
  String address;
  String orgId;
  int timestamp;


  CustomerData(this.id,this.name,this.email,this.mobile,this.address,this.orgId,this.timestamp);


  CustomerData.fromSnapshot(DataSnapshot snapshot) :
        id = snapshot.value["id"],
        name = snapshot.value["name"],
        email = snapshot.value["email"],
        mobile = snapshot.value["mobile"],
        address = snapshot.value["address"],
        orgId = snapshot.value["orgId"],
        timestamp = snapshot.value["timestamp"];

  CustomerData.fromJson(Map<dynamic, dynamic> json):
        id = json["id"],
        name = json["name"],
        email = json["email"],
        mobile = json["mobile"],
        address = json["address"],
        orgId = json["orgId"],
        timestamp = json["timestamp"];


  toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "mobile": mobile,
      "address": address,
      "orgId": orgId,
      "timestamp": timestamp
    };
  }

}