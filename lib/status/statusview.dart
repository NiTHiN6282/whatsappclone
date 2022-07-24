import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StatusViewPage extends StatefulWidget {
  var id;

  StatusViewPage({Key? key, this.id}) : super(key: key);

  @override
  _StatusViewPageState createState() => _StatusViewPageState();
}

class _StatusViewPageState extends State<StatusViewPage> {
  final storyController = StoryController();
  List<StoryItem> stories = [];
  var statusList;

  getList() {
    FirebaseFirestore.instance
        .collection('status')
        .doc(widget.id)
        .snapshots()
        .listen((event) {
      statusList = event.get('status');
      if (mounted) {
        setState(() {});
        for (int i = 0; i < statusList.length; i++) {
          setState(() {
            if (statusList[i]['type'] == 'image') {
              stories.add(StoryItem.pageImage(
                  url: statusList[i]['url'], controller: storyController));
            } else if (statusList[i]['type'] == 'text') {
              stories.add(StoryItem.text(
                  title: statusList[i]['text'], backgroundColor: Colors.blue));
            } else if (statusList[i]['type'] == 'video') {
              stories.add(StoryItem.pageVideo(statusList[i]['url'],
                  controller: storyController));
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    getList();

    super.initState();
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: stories.isNotEmpty
          ? StoryView(
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              progressPosition: ProgressPosition.top,
              repeat: true,
              controller: storyController,
              storyItems: [for (int i = 0; i < stories.length; i++) stories[i]],
            )
          : CircularProgressIndicator(),
    ));
  }
}
