import 'package:flutter/material.dart';

class dialogHist extends StatefulWidget {
  String msgContent;
  int receiver;

  dialogHist({required this.msgContent, required this.receiver});

  @override
  State<dialogHist> createState() => _dialogHistState();
}

class _dialogHistState extends State<dialogHist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
