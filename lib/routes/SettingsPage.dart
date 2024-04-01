import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/SettingsOptions/ProfileEdit.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/routes/LoginPage.dart';
import 'package:exchangeit/services/FirestoreServices.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../services/Appanalytics.dart';
import '../services/auth.dart';

showDialogueForWaiting(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => WaitingScreen(
          message: "Your account visibility is changing, please wait..."));
}

hideProgressDialogue(BuildContext context) {
  Navigator.of(context).pop(WaitingScreen(
      message: "Your account visibility is changing, please wait..."));
}

//var _currentuser = FirebaseAuth.instance.currentUser;
//var FireId = _currentuser!.uid;
bool Privchecher = true;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key, this.analytics, this.CurrentuserID})
      : super(key: key);
  final FirebaseAnalytics? analytics;
  var CurrentuserID;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService authService = AuthService();
  Future checkPrivate() async {
    print("check girdi");
    print("idsi bu:${widget.CurrentuserID}");
    try {
      DocumentSnapshot curruser =
          await FirestoreService.userCollection.doc(widget.CurrentuserID).get();
      Privchecher = curruser.get("checkPrivate");
    } catch (e) {
      print("hata bu:$e");
    }
  }

  Future makePrivate() async {
    if (Privchecher == false) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.CurrentuserID)
          .update({
        'checkPrivate': true,
      });
    }
    if (Privchecher == true) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.CurrentuserID)
          .update({
        'checkPrivate': false,
      });
    }
  }

  Future UserDelete() async {
    final _user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot Deleted =
        await FirestoreService.userCollection.doc(widget.CurrentuserID).get();
    List followers = Deleted.get('followers');
    List following = Deleted.get('following');
    //kendini takip edenlerden following kısmından çıkarma
    for (int i = 0; i < followers.length; i++) {
      String followerId = followers[i];

      DocumentSnapshot follower =
          await FirestoreService.userCollection.doc(followerId).get();

      List followingArray = [];

      followingArray = follower.get('following');
      int followingCount = follower.get('followingCount');

      followingArray.remove(widget.CurrentuserID);

      await FirestoreService.userCollection.doc(followerId).update({
        'following': followingArray,
        'followingCount': followingCount - 1,
      });
    }
    //Takip ettiklerinin follower kısmından çıkmalı
    for (int i = 0; i < following.length; i++) {
      String followingId = following[i];

      DocumentSnapshot follower =
          await FirestoreService.userCollection.doc(followingId).get();

      List followerArray = [];

      followerArray = follower.get('followers');
      int followerCount = follower.get('followerCount');

      followerArray.remove(widget.CurrentuserID);

      await FirestoreService.userCollection.doc(followingId).update({
        'followers': followerArray,
        'followerCount': followerCount - 1,
      });
    }
    var user = FirebaseAuth.instance.currentUser!;
    print('Silirken gereken uid: ${user.uid}');
    user.delete();
    await FirestoreService.userCollection.doc(widget.CurrentuserID).delete();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "Settings Page");
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: Future.wait([checkPrivate()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Settings page");
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text("Settings"),
                centerTitle: true,
                backgroundColor: AppColors.appBarColor,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile()));
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 30,
                    ),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        primary: Colors.black,
                        fixedSize: Size(size.width, size.height * 0.1)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      showDialogueForWaiting(context);
                      await makePrivate();
                      hideProgressDialogue(context);
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            elevation: 10,
                            content: Text('Profile visibility updated'),
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });
                    },
                    icon: const Icon(
                      Icons.visibility_off,
                      size: 30,
                    ),
                    label: Text(
                      Privchecher == false
                          ? 'Make private profile'
                          : 'Make public profile',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        primary: Colors.black,
                        fixedSize: Size(size.width, size.height * 0.1)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, 'PassChange');
                    },
                    icon: const Icon(
                      Icons.password,
                      size: 30,
                    ),
                    label: Text(
                      "Change password",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        primary: Colors.black,
                        fixedSize: Size(size.width, size.height * 0.1)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await UserDelete();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/Login', (Route<dynamic> route) => false);
                    },
                    icon: Icon(
                      Icons.delete_rounded,
                      size: 30,
                    ),
                    label: Text(
                      "Delete account",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        primary: Colors.black,
                        fixedSize: Size(size.width, size.height * 0.1)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool _facebooklogin =
                          await prefs.getBool('facebooklogin') ?? false;
                      bool _googlelogin =
                          await prefs.getBool('googlelogin') ?? false;
                      if (_facebooklogin == true) {
                        await prefs.setBool('facebooklogin', false);
                        await AuthService().FacebookLogout();
                      }
                      if (_googlelogin == true) {
                        await prefs.setBool('googlelogin', false);
                        await AuthService().googleLogout();
                      }
                      if (_facebooklogin == false && _googlelogin == false) {
                        print("signout yaptım");
                        AuthService().signOut();
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/Login', (Route<dynamic> route) => false);
                    },
                    icon: Icon(
                      Icons.logout_outlined,
                      size: 30,
                    ),
                    label: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        primary: Colors.black,
                        fixedSize: Size(size.width, size.height * 0.1)),
                  ),
                ],
              ),
            );
          }
        });
  }
}
