import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatefulWidget {
  String uid;
  String rid;

  String profilePic;
  String name;

  MessagePage(
      {Key? key,
      required this.rid,
      required this.uid,
      required this.profilePic,
      required this.name})
      : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController messageController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/whatsappwallpaper.png"),fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              widget.name,
              style: TextStyle(fontSize: 18),
            ),
            leadingWidth: 100,
            backgroundColor: Color(0xff1e2d34),
            leading: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new)),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.profilePic),
                  // maxRadius: 10,
                ),
              ],
            ),
            actions: [
              Icon(size: 23, Icons.videocam),
              SizedBox(
                width: 15,
              ),
              Icon(size: 20, Icons.call),
              SizedBox(
                width: 15,
              ),
              Icon(Icons.more_vert)
            ],
          ),
          body: SizedBox(
            height: scrHeight,
            width: scrWidth,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("chat").orderBy('sendTime',descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No messages");
                  } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return Text("No messages");
                  } else {
                    var data = snapshot.data!.docs;
                    print(widget.rid);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Expanded(
                            child: ListView.builder(
                              reverse: true,
                              itemCount: data.length,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                if ((data[index]["senderId"] == widget.uid ||
                                        data[index]["receiverId"] ==
                                            widget.uid) &&
                                    (data[index]["senderId"] == widget.rid ||
                                        data[index]["receiverId"] ==
                                            widget.rid)) {
                                  Timestamp t = data[index]["sendTime"];
                                  DateTime d = t.toDate();
                                  return Align(
                                    alignment: (data[index]["senderId"] == widget.rid
                                        ? Alignment.topLeft
                                        : Alignment.topRight),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: scrWidth - 45, minWidth: 130),
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                        color: (data[index]["senderId"] ==
                                          widget.rid
                                          ? Color(0xff18252a)
                                            : Color(0xff015c4b)),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 30,
                                                top: 5,
                                                bottom: 20,
                                              ),
                                              child: Text(
                                                data[index]["message"],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                    color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 10,
                                              child: Row(
                                                children: [
                                                  Text(
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                  // 0xff6cb0a6
                                                        color: (data[index]["senderId"] ==
                                                            widget.rid
                                                            ? Color(0xff6f7a83)
                                                            : Color(0xff6cb0a6)),
                                                      ),
                                                      DateFormat("h:mm a").format(d).toLowerCase()),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  // Icon(
                                                  //   Icons.done_all,
                                                  //   size: 20,
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox();
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xff1e2d34),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                      color: Color(0xff8796a0),
                                      Icons.emoji_emotions),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                      width: 298,
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        controller: messageController,
                                        decoration: InputDecoration(
                                            hintText: 'Message',
                                            hintStyle: TextStyle(
                                                color: Color(0xff8796a0)),
                                            border: InputBorder.none),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: scrWidth / 50,
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0xff01a984),
                              ),
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  sendMessage();
                                  messageController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  sendMessage() {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(DateTime.now().toString())
        .set({
      "message": messageController.text,
      "receiverId": widget.rid,
      "senderId": widget.uid,
      "sendTime": DateTime.now()
    });
  }
}
