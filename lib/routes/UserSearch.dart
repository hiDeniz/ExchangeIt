import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/routes/ZoomPhotoView.dart';
import 'package:exchangeit/routes/private_profile_page.dart';
import 'package:exchangeit/routes/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Objects/NewPostClass.dart';
import '../main.dart';
import '../models/Colors.dart';
import '../services/FirestoreServices.dart';
import 'followeduser_profile_page.dart';

class UserSearch extends StatefulWidget {
  UserSearch({Key? key, required this.SearchedId}) : super(key: key);
  String SearchedId;
  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  bool Private = false;

  Future IsSearchProfilePrivate(var searchID) async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(searchID).get();
    Private = await docSnap.get('checkPrivate');
  }

  int totalFollower = 0;
  int totalFollowing = 0;
  String profilepp = "";
  String bio = "";
  String uni = "";
  String searchedUserName = "";
  int totalLike = 0;
  int TotalDislike = 0;
  bool viewerFollow = false;
  List<UserPost> SearchedPosts = [];
  Future updateFollower() async {
    List allFollowers = [];
    List allFollowings = [];
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.SearchedId).get();
    //aranan userimin follower sayısını arttırma
    //currID sayfayı ziyaret eden
    int currFollowers = docSnap.get('followerCount');
    allFollowers = docSnap.get('followers');
    allFollowers.add(currId);
    await FirestoreService.userCollection.doc(widget.SearchedId).update(
        {'followers': allFollowers, 'followerCount': currFollowers + 1});

    docSnap = await FirestoreService.userCollection.doc(currId).get();

    //isteği atan kişinin following yaptıklarına ekleme
    int currFollowing = docSnap.get('followingCount');
    allFollowings = docSnap.get('following');
    allFollowings.add(widget.SearchedId);

    await FirestoreService.userCollection.doc(currId).update(
        {'following': allFollowings, 'followingCount': currFollowing + 1});
  }

  Future getSearchedUserPosts(var uid) async {
    SearchedPosts = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();

    for (var message in snapshot.docs) {
      totalLike = message.get('totalLike');
      //TotalDislike = message.get('totalDislike');
      List comment = message.get('comments');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0, 10);
      String posttopic = message.get("topic");
      UserPost post = UserPost(
        postId: message.id,
        content: message.get('content').toString(),
        imageurl: message.get('imageUrl').toString(),
        date: date,
        totalLike: totalLike,
        commentCount: comment.length,
        comments: comment,
        postownerID: uid,
        topic: posttopic,
        totalDislike: TotalDislike,
      );
      SearchedPosts.add(post);
    }
  }

  Future getSearcheduserInfo() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.SearchedId).get();
    searchedUserName = await docSnap.get("username");
    totalFollower = await docSnap.get('followerCount');
    totalFollowing = await docSnap.get('followingCount');
    profilepp = await docSnap.get('profileIm');
    bio = await docSnap.get('bio');
    uni = await docSnap.get('university');
  }

  Future senderFollowstate() async {
    DocumentSnapshot CurrentuserSnap =
        await FirestoreService.userCollection.doc(currId).get();
    List allfollowings = [];
    allfollowings = CurrentuserSnap.get('following');
    if (allfollowings.contains(widget.SearchedId)) {
      viewerFollow = true;
    } else {
      viewerFollow = false;
    }
  }

  currentusercheck() {
    var _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      print('user yok');
    } else {
      print('user var');
      print('Firebase user:${_user.uid}');
    }
  }

  final currId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait(
            [senderFollowstate(), IsSearchProfilePrivate(widget.SearchedId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Profile");
          } else {
            if (widget.SearchedId == currId) {
              return ProfileView(analytics: null);
            } else if (viewerFollow) {
              return followedProfilePage(userId: widget.SearchedId);
            } else if (Private) {
              return privateProfileView(uid: widget.SearchedId);
            } else {
              return followedProfilePage(userId: widget.SearchedId);
            }
          }
        });
  }
}
