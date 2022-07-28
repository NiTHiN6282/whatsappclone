import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:whatsappclone/chat/viewer/imageviewer.dart';
import 'package:whatsappclone/chat/viewer/videoviewer.dart';
import 'package:whatsappclone/main.dart';

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

  // bool keyboardShowing = false;
  final ImagePicker _picker = ImagePicker();
  File? chatimage;
  File? file;
  dynamic url;
  String? chatfileName;
  String? ext;
  String? size;
  var bytes;

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
        // resizeToAvoidBottomInset: false,
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
                backgroundImage: CachedNetworkImageProvider(widget.profilePic),
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
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SizedBox(
                    height: scrHeight,
                    width: scrWidth,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("chat")
                            .where("senderId", whereIn: [userId, widget.rid])
                            .orderBy('sendTime', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isEmpty) {
                            return SizedBox();
                          } else {
                            var data = snapshot.data!.docs;
                            print(widget.rid);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Expanded(
                                    child: ListView.builder(
                                      addAutomaticKeepAlives: true,
                                      cacheExtent: double.infinity,
                                      reverse: true,
                                      itemCount: data.length,
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
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

                                          if (data[index]['receiverId'] ==
                                              userId) {
                                            FirebaseFirestore.instance
                                                .collection('chat')
                                                .doc(data[index]['msgId'])
                                                .update({"isRead": true});
                                          }

                                          return Align(
                                            alignment: (data[index]
                                                        ["senderId"] ==
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
                                                        BorderRadius.circular(
                                                            8)),
                                                color: (data[index]
                                                            ["senderId"] ==
                                                        widget.rid
                                                    ? Color(0xff18252a)
                                                    : Color(0xff015c4b)),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 5),
                                                child: Stack(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (data[index]
                                                                ['type'] ==
                                                            "image") {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ImageViewPage(
                                                                  url: data[
                                                                          index]
                                                                      ['file'],
                                                                ),
                                                              ));
                                                        } else if (data[index]
                                                                ['type'] ==
                                                            "file") {
                                                          if (data[index]
                                                                  ['ext'] ==
                                                              "mp4") {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          VideoViewPage(
                                                                    url: data[
                                                                            index]
                                                                        [
                                                                        'file'],
                                                                  ),
                                                                ));
                                                          } else if (data[index]
                                                                  ['ext'] ==
                                                              "jpg") {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ImageViewPage(
                                                                    url: data[
                                                                            index]
                                                                        [
                                                                        'file'],
                                                                  ),
                                                                ));
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                            right: 30,
                                                            top: 5,
                                                            bottom: 20,
                                                          ),
                                                          child: data[index][
                                                                      'type'] ==
                                                                  "text"
                                                              ? Text(
                                                                  data[index][
                                                                      "message"],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )
                                                              : data[index][
                                                                          'type'] ==
                                                                      "image"
                                                                  ? CachedNetworkImage(
                                                                      imageUrl:
                                                                          data[index]
                                                                              [
                                                                              'file'])
                                                                  : Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(Icons.file_present),
                                                                            Text(
                                                                              data[index]['fileName'],
                                                                              style: TextStyle(color: Colors.white),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(data[index]['size'].toString()),
                                                                            Text("•"),
                                                                            Text(data[index]['ext'])
                                                                          ],
                                                                        )
                                                                      ],
                                                                    )),
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
                                                                color: (data[index]
                                                                            [
                                                                            "senderId"] ==
                                                                        widget
                                                                            .rid
                                                                    ? Color(
                                                                        0xff6f7a83)
                                                                    : Color(
                                                                        0xff6cb0a6)),
                                                              ),
                                                              DateFormat(
                                                                      "h:mm a")
                                                                  .format(d)
                                                                  .toLowerCase()),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          data[index]['senderId'] ==
                                                                  userId
                                                              ? Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: data[index]
                                                                          [
                                                                          'isRead']
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors.grey[
                                                                          600],
                                                                  size: 20,
                                                                )
                                                              : SizedBox(),
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
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    emojiShowing = !emojiShowing;
                                    // keyboardShowing = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                },
                                icon: const Icon(
                                  Icons.emoji_emotions,
                                  color: Color(0xff6f7a83),
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextField(
                                      onTap: () {
                                        emojiShowing = false;
                                        // keyboardShowing = true;
                                        setState(() {});
                                        // Timer(Duration(milliseconds: 700), () {
                                        //   keyboardShowing = false;
                                        // });
                                      },
                                      onChanged: (value) {
                                        // keyboardShowing = true;
                                        setState(() {});
                                        Timer(Duration(milliseconds: 100), () {
                                          // keyboardShowing = false;
                                        });
                                      },
                                      controller: messageController,
                                      style: const TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Message',
                                          hintStyle: TextStyle(
                                              color: Color(0xff6f7a83),
                                              fontSize: 19))),
                                ),
                              ),
                              SizedBox(
                                width: 35,
                                child: IconButton(
                                  onPressed: () {
                                    pickFile();
                                  },
                                  splashRadius: 1,
                                  icon: const Icon(
                                    Icons.attach_file,
                                    color: Color(0xff6f7a83),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 35,
                                child: IconButton(
                                  onPressed: () {},
                                  splashRadius: 1,
                                  icon: const Icon(
                                    Icons.currency_rupee,
                                    color: Color(0xff6f7a83),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 35,
                                child: IconButton(
                                  splashRadius: 1,
                                  onPressed: () {
                                    imgPicker();
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Color(0xff6f7a83),
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
                            icon: Icon(messageController.text.isEmpty
                                ? Icons.mic
                                : Icons.send),
                            onPressed: () {
                              if (messageController.text.isNotEmpty) {
                                sendMessage();
                              }
                              messageController.clear();
                            },
                          ),
                        ),
                      ],
                    )),
                // Offstage(
                //   offstage: !keyboardShowing,
                //   child: SizedBox(
                //     height: 250,
                //   ),
                // ),
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
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              textAlign: TextAlign.center,
                            ),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL)),
                  ),
                ),
              ],
            ),
            Positioned(
                height: scrHeight,
                width: scrWidth,
                child: chatimage == null
                    ? SizedBox()
                    : Container(
                        color: Colors.black,
                        height: scrHeight,
                        width: scrWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Image.file(
                                chatimage!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ],
                        ),
                      ))
          ],
        ),
        floatingActionButton: Visibility(
          visible: chatimage == null ? false : true,
          child: FloatingActionButton(
            onPressed: () {
              sendPhoto();
            },
            child: Icon(Icons.send),
          ),
        ),
      ),
    );
  }

  imgPicker() async {
    XFile? file =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 45);
    if (file != null) {
      chatimage = File(file.path);
      setState(() {});
    }
  }

  sendMessage() {
    FirebaseFirestore.instance.collection('chat').add({
      "message": messageController.text,
      "receiverId": widget.rid,
      "senderId": widget.uid,
      "sendTime": DateTime.now(),
      "isRead": false,
      "type": "text"
    }).then((value) {
      value.update({"msgId": value.id});
    });
  }

  sendPhoto() {
    String fileName = DateTime.now().toString();

    var ref = FirebaseStorage.instance.ref().child('chat/$fileName');
    UploadTask uploadTask = ref.putFile(File(chatimage!.path));
    setState(() {
      chatimage = null;
    });
    uploadTask.then((res) async {
      url = (await ref.getDownloadURL()).toString();
    }).then((value) => FirebaseFirestore.instance.collection('chat').add({
          "file": url,
          "receiverId": widget.rid,
          "senderId": widget.uid,
          "sendTime": DateTime.now(),
          "isRead": false,
          "type": "image"
        }).then((value) {
          value.update({"msgId": value.id});
        }));
  }

  sendFile() {
    var ref = FirebaseStorage.instance
        .ref()
        .child('chat/${DateTime.now().toString()}');
    UploadTask uploadTask = ref.putFile(File(file!.path));
    setState(() {
      file = null;
    });
    uploadTask.then((res) async {
      url = (await ref.getDownloadURL()).toString();
    }).then((value) => FirebaseFirestore.instance.collection('chat').add({
          "file": url,
          "fileName": chatfileName,
          "receiverId": widget.rid,
          "senderId": widget.uid,
          "sendTime": DateTime.now(),
          "isRead": false,
          "type": "file",
          "ext": ext,
          "size": size,
        }).then((value) {
          value.update({"msgId": value.id});
        }));
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result.files.single.path!);
      chatfileName = result.files.single.name;
      ext = result.files.single.extension;
      bytes = result.files.single.bytes;

      size = formatBytes(result.files.single.size, 2);
      setState(() {});
      sendFile();
      print('bytes!!!!!!!!' + bytes.toString());
    } else {
      // User canceled the picker
    }
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1000, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
