import 'package:splash_app/models/MenuData.dart';

class MenuUtils{
  static final int MENU_COMPANYINFO=1,
      MENU_MYACCOUNT=2,
      MENU_BRANCH=3,
      MENU_MASTER=4,
      MENU_USERS=5,
      MENU_NEW_SERVICE=6,
      MENU_SERVICE_HISTORY=7,
      MENU_SETTINGS=8;

   static final String MENU_IMAGE_COMPANYINFO= "images/ic_companyinfo.png",
      MENU_IMAGE_MYACCOUNT="images/ic_user1.png",
      MENU_IMAGE_BRANCH="images/ic_branch.png",
      MENU_IMAGE_MASTER="images/ic_master.png",
      MENU_IMAGE_USERS="images/ic_user.png",
      MENU_IMAGE_SETTINGS="images/ic_settings.png",
      MENU_IMAGE_SERVICE_HISTORY="images/ic_orders.png",
      MENU_IMAGE_NEW_SERVICE="images/ic_new_order.png";


   static final String MENU_NAME_COMPANYINFO="Company Info",
      MENU_NAME_MYACCOUNT="My Account",
      MENU_NAME_BRANCH="Branch",
      MENU_NAME_MASTER="Master",
      MENU_NAME_USERS="Users",
      MENU_NAME_SETTINGS="Settings",
      MENU_NAME_SERVICE_HISTORY="Service History",
      MENU_NAME_NEW_SERVICE="New Service";

   static List<MenuData> getAllMenuList(){
     List almenu=new List<MenuData>();
    almenu.add(new MenuData(MENU_COMPANYINFO,MENU_NAME_COMPANYINFO,MENU_IMAGE_COMPANYINFO));
    almenu.add(new MenuData(MENU_MYACCOUNT,MENU_NAME_MYACCOUNT,MENU_IMAGE_MYACCOUNT));
    almenu.add(new MenuData(MENU_BRANCH,MENU_NAME_BRANCH,MENU_IMAGE_BRANCH));
    almenu.add(new MenuData(MENU_MASTER,MENU_NAME_MASTER,MENU_IMAGE_MASTER));
    almenu.add(new MenuData(MENU_USERS,MENU_NAME_USERS,MENU_IMAGE_USERS));
    almenu.add(new MenuData(MENU_SERVICE_HISTORY,MENU_NAME_SERVICE_HISTORY,MENU_IMAGE_SERVICE_HISTORY));
    almenu.add(new MenuData(MENU_NEW_SERVICE,MENU_NAME_NEW_SERVICE,MENU_IMAGE_NEW_SERVICE));
    almenu.add(new MenuData(MENU_SETTINGS,MENU_NAME_SETTINGS,MENU_IMAGE_SETTINGS));
    return almenu;
  }


}