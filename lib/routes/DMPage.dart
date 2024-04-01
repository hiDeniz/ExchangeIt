import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/Objects/DMClass.dart';
import 'package:exchangeit/designs/DMUi.dart';

import '../main.dart';
import '../services/Appanalytics.dart';
import '../services/FirestoreServices.dart';

class DMPage extends StatefulWidget {
  DMPage({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;

  @override
  State<DMPage> createState() => _DMPageState();
}

class _DMPageState extends State<DMPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<DMObj> DMusers = [];

  Future listContacts() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(uid).get();

    List contactList1 = await docSnap.get('followers');
    List contactList2 = await docSnap.get('following');
    contactList2.remove(uid);
    var contactList = [...contactList1, ...contactList2].toSet().toList();
    //var contactList=[];
    //for() {}

    /*
    DocumentSnapshot idSnapshot =
    await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    String userName = idSnapshot.get('username');
     */

    for (var follower in contactList) {
      DocumentSnapshot currSender =
          await FirestoreService.userCollection.doc(follower).get();

      String senderPic = await currSender.get('profileIm');

      DMObj contactObj = DMObj(
        profileImg: senderPic == ""
            ? NetworkImage(
                "https://i1.sndcdn.com/avatars-000322080916-3lqw29-t500x500.jpg")
            : NetworkImage(senderPic),
        senderId: currSender.get('userId'),
        name: currSender.get('username'),
      );

      DMusers.add(contactObj);
    }
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "DM Page");
    return FutureBuilder(
        future: Future.wait([listContacts()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Messages");
          }
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: AppColors.appBarColor,
                title: const Text(
                  "Direct Messages",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                          itemCount: DMusers.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: 16),
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return contact(
                              name: DMusers[index].name,
                              profileImg: DMusers[index].profileImg,
                              senderId: DMusers[index].senderId,
                            );
                          })
                    ]),
              ));
        });
  }
}
