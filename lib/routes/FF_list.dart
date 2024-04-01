import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/FirestoreServices.dart';

class FFList extends StatefulWidget {
  const FFList({Key? key, required this.pageName, required this.userId})
      : super(key: key);
  final String pageName;
  final dynamic userId;
  @override
  State<FFList> createState() => _FFListState();
}

class FFinfo extends StatelessWidget {
  final String avatar;
  final String username;

  FFinfo({
    Key? key,
    required this.avatar,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(this.avatar),
            ),
          ),
          Expanded(
              child:
                  Text(this.username, style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }
}

List<FFinfo> _ffList = [];

class _FFListState extends State<FFList> {
  Future createFFlist() async {
    DocumentSnapshot CurrentuserSnap =
        await FirestoreService.userCollection.doc(widget.userId).get();
    _ffList.clear();
    List allFF = [];
    if (widget.pageName == "Follow") {
      allFF = await CurrentuserSnap.get('following');
    }
    if (widget.pageName == "Followers") {
      allFF = await CurrentuserSnap.get('followers');
    }

    for (var i = 0; i < allFF.length; i++) {
      if (allFF[i] != widget.userId) {
        DocumentSnapshot tempSnapshot =
            await FirestoreService.userCollection.doc(allFF[i]).get();
        dynamic username = tempSnapshot.get('username');
        dynamic pp = tempSnapshot.get('profileIm');
        FFinfo temp = FFinfo(
          avatar: pp,
          username: username,
        );
        _ffList.add(temp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait(
          [createFFlist()],
        ),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading page");
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text(
                widget.pageName,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            body: Container(
              color: Colors.white,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return _ffList[index];
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 0,
                ),
                itemCount: _ffList.length,
              ),
            ),
          );
        });
  }
}
