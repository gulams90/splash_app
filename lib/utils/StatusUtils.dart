import 'package:splash_app/models/MenuData.dart';

class StatusUtils{
  static final int PENDING=1,
      CANCELLED=2,
      COMPLETED=3;

  static final String PENDING_TEXT= "Pending",
      CANCELLED_TEXT="Cancelled",
      COMPLETED_TEXT="Completed";

  static final String PENDING_IMAGE= "images/ic_pending_history.png",
      CANCELLED_IMAGE="images/ic_cancelled_history.png",
      COMPLETED_IMAGE="images/ic_completed_history.png";

  static List<MenuData> getAllMenuList(){
    List almenu=new List<MenuData>();
    almenu.add(new MenuData(PENDING,PENDING_TEXT,PENDING_IMAGE));
    almenu.add(new MenuData(CANCELLED,CANCELLED_TEXT,CANCELLED_IMAGE));
    almenu.add(new MenuData(COMPLETED,COMPLETED_TEXT,COMPLETED_IMAGE));
    return almenu;
  }

}