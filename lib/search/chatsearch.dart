// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat/messagepage.dart';
import '../main.dart';

class ChatSearch extends StatefulWidget {
  const ChatSearch({Key? key}) : super(key: key);

  @override
  State<ChatSearch> createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff1c252c),
            title: Card(
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xff1c252c),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...'),
                onChanged: (val) {
                  setState(() {
                    name = val;
                  });
                },
              ),
            )),
        body: Container(
          color: Color(0xff0e171c),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where("userid", isNotEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        if (name.isEmpty) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MessagePage(
                                      rid: snapshot.data!.docs[index]['userid'],
                                      uid: userId,
                                      profilePic: snapshot.data!.docs[index]
                                          ['userimage'],
                                      name: snapshot.data!.docs[index]
                                          ['username'],
                                    ),
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 27,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  snapshot.data!.docs[index]
                                                      ['userimage']),
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
                                                  color: Colors.white),
                                            ),
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
                          );
                        }
                        if (data['username']
                            .toString()
                            .toLowerCase()
                            .startsWith(name.toLowerCase())) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MessagePage(
                                      rid: snapshot.data!.docs[index]['userid'],
                                      uid: userId,
                                      profilePic: snapshot.data!.docs[index]
                                          ['userimage'],
                                      name: snapshot.data!.docs[index]
                                          ['username'],
                                    ),
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 27,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  snapshot.data!.docs[index]
                                                      ['userimage']),
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
                                                  color: Colors.white),
                                            ),
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
                          );
                        }
                        return Container();
                      });
            },
          ),
        ));
  }
}
