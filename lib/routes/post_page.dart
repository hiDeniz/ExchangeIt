import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Objects/PostBase.dart';
import '../models/Colors.dart';

class postPageView extends StatefulWidget {
  postPageView(
      {Key? key, required this.pf, required this.pID, required this.ownerID})
      : super(key: key);
  final dynamic pf;
  dynamic pID;
  dynamic ownerID;
  @override
  State<postPageView> createState() => _postPageViewState();
}

class commentInfo extends StatelessWidget {
  final String avatar;
  final String name;
  final String timeAgo;
  final String text;

  commentInfo({
    Key? key,
    required this.avatar,
    required this.name,
    required this.timeAgo,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(this.avatar),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        this.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      ' · $timeAgo',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  this.text,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _postPageViewState extends State<postPageView> {
  var _textController = TextEditingController();

  var currID = FirebaseAuth.instance.currentUser!.uid;
  Future sendComment(String str) async {
    if (str == "") return;
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(currID).get();
    String avatarUrl = docSnapshot.get("profileIm");
    String name = docSnapshot.get("username");
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.ownerID)
        .collection("posts")
        .doc(widget.pID)
        .collection("comments")
        .add({
      "avatar": avatarUrl,
      "name": name,
      "date":
          DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()).toString(),
      "comment": str,
    }).then((value) => _textController.text = "");

    DocumentSnapshot commentListSnap = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.ownerID)
        .collection("posts")
        .doc(widget.pID)
        .get();
    List currList = commentListSnap.get('comments');
    currList.add(1);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.ownerID)
        .collection("posts")
        .doc(widget.pID)
        .update({'comments': currList});

    setState(() {});
  }

  List commentList = [];
  List checker = [];
  Future getComments() async {
    QuerySnapshot commentSnap = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.ownerID)
        .collection("posts")
        .doc(widget.pID)
        .collection("comments")
        .orderBy("date", descending: false)
        .get();
    for (var comments in commentSnap.docs) {
      commentInfo temp = commentInfo(
        avatar: comments.get('avatar'),
        name: comments.get('name'),
        timeAgo: comments.get('date'),
        text: comments.get('comment'),
      );
      if (!checker.contains(comments.id)) {
        commentList.add(temp);
        checker.add(comments.id);
      }
    }
  }

  var input;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Exchangeit'),
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.appBarColor,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              BaseDesingPost(
                  post: widget.pf,
                  delete: () {
                    setState(() {});
                  },
                  like: () {},
                  searched: false),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: _textController,
                        onChanged: (text) {
                          input = text;
                        },
                        decoration: InputDecoration(
                          labelText: 'Share your comment...',
                          labelStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(width: 1, color: Colors.black),
                            //borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        obscureText: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  FloatingActionButton(
                    onPressed: () async {
                      await sendComment(input);
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  SizedBox(width: 5)
                ],
              ),
              FutureBuilder(
                  future: getComments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      //commentList.clear();
                      return Container(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    return Container(
                      child: ListView.separated(
                        controller: ScrollController(),
                        shrinkWrap: true,
                        itemCount: commentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return commentList[index];
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          height: 2,
                          thickness: 3,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
        //bottomSheet: shareComment(),
      ),
    );
  }
}
