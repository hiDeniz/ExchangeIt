import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/Objects/NewPostClass.dart';
import 'package:exchangeit/SettingsOptions/PostEdit.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:mailer/smtp_server/gmail.dart';

import '../models/Styles.dart';
import '../routes/post_page.dart';
import '../routes/profile_page_posts.dart';

class BaseDesingPost extends StatefulWidget {
  final UserPost post;
  final VoidCallback delete;
  final VoidCallback like;
  bool searched;

  BaseDesingPost(
      {required this.post,
      required this.delete,
      required this.like,
      required this.searched});
  @override
  State<BaseDesingPost> createState() => _BaseDesingPostState();
}

class _BaseDesingPostState extends State<BaseDesingPost> {
  @override
  void initState() {
    //setState(() {});
  }

  final _currentuser = FirebaseAuth.instance.currentUser;
  bool Isliked = false;
  bool IsDisliked = false;
  bool there_is_image = true;
  String location = '';
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
    List<dynamic> listOfLikes = [];
    listOfLikes = liked.get('likedBy');
    if (listOfLikes.contains(_currentuser!.uid)) {
      return true;
    }
    return false;
  }

  Future<bool> LikeButtonTapped(context, bool isLiked, post) async {
    bool getliked = false;

    DocumentSnapshot liked = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postownerID)
        .collection('posts')
        .doc(widget.post.postId)
        .get();

    List<dynamic> allLike = [];

    allLike = liked.get('likedBy');

    if (isLiked == false) {
      allLike.add(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalLike': widget.post.totalLike + 1,
        'likedBy': allLike,
      }).then((value) => getliked = true);

      setState(() {
        post.totalLike = post.totalLike + 1;
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
        'notification': 'You get a like from ${Sender['username']}!',
        'Posturl': widget.post.imageurl,
        'uid': _currentuser!.uid,
        'IsfollowReq': 'no',
        'postId': widget.post.postId,
      });

      return getliked;
    } else {
      allLike.remove(_currentuser!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postownerID)
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'totalLike': widget.post.totalLike - 1,
        'likedBy': allLike,
      }).then((value) => getliked = false);

      setState(() {
        post.totalLike = post.totalLike - 1;
      });

      return getliked;
    }
  }

  String Postusername = "";
  @override
  Widget build(BuildContext context) {
    if (widget.post.imageurl != "") {
      return FutureBuilder(
        future: Future.wait(
          [
            PostalreadyLiked().then((changer) => Isliked = changer),
            PostalreadyDisliked().then((value) => IsDisliked = value),
          ],
        ),
        builder: (context, snapshot) {
          //print(widget.post.imageurl);
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
                          IconButton(
                              onPressed: () {},
                              iconSize: 30,
                              icon: Icon(Icons.report_gmailerrorred_sharp)),
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
                              : SizedBox.shrink(),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Spacer(),
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
                            Spacer(),
                            widget.searched == false &&
                                    _currentuser!.uid == widget.post.postownerID
                                ? IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    onPressed: widget.delete,
                                    iconSize: 25,
                                    splashRadius: 20,
                                    color: Colors.black,
                                    icon: Icon(
                                      Icons.delete_outline,
                                    ),
                                  )
                                : SizedBox.shrink(),
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
                            IconButton(
                                onPressed: () {},
                                iconSize: 30,
                                icon: Icon(Icons.report_gmailerrorred_sharp)),
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
                                : SizedBox.shrink(),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Spacer(),
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
                                                ownerID:
                                                    widget.post.postownerID,
                                              )),
                                    ).then((value) => setState(() {}));
                                  }),
                              SizedBox(width: 5),
                              //Text('${widget.post.commentCount}',
                              // style: AppStyles.LikeText),
                              Spacer(),
                              widget.searched == false
                                  ? IconButton(
                                      padding: EdgeInsets.all(0),
                                      alignment: Alignment.center,
                                      onPressed: widget.delete,
                                      iconSize: 25,
                                      splashRadius: 20,
                                      color: Colors.black,
                                      icon: Icon(
                                        Icons.delete_outline,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ]),
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
