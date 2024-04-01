import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/routes/ZoomPhotoView.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/routes/private_profile_page_base_screen.dart';
import 'package:flutter/rendering.dart';

import '../designs/reportSystem.dart';
import '../main.dart';
import '../models/Styles.dart';
import '../services/Appanalytics.dart';
import '../services/FirestoreServices.dart';

class privateProfileView extends StatefulWidget {
  privateProfileView({Key? key, required this.uid}) : super(key: key);
  final dynamic uid;
  String unameE = "";

  final currUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  State<privateProfileView> createState() => _privateProfileViewState();
}

class _privateProfileViewState extends State<privateProfileView> {
  void getName() async {
    DocumentSnapshot idSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.currUser)
        .get();

    widget.unameE = await idSnapshot.get('username');
  }

  String uname = "";
  int totalFollower = 0;
  int totalFollowing = 0;
  String profilepp = "";
  String Bio = "";
  String uni = "";
  Future getuserInfo() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.uid).get();
    uname = docSnap.get('username');
    totalFollower = await docSnap.get('followerCount');
    totalFollowing = await docSnap.get('followingCount');
    profilepp = await docSnap.get('profileIm');
    Bio = await docSnap.get('bio');
    uni = await docSnap.get('university');
  }

  Future updateRequest() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.uid).get();
    List requestList = [];
    requestList = docSnap.get('followRequests');
    requestList.add(currId);
    await FirestoreService.userCollection
        .doc(widget.uid)
        .update({'followRequests': requestList});

    setState(() {});
  }

  Future negUpdateRequest() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.uid).get();
    List requestList = [];
    requestList = docSnap.get('followRequests');
    requestList.remove(currId);
    await FirestoreService.userCollection
        .doc(widget.uid)
        .update({'followRequests': requestList});

    setState(() {});
  }

  String requestState = "Follow";

  Future isRequestedCheck() async {
    DocumentSnapshot CurrentuserSnap =
        await FirestoreService.userCollection.doc(widget.uid).get();
    List allfollowings = [];
    allfollowings = CurrentuserSnap.get('followRequests');
    if (allfollowings.contains(currId)) {
      requestState = "Requested";
    } else {
      requestState = "Follow";
    }
  }

  Future SendFollowNotif() async {
    DocumentSnapshot Senderdocsnap =
        await FirestoreService.userCollection.doc(currId).get();

    String SenderUserName = Senderdocsnap.get("username");
    await FirestoreService.userCollection
        .doc(widget.uid)
        .collection('notifications')
        .add({
      'datetime': DateTime.now(),
      'notification': '$SenderUserName wants to follow you',
      'Posturl': "",
      'uid': currId,
      'IsfollowReq': 'yes',
      'postId': "",
    });
  }

  final currId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "Private_Profile_Page");
    return FutureBuilder(
        future: Future.wait([getuserInfo(), isRequestedCheck()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Profile");
          }
          final NetworkImage pp = NetworkImage(profilepp);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              elevation: 0.0,
              title: Text(
                "$uname",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.report_gmailerrorred_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print("Reportladım useri");
                    showAlertDialog(context, widget.uid, widget.unameE);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: pp,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  photoViewPage(pht: pp)));
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Text(
                                        '$totalFollower',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Text(
                                        '$totalFollowing',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Follow',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(height: 30),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              splashColor: Colors.blueAccent,
                              onTap: () {
                                if (requestState == "Requested") {
                                  requestState = "Follow";
                                  // notification silmeyi unutma
                                  negUpdateRequest();
                                } else {
                                  requestState = "Requested";
                                  // notificationdan return gelince followrequesti guncellemeyi unutma
                                  updateRequest();
                                  SendFollowNotif();
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  width: 150,
                                  height: 40,
                                  margin: const EdgeInsets.all(3.0),
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[100],
                                    border: Border.all(
                                        width: 2.5,
                                        color: Colors.lightBlueAccent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: Center(child: Text(requestState)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Text(
                                " University: $uni",
                                style: AppStyles.WalkTextStyle,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                              child: Text(
                                "$Bio",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.lock, size: 50),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "This Account is Private",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

@override
showAlertDialog(BuildContext context, String uid, String uname) {
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
      userReport(
        userId: uid,
        reporterName: uname,
      );
      Navigator.of(context).pop();
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("AlertDialog"),
    content: Text("Are you sure you want to report this user?"),
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
