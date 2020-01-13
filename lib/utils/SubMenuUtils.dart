import 'package:splash_app/models/MenuData.dart';

class SubMenuUtils{
  static final int MENU_USERTYPE=1,
      MENU_ACCESSRIGHTS=2,
      MENU_STATUS=3,
      MENU_SERVICETYPE=4;


  static final String MENU_IMAGE_USERTYPE= "images/ic_usertype.png",
      MENU_IMAGE_ACCESSRIGHTS="images/ic_accessrights.png",
      MENU_IMAGE_STATUS="images/ic_status.png",
      MENU_IMAGE_SERVICETYPE="images/ic_servicetype.png";


  static final String MENU_NAME_USERTYPE="User Type",
      MENU_NAME_ACCESSRIGHTS="Access Rights",
      MENU_NAME_STATUS="Status",
      MENU_NAME_SERVICETYPE="Service Type";


  static List<MenuData> getAllMenuList(){
    List almenu=new List<MenuData>();
    almenu.add(new MenuData(MENU_USERTYPE,MENU_NAME_USERTYPE,MENU_IMAGE_USERTYPE));
    almenu.add(new MenuData(MENU_ACCESSRIGHTS,MENU_NAME_ACCESSRIGHTS,MENU_IMAGE_ACCESSRIGHTS));
//    almenu.add(new MenuData(MENU_STATUS,MENU_NAME_STATUS,MENU_IMAGE_STATUS));
    almenu.add(new MenuData(MENU_SERVICETYPE,MENU_NAME_SERVICETYPE,MENU_IMAGE_SERVICETYPE));
    return almenu;
  }


}