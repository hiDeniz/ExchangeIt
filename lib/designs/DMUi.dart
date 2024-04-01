import 'package:flutter/material.dart';
import 'package:exchangeit/designs/dialogHistUi.dart';
import 'package:exchangeit/routes/DialogHistPage.dart';

class contact extends StatefulWidget {
  String name;
  NetworkImage profileImg;
  String senderId;

  contact({
    Key? key,
    required this.name,
    required this.profileImg,
    required this.senderId,
  }) : super(key: key);

  @override
  State<contact> createState() => _contactState();
}

class _contactState extends State<contact> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DialogPage(
              profileImg: widget.profileImg,
              senderName: widget.name,
              senderId: widget.senderId,
            );
          }));
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: widget.profileImg,
                maxRadius: 30,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.name,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ));
  }
}
