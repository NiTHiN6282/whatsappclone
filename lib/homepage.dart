import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsappclone/auth/login.dart';
import 'package:whatsappclone/status/statuspage.dart';

import 'chat/chatpage.dart';
import 'main.dart';

File? image;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  dynamic url;
  String? imagePath;
  late TabController _controller;
  var checkVisibility = true;
  int _selectedIndex = 1;
  double editBottom = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 0) {
      setState(() {
        checkVisibility = false;
      });
    }
    if (_selectedIndex != 0) {
      setState(() {
        checkVisibility = true;
      });
    }
    if (_selectedIndex == 2) {
      setState(() {
        editBottom = 70;
      });
    }
    if (_selectedIndex == 1 || _selectedIndex == 3) {
      setState(() {
        editBottom = 0;
      });
    }
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1c252c),
        title: Text(
          "WhatsApp",
          style: TextStyle(
              color: Color(0xff728088),
              fontSize: 22,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          Icon(Icons.search, color: Color(0xff728088)),
          SizedBox(
            width: 10,
          ),
          PopupMenuButton<int>(
            color: Color(0xff1c252c),
            itemBuilder: (context) => [
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('New group'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('New broadcast'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('Linked devices'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('Starred messages'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('Payments'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('Settings'),
                onTap: () {},
              ),
              PopupMenuItem(
                textStyle: TextStyle(color: Colors.white),
                child: Text('Logout'),
                onTap: () async {
                  await GoogleSignIn().signOut();
                  FirebaseAuth.instance
                      .signOut()
                      .then((value) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          )));
                },
              ),
            ],
            icon: Icon(
              color: Color(0xff728088),
              Icons.more_vert,
            ),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
          labelColor: Color(0xff168670),
          unselectedLabelColor: Color(0xff728088),
          indicatorColor: Color(0xff168670),
          onTap: (index) {},
          controller: _controller,
          tabs: [
            Container(
              width: w * 0.07,
              height: 40,
              child: Center(child: Icon(Icons.camera_alt_rounded)),
            ),
            Container(
              width: w * 0.24,
              height: 40,
              child: Center(child: Text("CHATS")),
            ),
            Container(
              width: w * 0.24,
              height: 40,
              child: Center(child: Text("STATUS")),
            ),
            Container(
              width: w * 0.24,
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
          StatusPage(),
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
          clipBehavior: Clip.none,
          children: [
            image == null
                ? Positioned(
                    bottom: editBottom,
                    left: 5,
                    width: 45,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      backgroundColor: Color(0xff1c252c),
                      onPressed: () {},
                      child: Icon(Icons.edit),
                    ))
                : SizedBox(),
            Positioned(
                child: FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Color(0xff168670),
              onPressed: () {
                if (_selectedIndex == 1) {
                } else if (_selectedIndex == 2) {
                  if (image == null) {
                    imgChooser();
                  } else {
                    uploadToStorage();
                  }
                } else if (_selectedIndex == 3) {}
              },
              child: iconCondition(),
            )),
          ],
        ),
      ),
    );
  }

  iconCondition() {
    if (_selectedIndex == 1) {
      return Icon(Icons.message);
    } else if (_selectedIndex == 2) {
      return image == null ? Icon(Icons.camera_alt_rounded) : Icon(Icons.done);
    } else if (_selectedIndex == 3) {
      return Icon(Icons.add_call);
    }
  }

  imgPicker(ImageSource filePath) async {
    XFile? file = await _picker.pickImage(source: filePath, imageQuality: 45);
    if (file != null) {
      image = File(file.path);
      setState(() {});
    }
  }

  uploadToStorage() {
    String fileName = DateTime.now().toString();

    var ref = FirebaseStorage.instance.ref().child('status/$fileName');
    UploadTask uploadTask = ref.putFile(File(image!.path));
    setState(() {
      image = null;
    });
    uploadTask.then((res) async {
      url = (await ref.getDownloadURL()).toString();
      statusList.add({
        'type': "image",
        'url': url,
        'sendTime': DateTime.now(),
        'viewed': []
      });
    }).then((value) =>
        FirebaseFirestore.instance.collection('status').doc(userId).set({
          'SenderName': userData.displayName,
          'senderId': userId,
          'viewed': [],
          'status': FieldValue.arrayUnion(statusList)
        }));
  }

  imgChooser() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Alert'),
              content: const Text('Choose a option'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      setState(() {
                        imgPicker(ImageSource.camera);
                      });
                    },
                    child: const Text('Camera')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        imgPicker(ImageSource.gallery);
                      });
                    },
                    child: const Text('Gallery'))
              ],
            ));
  }
}
