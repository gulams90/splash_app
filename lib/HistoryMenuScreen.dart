import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:splash_app/models/MenuData.dart';
import 'package:splash_app/utils/StatusUtils.dart';

class HistoryMenuScreen extends StatefulWidget {
  @override
  _HistoryMenuScreenState createState() => new _HistoryMenuScreenState();
}

class _HistoryMenuScreenState extends State<HistoryMenuScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);


  void gridItemClickEvent(MenuData mdata){

    if(mdata.id==StatusUtils.PENDING){
      Navigator.of(context).pushNamed("/PendingOrderList");
    }else if(mdata.id==StatusUtils.CANCELLED){
      Navigator.of(context).pushNamed("/CancelledOrderHistory");
    }else if(mdata.id==StatusUtils.COMPLETED){
      Navigator.of(context).pushNamed("/OrdersList");
    }
  }

  @override
  Widget build(BuildContext context) {

    List alMenu=StatusUtils.getAllMenuList();

    return new Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text('History Type'),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed:() => Navigator.pop(context, false),
          )
      ),
      body:Container(
          color: Colors.white,
          child: GridView.count(

            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 2,
            physics: new NeverScrollableScrollPhysics(),
            childAspectRatio: 0.7,
//            shrinkWrap: true,
            children: List.generate(alMenu.length, (index) {
              MenuData md=alMenu[index];
              return GestureDetector(
                      onTap: () {
                        gridItemClickEvent(md);

                      },
                      child:Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(md.image,width: 60,height: 60),
                              SizedBox(height: 10.0),
                              Text(md.name,style:style ,)
                            ],
                          )
//            child: Text(
//              'Item $index',
//              style: Theme.of(context).textTheme.headline,
//            ),
                      )
                  );
            }),
          )
      ),
    );
  }
}
