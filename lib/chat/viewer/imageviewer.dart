import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewPage extends StatefulWidget {
  var url;

  ImageViewPage({Key? key, this.url}) : super(key: key);

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1c252c),
      ),
      body: Center(
        child: CachedNetworkImage(imageUrl: widget.url),
      ),
    );
  }
}
