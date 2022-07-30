import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class StatusList extends StatefulWidget {
  StatusList({Key? key}) : super(key: key);

  @override
  State<StatusList> createState() => _StatusListState();
}

class _StatusListState extends State<StatusList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1c252c),
        title: Text("My Status"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('status')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              } else {
                var data = snapshot.data?.get("status");

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            CachedNetworkImageProvider(data[index]['url']),
                      ),
                      title: Text("0 views"),
                      subtitle: Text("15 mins ago"),
                      trailing: IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('status')
                                .doc(userId)
                                .update({
                              "status": FieldValue.arrayRemove([data[index]])
                            });
                          },
                          icon: Icon(Icons.delete)),
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
