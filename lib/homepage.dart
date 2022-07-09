import 'package:flutter/material.dart';
import 'chatpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  var checkVisibility=true;
  int _selectedIndex = 1;
  double editBottom=0;


  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this,initialIndex: 1);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_selectedIndex==0){
      setState((){
        checkVisibility=false;
      });
    }
    if(_selectedIndex!=0){
      setState((){
        checkVisibility=true;
      });
    }
    if(_selectedIndex==2){
      setState((){
        editBottom=70;
      });
    }
    if(_selectedIndex==1||_selectedIndex==3){
      setState((){
        editBottom=0;
      });
    }
    var w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1c252c),
        title: Text("WhatsApp",
          style: TextStyle(
              color: Color(0xff728088),
              fontSize: 22,
              fontWeight: FontWeight.w400
          ),),
        actions: [
          Icon(Icons.search,
              color: Color(0xff728088)),
          Icon(Icons.more_vert,
              color: Color(0xff728088))
        ],
        bottom: TabBar(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
          labelColor: Color(0xff168670),
          unselectedLabelColor: Color(0xff728088),
          indicatorColor: Color(0xff168670),
          onTap: (index) {

          },
          controller: _controller,
          tabs: [
            Container(
              width: w*0.07,
              height: 40,
              child: Center(child: Icon(Icons.camera_alt_rounded)),
            ),
            Container(
              width: w*0.24,
              height: 40,
              child: Center(child: Text("CHATS")),
            ),
            Container(
              width: w*0.24,
              height: 40,
              child: Center(child: Text("STATUS")),
            ),
            Container(
              width: w*0.24,
              height: 40,
              child: Center(child: Text("CALLS")),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          Container(
            child: Center(
              child: Text("Camera"),
            ),
          ),

          ChatPage(),

          Container(
            child: Center(
              child: Text("Status"),
            )
          ),

          Container(
            child: Center(
              child: Text("Calls"),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: checkVisibility,
        child: Stack(
          clipBehavior: Clip.none, children: [
            Positioned(
              bottom: editBottom,
                left: 5,
                width: 45,
                child: FloatingActionButton(
                  onPressed: (){

                  },
                  child: Icon(Icons.edit),
                )
            ),
            Positioned(
                child: FloatingActionButton(
                  onPressed: (){

                  },
                  child: iconCondition(),
                )
            ),
          ],
        ),
      ),
    );
  }

  iconCondition(){
    if(_selectedIndex==1){
      return Icon(Icons.message);
    }
    else if(_selectedIndex==2){
      return Icon(Icons.camera_alt_rounded);
    }
    else if(_selectedIndex==3){
      return Icon(Icons.add_call);
    }
  }
}