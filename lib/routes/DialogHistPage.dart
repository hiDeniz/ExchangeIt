import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/Objects/chatMessage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class DialogPage extends StatefulWidget {
  final currUser = FirebaseAuth.instance.currentUser!.uid;

  var chatDocId;
  var friendId;

  final NetworkImage profileImg;
  final String senderName;
  final String senderId;
  DialogPage(
      {Key? key,
      required this.profileImg,
      required this.senderName,
      required this.senderId})
      : super(key: key);

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  var _textController = TextEditingController();

  Future getName() async {
    DocumentSnapshot idSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.currUser)
        .get();

    return idSnapshot.get('username');
  }

  _DialogPageState();
  @override
  void initState() {
    super.initState();
    chats
        .where('users',
            isEqualTo: {widget.senderId: null, widget.currUser: null})
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            setState(() {
              widget.chatDocId = querySnapshot.docs.single.id;
            });
          } else {
            await chats.add({
              'users': {widget.currUser: null, widget.senderId: null},
              'names': {
                widget.currUser: await getName(),
                widget.senderId: widget.senderName,
              }
            }).then((value) => {widget.chatDocId = value});
          }
        });
  }

  Future sendMessage(String msg) async {
    if (msg == "") return;
    await chats.doc(widget.chatDocId).collection('messages').add({
      'createdOn': DateFormat('yyyy-MM-dd hh:mm:ss')
          .format(DateTime.now())
          .toString(), //DateTime.now().formattoString(),
      'msg': msg,
      'friendName': widget.senderName,
      'uid': widget.currUser,
    }).then((value) => _textController.text = "");
  }

  bool isReceiver(String friend) {
    return friend == widget.senderName;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chats
            .doc(widget.chatDocId)
            .collection('messages')
            .orderBy('createdOn', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error Occurred!'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Messages");
          }

          if (snapshot.hasData) {
            List messages = snapshot.data!.docs;
            var data;
            var input;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                elevation: 0,
                flexibleSpace: SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(right: 16),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 48),
                        CircleAvatar(
                          backgroundImage: widget.profileImg,
                          maxRadius: 20,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.senderName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 10, bottom: 10),
                            child: Align(
                              alignment:
                                  (isReceiver(messages[index]['friendName']) ==
                                          true
                                      ? Alignment.topLeft
                                      : Alignment.topRight),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: (isReceiver(
                                              messages[index]['friendName']) ==
                                          true
                                      ? Colors.grey.shade200
                                      : Colors.blue[200]),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      messages[index]['msg'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(messages[index]['createdOn'],
                                        style: TextStyle(fontSize: 8)),
                                  ],
                                ),
                              ),
                            ));
                      }),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
                      height: 60,
                      width: double.infinity,
                      color: Colors.grey.shade500,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onChanged: (text) {
                                input = text;
                              },
                              decoration: const InputDecoration(
                                hintText: "Write the message...",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          FloatingActionButton(
                            onPressed: () async {
                              await sendMessage(input);
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor: Colors.blue,
                            elevation: 0,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
