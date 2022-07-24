import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:status_view/status_view.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/status/statusview.dart';

import '../homepage.dart';

List statusList = [];

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  getList() {
    FirebaseFirestore.instance
        .collection('status')
        .doc(userId)
        .snapshots()
        .listen((event) {
      statusList = event.get('status');
    });
  }

  @override
  void initState() {
    statusList = [];
    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              color: Color(0xff0e171c),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (statusList.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusViewPage(
                                id: userId,
                              ),
                            ));
                      }
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Badge(
                            toAnimate: false,
                            showBadge: statusList.isEmpty ? true : false,
                            position: BadgePosition(bottom: 1, start: 30),
                            badgeColor: Color(0xff168670),
                            badgeContent: Icon(
                              Icons.add,
                              size: 13,
                              color: Colors.white,
                            ),
                            child: statusList.isEmpty
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage: CachedNetworkImageProvider(
                                        userData.photoURL),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('status')
                                        .where("senderId", isEqualTo: userId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      var data;
                                      var statlen;
                                      if (!snapshot.hasData) {
                                        return Text("No messages");
                                      } else if (snapshot.hasData &&
                                          snapshot.data!.docs.isEmpty) {
                                        return Badge(
                                          toAnimate: false,
                                          position: BadgePosition(
                                              bottom: 1, start: 30),
                                          badgeColor: Color(0xff168670),
                                          badgeContent: Icon(
                                            Icons.add,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    userData.photoURL),
                                          ),
                                        );
                                      } else {
                                        data = snapshot.data!.docs;
                                        statlen = data[0]['status'].length;
                                        return StatusView(
                                          radius: 30,
                                          spacing: 15,
                                          strokeWidth: 2,
                                          indexOfSeenStatus: statlen,
                                          numberOfStatus:
                                              data[0]['status'].length,
                                          padding: 4,
                                          centerImageUrl: data[0]['status']
                                              [statlen - 1]['url'],
                                          seenColor: Colors.grey,
                                          unSeenColor: Colors.green,
                                        );
                                      }
                                    }),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My status",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Tap to add status update",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
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
                            return SizedBox();
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isEmpty) {
                            return SizedBox();
                          } else {
                            return ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data?.length,
                              itemBuilder: (context, index) {
                                var statlen = data![index]['status'].length;
                                Timestamp t = data[index]["status"][statlen - 1]
                                    ['sendTime'];
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
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        StatusView(
                                          radius: 30,
                                          spacing: 15,
                                          strokeWidth: 2,
                                          // indexOfSeenStatus: 2,
                                          numberOfStatus:
                                              data[index]['status'].length,
                                          padding: 4,
                                          centerImageUrl: data[index]['status']
                                              [statlen - 1]['url'],
                                          seenColor: Colors.grey,
                                          unSeenColor: Colors.green,
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
                                                style: TextStyle(
                                                    color: Colors.grey)),
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
            Positioned(
                height: h,
                width: w,
                child: image == null
                    ? SizedBox()
                    : Container(
                        color: Colors.black,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Image.file(
                                image!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ],
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
