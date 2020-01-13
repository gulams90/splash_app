class MessageTextUtils{
   static String getNewRegistrationTitle(String name){
    String strText="Hello "+name+" !";
    return  strText;
  }

   static String getGeneralTitle(){
    String strText="Hello !";
    return  strText;
  }

   static String getOrderStatusMessageTitle(){
    String strText="Hi";
    return  strText;
  }

   static String getNewRegistrationSubject(){
    String strText="iMount User Account Information";
    return  strText;
  }

   static String getOrderStatusSubject(){
    String strText="Order Status";
    return  strText;
  }

   static String getNewRegistrationText(String userId,String pwd){
    String strText="Welcome to iMount.\nKindly use the following credentials.\n"+"User Id is Mobile number, Password : "+pwd;
    return  strText;
  }



   static String getForgotOTPSubject(){
    String strText="iMount Password Reset Information";
    return  strText;
  }

   static String getForgotOTPText(String otp){
    String strText="Use "+otp+" as OTP to Reset Password for iMount Account.";
    return  strText;
  }

   static String getStatusSubject(){
    String strText="Service Status";
    return  strText;
  }



   static String getCommonSubject(){
    String strText="Hello";
    return  strText;
  }



   static String getNewOrderText(String strServiceType,String orderNumber,String strCustName,String strCustMobile,String strCustAddress){
    String strText="New service has been booked for "+strServiceType+"."+"\nOrder No: "+orderNumber+", Customer Name : "+strCustName+", Contact No : "+strCustMobile;
    return  strText;
  }

   static String getNewOrderTexttoCustomer(String strServiceType,String orderNumber,String strCustName,String strCustMobile,String strCustAddress){
    String strText="Your service has been booked for "+strServiceType+"."+"\nOrder No: "+orderNumber+"\nThanks for choosing us.\nWe will complete your query shortly.";
    return  strText;
  }
}