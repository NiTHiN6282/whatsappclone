import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/status/statusview.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    print(userData);
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(15),
          color: Color(0xff0e171c),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StatusViewPage(),));
                },
                child: Container(
                  child: Row(
                    children: [
                      Badge(
                        toAnimate: false,
                        position: BadgePosition(bottom: 1, start: 30),
                        badgeColor: Color(0xff168670),
                        badgeContent: Icon(
                          Icons.add,
                          size: 13,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(userData.photoURL),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My status",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Tap a add status update",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Recent updates",
                  style: TextStyle(color: Colors.grey, fontSize: 16)
              )
            ],
          ),
        ),
      ),
    );
  }
}
