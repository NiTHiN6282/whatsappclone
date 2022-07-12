import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
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
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController messageController = TextEditingController();
  bool emojiShowing = false;

  _onEmojiSelected(Emoji emoji) {
    messageController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  _onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/whatsappwallpaper.png"),
            fit: BoxFit.cover),
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
        body: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: scrHeight,
                width: scrWidth,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("chat")
                        .orderBy('sendTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("No messages");
                      } else if (snapshot.hasData &&
                          snapshot.data!.docs.isEmpty) {
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
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  physics: const ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if ((data[index]["senderId"] ==
                                        widget.uid ||
                                        data[index]["receiverId"] ==
                                            widget.uid) &&
                                        (data[index]["senderId"] ==
                                            widget.rid ||
                                            data[index]["receiverId"] ==
                                                widget.rid)) {
                                      Timestamp t = data[index]["sendTime"];
                                      DateTime d = t.toDate();
                                      return Align(
                                        alignment: (data[index]["senderId"] ==
                                            widget.rid
                                            ? Alignment.topLeft
                                            : Alignment.topRight),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: scrWidth - 45,
                                              minWidth: 130),
                                          child: Card(
                                            elevation: 1,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8)),
                                            color: (data[index]["senderId"] ==
                                                widget.rid
                                                ? Color(0xff18252a)
                                                : Color(0xff015c4b)),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
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
                                                            color: (data[index][
                                                            "senderId"] ==
                                                                widget.rid
                                                                ? Color(
                                                                0xff6f7a83)
                                                                : Color(
                                                                0xff6cb0a6)),
                                                          ),
                                                          DateFormat("h:mm a")
                                                              .format(d)
                                                              .toLowerCase()),
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
                          ],
                        );
                      }
                    }),
              ),
            ),
            Container(
                margin: EdgeInsets.only(bottom: 5),
                height: 60.0,
                padding: EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 325,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff1e2d34),
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  emojiShowing = !emojiShowing;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                              },
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Color(0xff6f7a83),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                  onTap: () {
                                    emojiShowing = false;
                                    setState(() {});
                                  },
                                  controller: messageController,
                                  style: const TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Message',
                                      hintStyle: TextStyle(
                                        color: Color(0xff6f7a83),
                                        fontSize: 19
                                      )
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5,
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
                )),
            Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                    onEmojiSelected: (Category category, Emoji emoji) {
                      _onEmojiSelected(emoji);
                    },
                    onBackspacePressed: _onBackspacePressed,
                    config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        progressIndicatorColor: Colors.blue,
                        backspaceColor: Colors.blue,
                        skinToneDialogBgColor: Colors.white,
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        showRecentsTab: true,
                        recentsLimit: 28,
                        replaceEmojiOnLimitExceed: false,
                        noRecents: const Text(
                          'No Recents',
                          style: TextStyle(fontSize: 20, color: Colors.black26),
                          textAlign: TextAlign.center,
                        ),
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL)),
              ),
            ),
          ],
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
