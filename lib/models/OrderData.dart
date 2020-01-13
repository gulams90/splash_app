import 'package:firebase_database/firebase_database.dart';

import 'NameData.dart';
import 'OrderStatusData.dart';

class OrderData{
   String id;
   String orderNumber;
   String serviceId;
   String serviceTypeData;
   String branchId;
   String branchName;
   int price;
   int totalPrice;
   String status;
   String statusName;
//   List<OrderStatusData> orderStatus;
   String orgId;
   String datefilter;
   String datefilterUser;
   String customerId;
   String customerName;
   String customerEmail;
   String customerMobile;
   String customerAddress;
   String description;
   String orderedDate;
   String targetDate;
   String assignedUserId;
   String userId;
   String filter;
   int rating;
   String customerComment;
   int time;

  OrderData(this.id,this.orderNumber,this.serviceId,this.serviceTypeData,this.branchId,this.branchName,this.price,this.totalPrice,this.status,this.statusName,
      this.orgId,this.datefilter,this.datefilterUser,
   this.customerId,this.customerName,this.customerEmail,this.customerMobile,
      this.customerAddress,this.description,this.orderedDate,this.filter,this.userId,this.time);

   OrderData.fromSnapshot(DataSnapshot snapshot) :
         id = snapshot.value["id"],
         orderNumber = snapshot.value["orderNumber"],
         serviceId = snapshot.value["serviceId"],
         serviceTypeData = snapshot.value["serviceTypeData"],
         branchId = snapshot.value["branchId"],
         branchName = snapshot.value["branchName"],
         price = snapshot.value["price"],
         totalPrice = snapshot.value["totalPrice"],
         status = snapshot.value["status"],
         statusName = snapshot.value["statusName"],
//         orderStatus = snapshot.value["orderStatus"],
         orgId = snapshot.value["orgId"],
         datefilter = snapshot.value["datefilter"],
         datefilterUser = snapshot.value["datefilterUser"],
         customerId = snapshot.value["customerId"],
         customerName = snapshot.value["customerName"],
         customerEmail = snapshot.value["customerEmail"],
         customerMobile = snapshot.value["customerMobile"],
         customerAddress = snapshot.value["customerAddress"],
         description = snapshot.value["description"],
         orderedDate = snapshot.value["orderedDate"],
         filter = snapshot.value["filter"],
         userId = snapshot.value["userId"],
         targetDate= snapshot.value["targetDate"],
         time = snapshot.value["time"];


   OrderData.fromJson(Map<dynamic, dynamic> json):
         id = json["id"],
         orderNumber = json["orderNumber"],
         serviceId = json["serviceId"],
         serviceTypeData = json["serviceTypeData"],
         branchId = json["branchId"],
         branchName = json["branchName"],
         price = json["price"],
         totalPrice = json["totalPrice"],
         status = json["status"],
         statusName = json["statusName"],
//         orderStatus = json["orderStatus"],
         orgId = json["orgId"],
         datefilter = json["datefilter"],
         datefilterUser = json["datefilterUser"],
         customerId = json["customerId"],
         customerName = json["customerName"],
         customerEmail = json["customerEmail"],
         customerMobile = json["customerMobile"],
         customerAddress = json["customerAddress"],
         description = json["description"],
         orderedDate = json["orderedDate"],
         filter = json["filter"],
         userId = json["userId"],
         targetDate= json["targetDate"],
         time = json["time"];



   toJson() {
     return {
       "id": id,
       "orderNumber": orderNumber,
       "serviceId": serviceId,
       "serviceTypeData": serviceTypeData,
       "branchId": branchId,
       "branchName": branchName,
       "price": price,
       "totalPrice": totalPrice,
       "status": status,
       "statusName": statusName,
//       "orderStatus": orderStatus,
       "orgId": orgId,
       "datefilter": datefilter,
       "datefilterUser": datefilterUser,
       "customerId": customerId,
       "customerName": customerName,
       "customerMobile": customerMobile,
       "customerAddress": customerAddress,
       "description": description,
       "orderedDate": orderedDate,
       "filter": filter,
       "userId": userId,
       "targetDate": targetDate,
       "time": time
     };
   }


}