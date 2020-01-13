import 'package:firebase_database/firebase_database.dart';

class CompanyData{

   String id;
   String orgId;
   String name;
   String email;
   String mobile;
   String address;
   String city;
   String state;
   String country;
   String countryCode;
   String logo;
   bool selected;
   int deleted;
   int createdTime;
   int modifedTime;
   int license;


   CompanyData(this.id,this.name,this.email,this.mobile,this.address,this.city,this.state,this.country,this.countryCode,this.logo,this.orgId,this.deleted,this.createdTime,this.modifedTime,this.license);

//   String get _id => id;
//   String get _name => name;
//   String get _email => email;
//   String get _mobile => mobile;
//   String get _address => address;
//   String get _city => city;
//   String get _state => state;
//   String get _country => country;
//   String get _countryCode => countryCode;
//   String get _logo => logo;
//   String get _orgId => orgId;
//   int get _deleted => deleted;
//   int get _createdTime => createdTime;
//   int get _modifedTime => modifedTime;
//   int get _license => license;

   CompanyData.fromSnapshot(DataSnapshot snapshot) :
          id = snapshot.value["id"],
          name = snapshot.value["name"],
          email = snapshot.value["email"],
          mobile = snapshot.value["mobile"],
          address = snapshot.value["address"],
          city = snapshot.value["city"],
          state = snapshot.value["state"],
          country = snapshot.value["country"],
          countryCode = snapshot.value["countryCode"],
          logo = snapshot.value["logo"],
          orgId = snapshot.value["orgId"],
          deleted = snapshot.value["deleted"],
          createdTime = snapshot.value["createdTime"],
          modifedTime = snapshot.value["modifedTime"],
          license = snapshot.value["license"];

   CompanyData.fromJson(Map<dynamic, dynamic> json):
          id = json["id"],
          name = json["name"],
          email = json["email"],
          mobile = json["mobile"],
          address = json["address"],
          city = json["city"],
          state = json["state"],
          country = json["country"],
          countryCode = json["countryCode"],
          logo = json["logo"],
          orgId = json["orgId"],
          deleted = json["deleted"],
          createdTime = json["createdTime"],
          modifedTime = json["modifedTime"],
          license = json["license"];


   toJson() {
      return {
         "id": id,
         "name": name,
         "email": email,
         "mobile": mobile,
         "address": address,
         "city": city,
         "state": state,
         "country": country,
         "countryCode": countryCode,
         "logo": logo,
         "orgId": orgId,
         "deleted": deleted,
         "createdTime": createdTime,
         "modifedTime": modifedTime,
         "license": license
      };
   }


//   CompanyData.fromSnapshot(DataSnapshot snapshot) {
//      _id = snapshot.key;
//      _name = snapshot.value['name'];
//      _email = snapshot.value['email'];
//      _age = snapshot.value['age'];
//      _mobile = snapshot.value['mobile'];
//   }


}




