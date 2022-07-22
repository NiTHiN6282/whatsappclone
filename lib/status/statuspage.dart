import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/main.dart';
import 'package:intl/intl.dart';
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusViewPage(
                          id: userId,
                        ),
                      ));
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
                          backgroundImage:
                              CachedNetworkImageProvider(userData.photoURL),
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
                            "Tap to add status update",
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
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              Container(
                padding: EdgeInsets.only(top: 20),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('status')
                        .where('senderId', isNotEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      var data = snapshot.data?.docs;
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData &&
                          snapshot.data!.docs.isEmpty) {
                        return Text("No Status");
                      } else {
                        return ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data?.length,
                          itemBuilder: (context, index) {
                            var statlen = data![index]['status'].length;
                            Timestamp t =
                                data[index]["status"][statlen - 1]['sendTime'];
                            DateTime d = t.toDate();
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StatusViewPage(
                                        id: data[index]['senderId'],
                                      ),
                                    ));
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 27,
                                      backgroundImage:
                                          CachedNetworkImageProvider(data[index]
                                              ['status'][statlen - 1]['url']),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index]['SenderName'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                            DateFormat("h:mm a")
                                                .format(d)
                                                .toLowerCase(),
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
