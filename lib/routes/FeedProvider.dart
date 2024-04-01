import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/models/Styles.dart';
import 'package:exchangeit/routes/post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';

import '../Objects/NewPostClass.dart';
import '../SettingsOptions/PostEdit.dart';
import '../designs/reportSystem.dart';

class FeedProvider extends StatefulWidget {
  var name;
  final UserPost post;
  final VoidCallback delete;
  final VoidCallback like;
  bool searched;
  FeedProvider(
      {required this.post,
      required this.delete,
      required this.like,
      required this.searched});
  @override
  State<FeedProvider> createState() => _FeedProviderState();
}

class _FeedProviderState extends State<FeedProvider> {
  final _currentuser = FirebaseAuth.instance.currentUser;
  bool Isliked = false;
  bool IsDisliked = false;
  Future getName() async {
    final currUser = FirebaseAuth.instance.currentUser!.uid;
    print(currUser);
    DocumentSnapshot idSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currUser)
        .get();

    widget.name = idSnapshot.get('username');
  }

  Future<bool> PostalreadyDisliked() async {
    DocumentSnapshot liked = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .collection('posts')
        .doc(widget.post.postId)
        .get();
    DocumentSnapshot userinfos = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .get();
    Postusername = userinfos['username'];
    location = liked.get('location');
    List<dynamic> listOfDislikes = [];
    listOfDislikes = liked.get('dislikedBy');
    if (listOfDislikes.contains(_currentuser!.uid)) {
      return true;
    }
    return false;
  }

  Future DislikeButtonTapped(context, bool isDisLiked, post) async {
    bool getDisliked = false;

    DocumentSnapshot disliked = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .collection('posts')
        .doc(widget.post.postId)
        .get();

    List<dynamic> allDislike = [];

    allDislike = disliked.get('dislikedBy');

    if (isDisLiked == false) {
      allDislike.add(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalDislike': widget.post.totalDislike + 1,
        'dislikedBy': allDislike,
      }).then((value) => getDisliked = true);

      setState(() {
        post.totalDislike = post.totalDislike + 1;
      });

      DocumentSnapshot Sender = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentuser!.uid)
          .get();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('notifications')
          .add({
        'datetime': DateTime.now(),
        'notification': 'You get a dislike from ${Sender['username']}!',
        'Posturl': widget.post.imageurl,
        'uid': _currentuser!.uid,
        'IsfollowReq': 'no',
        'postId': widget.post.postId,
      });

      IsDisliked = getDisliked;
    } else {
      allDislike.remove(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalDislike': widget.post.totalDislike - 1,
        'dislikedBy': allDislike,
      }).then((value) => getDisliked = false);

      setState(() {
        post.totalDislike = post.totalDislike - 1;
      });

      IsDisliked = getDisliked;
    }
  }

  Future<bool> PostalreadyLiked() async {
    DocumentSnapshot CurrentPost = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .collection('posts')
        .doc(widget.post.postId)
        .get();
    DocumentSnapshot DocSnapInfo = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .get();
    Postusername = DocSnapInfo['username'];
    location = CurrentPost.get('location');
    List<dynamic> AllLikers = [];
    AllLikers = CurrentPost.get('likedBy');
    if (AllLikers.contains(_currentuser!.uid)) {
      return true;
    }
    return false;
  }

  Future<bool> LikeButtonTapped(context, bool isLiked, post) async {
    bool getliked = false;

    DocumentSnapshot DocSnapPost = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .collection('posts')
        .doc(widget.post.postId)
        .get();

    List<dynamic> AllLikers = [];

    AllLikers = DocSnapPost.get('likedBy');

    if (isLiked == false) {
      AllLikers.add(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalLike': widget.post.totalLike + 1,
        'likedBy': AllLikers,
      }).then((value) => getliked = true);

      setState(() {
        post.totalLike = post.totalLike + 1;
      });

      DocumentSnapshot info = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentuser!.uid)
          .get();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('notifications')
          .add({
        'datetime': DateTime.now(),
        'notification': 'You get a like from ${info['username']}!',
        'Posturl': widget.post.imageurl,
        'uid': _currentuser!.uid,
        'IsfollowReq': 'no',
        'postId': widget.post.postId,
      });

      return getliked;
    } else {
      AllLikers.remove(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalLike': widget.post.totalLike - 1,
        'likedBy': AllLikers,
      }).then((value) => getliked = false);

      setState(() {
        post.totalLike = post.totalLike - 1;
      });

      return getliked;
    }
  }

  @override
  void initState() {
    setState(() {});
  }

  String location = '';
  String Postusername = "";
  @override
  Widget build(BuildContext context) {
    if (widget.post.imageurl != "") {
      return FutureBuilder(
        future: Future.wait(
          [
            PostalreadyLiked().then((changer) => Isliked = changer),
            PostalreadyDisliked().then((value) => IsDisliked = value),
            getName(),
          ],
        ),
        builder: (context, snapshot) {
          return Card(
            shadowColor: Colors.grey,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.all(10),
            color: Colors.white30,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                Postusername,
                                style: GoogleFonts.signika(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                widget.post.date,
                                style: GoogleFonts.signika(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          _currentuser!.uid == widget.post.postownerID
                              ? IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  iconSize: 25,
                                  splashRadius: 20,
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostEditScreen(
                                              ourPost: widget.post)),
                                    );
                                  },
                                  icon: Icon(Icons.edit))
                              : IconButton(
                                  onPressed: () {
                                    showAlertDialog(context, widget.post.postId,
                                        widget.name);
                                  },
                                  iconSize: 30,
                                  icon: Icon(Icons.report_gmailerrorred_sharp)),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(widget.post.imageurl),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LikeButton(
                              circleColor: CircleColor(
                                  start: const Color(0xFFFF5722),
                                  end: const Color(0xFFFFC107)),
                              isLiked: Isliked,
                              onTap: (isLiked) {
                                return LikeButtonTapped(
                                    context, Isliked, widget.post);
                              },
                            ),
                            SizedBox(width: 5),
                            Text('${widget.post.totalLike}',
                                style: AppStyles.LikeText),
                            IconButton(
                                onPressed: () {
                                  DislikeButtonTapped(
                                      context, IsDisliked, widget.post);
                                },
                                icon: Icon(Icons.thumb_down_alt_outlined)),
                            SizedBox(width: 5),
                            Text('${widget.post.totalDislike}',
                                style: AppStyles.LikeText),
                            SizedBox(
                              width: 70,
                            ),
                            IconButton(
                                icon: Icon(Icons.insert_comment_outlined),
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => postPageView(
                                              pf: widget.post,
                                              pID: widget.post.postId,
                                              ownerID: widget.post.postownerID,
                                            )),
                                  ).then((value) => setState(() {}));
                                }),
                            SizedBox(width: 5),
                            //Text('${widget.post.commentCount}',
                            //  style: AppStyles.LikeText),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(widget.post.content),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                backgroundColor: Colors.greenAccent[200],
                                shadowColor: Colors.black, //CircleAvatar
                                label: Text("Location: $location",
                                    style: AppStyles.postLocation), //Text
                              ),
                              Chip(
                                backgroundColor: Colors.greenAccent[200],
                                shadowColor: Colors.black, //CircleAvatar
                                label: Text(
                                  "Topic: ${widget.post.topic} ",
                                  style: AppStyles.postLocation,
                                ), //Text
                              ),
                            ])),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return FutureBuilder(
          future: Future.wait(
            [
              PostalreadyLiked().then((changer) => Isliked = changer),
              PostalreadyDisliked().then((value) => IsDisliked = value),
              getName(),
            ],
          ),
          builder: (context, snapshot) {
            return Card(
              shadowColor: Colors.grey,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.all(10),
              color: Colors.white30,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  Postusername,
                                  style: GoogleFonts.signika(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  widget.post.date,
                                  style: GoogleFonts.signika(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            _currentuser!.uid == widget.post.postownerID
                                ? IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    iconSize: 25,
                                    splashRadius: 20,
                                    color: Colors.black,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PostEditScreen(
                                                    ourPost: widget.post)),
                                      );
                                    },
                                    icon: Icon(Icons.edit))
                                : IconButton(
                                    onPressed: () {
                                      showAlertDialog(context,
                                          widget.post.postId, widget.name);
                                    },
                                    iconSize: 30,
                                    icon:
                                        Icon(Icons.report_gmailerrorred_sharp)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.post.content),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LikeButton(
                              circleColor: CircleColor(
                                  start: const Color(0xFFFF5722),
                                  end: const Color(0xFFFFC107)),
                              isLiked: Isliked,
                              onTap: (isLiked) {
                                return LikeButtonTapped(
                                    context, Isliked, widget.post);
                              },
                            ),
                            SizedBox(width: 5),
                            Text('${widget.post.totalLike}',
                                style: AppStyles.LikeText),
                            IconButton(
                                onPressed: () {
                                  DislikeButtonTapped(
                                      context, IsDisliked, widget.post);
                                },
                                icon: Icon(Icons.thumb_down_alt_outlined)),
                            SizedBox(width: 5),
                            Text('${widget.post.totalDislike}',
                                style: AppStyles.LikeText),
                            SizedBox(width: 40),
                            IconButton(
                                icon: Icon(Icons.insert_comment_outlined),
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => postPageView(
                                              pf: widget.post,
                                              pID: widget.post.postId,
                                              ownerID: widget.post.postownerID,
                                            )),
                                  ).then((value) => setState(() {}));
                                }),
                            SizedBox(width: 5),
                            //Text('${widget.post.commentCount}',
                            //  style: AppStyles.LikeText),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  backgroundColor: Colors.greenAccent[200],
                                  shadowColor: Colors.black, //CircleAvatar
                                  label: Text("Location: $location",
                                      style: AppStyles.postLocation), //Text
                                ),
                                Chip(
                                  backgroundColor: Colors.greenAccent[200],
                                  shadowColor: Colors.black, //CircleAvatar
                                  label: Text(
                                    "Topic: ${widget.post.topic} ",
                                    style: AppStyles.postLocation,
                                  ), //Text
                                ),
                              ])),
                    ],
                  ),
                ),
              ),
            );
          });
    }
  }
}

@override
showAlertDialog(BuildContext context, String pid, String uname) {
  // set up the buttons
  Widget cancelButton = OutlinedButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = OutlinedButton(
    child: Text("Continue"),
    onPressed: () {
      postReport(
        postId: pid,
        reporterName: uname,
      );
      Navigator.of(context).pop();
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("AlertDialog"),
    content: Text("Are you sure you want to report this post?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
