import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/FirestoreServices.dart';

class privateBaseScreenView extends StatefulWidget {
  privateBaseScreenView({Key? key, required this.uid}) : super(key: key);

  String uid;

  @override
  State<privateBaseScreenView> createState() => _privateBaseScreenViewState();
}

class _privateBaseScreenViewState extends State<privateBaseScreenView> {
  String buttonStat = "Follow";

  int totalFollower = 0;
  int totalFollowing = 0;
  String profilepp = "";
  String Bio = "";
  String uni = "";

  final currId = FirebaseAuth.instance.currentUser!.uid;

  Future getuserInfo() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.uid).get();
    totalFollower = await docSnap.get('followerCount');
    totalFollowing = await docSnap.get('followingCount');
    profilepp = await docSnap.get('profileIm');
    Bio = await docSnap.get('bio');
    uni = await docSnap.get('university');
  }

  @override
  Widget build(BuildContext context) {
    Size sizeapp = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getuserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Profile");
          }
          return Container(
            child: Column(
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(profilepp),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Text(
                                        "$totalFollower",
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
                              SizedBox(width: 15),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Text(
                                        "$totalFollowing",
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned.fill(
                                          child: Container(
                                            margin: const EdgeInsets.all(3.0),
                                            padding: const EdgeInsets.all(3.0),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              border: Border.all(width: 1.5),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(16.0),
                                            primary: Colors.black,
                                            textStyle:
                                                const TextStyle(fontSize: 15),
                                            fixedSize: Size(
                                                sizeapp.width * 0.75 - 80, 50),
                                          ),
                                          onPressed: () {
                                            //updateFollower();
                                            setState(() {
                                              buttonStat =
                                                  buttonStat == "Requested"
                                                      ? "Follow"
                                                      : "Requested";
                                            });
                                          },
                                          child: Text(
                                            buttonStat,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Text(
                        "$uni",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
          );
        });
  }
}
