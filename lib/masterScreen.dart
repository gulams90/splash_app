import 'package:flutter/material.dart';
import 'package:splash_app/models/MenuData.dart';
import 'package:splash_app/utils/SubMenuUtils.dart';

class masterScreen extends StatefulWidget {
  @override
  _masterScreenState createState() => new _masterScreenState();
}

class _masterScreenState extends State<masterScreen> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat',color: Colors.black , fontSize: 16.0,fontWeight: FontWeight.bold);
  TextStyle styleAppName = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold);

  void gridItemClickEvent(MenuData mdata){

    if(mdata.id==SubMenuUtils.MENU_USERTYPE){
      Navigator.of(context).pushNamed("/userTypeList");
    }else if(mdata.id==SubMenuUtils.MENU_ACCESSRIGHTS){
      Navigator.of(context).pushNamed("/AccessRights");
    }else if(mdata.id==SubMenuUtils.MENU_STATUS){
      Navigator.of(context).pushNamed("/StatusList");
    }else if(mdata.id==SubMenuUtils.MENU_SERVICETYPE){
      Navigator.of(context).pushNamed("/serviceTypeList");
    }
  }


  @override
  Widget build(BuildContext context) {

    List alMenu=SubMenuUtils.getAllMenuList();

    return new Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text('Master'),
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
//            shrinkWrap: true,
            physics: new NeverScrollableScrollPhysics(),
            childAspectRatio: 0.7,
            children: List.generate(alMenu.length, (index) {
              MenuData md=alMenu[index];
              return  GestureDetector(
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
