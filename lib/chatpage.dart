import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/messagepage.dart';

import 'main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff0e171c),
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("user")
              .where("userid", isNotEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
              return Text("No Chats");
            } else {
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Color(0xff0e171c),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagePage(
                                  rid: snapshot.data!.docs[index]['userid'],
                                  uid: userId,
                                  profilePic: snapshot.data!.docs[index]
                                      ['userimage'],
                                  name: snapshot.data!.docs[index]['username'],
                                ),
                              ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 27,
                                      backgroundImage: NetworkImage(snapshot
                                          .data!.docs[index]['userimage']),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data!.docs[index]
                                              ['username'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xffafb3b5)),
                                        ),
                                        // SizedBox(
                                        //   height: 12,
                                        // ),
                                        // Text(
                                        //   snapshot.data!.docs[index]
                                        //       ['username'],
                                        //   style: TextStyle(
                                        //       color: Color(0xff728088)),
                                        // ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // Text(chatList[index]['time'],
                              //     style: TextStyle(color: Color(0xff728088)))
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
