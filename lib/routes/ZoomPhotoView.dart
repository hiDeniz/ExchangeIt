import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class photoViewPage extends StatefulWidget {
  const photoViewPage({Key? key, required this.pht}) : super(key: key);
  final NetworkImage pht;
  @override
  State<photoViewPage> createState() => _photoViewPageState();
}

class _photoViewPageState extends State<photoViewPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.0,
      height: 300.0,
      child: Container(
          child: PhotoView(
        imageProvider: widget.pht,
        backgroundDecoration: BoxDecoration(color: Colors.white),
      )),
    );
  }
}
