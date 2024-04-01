import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/Objects/NotificationClass.dart';
import 'package:exchangeit/designs/NotificationUi.dart';

import '../main.dart';
import '../services/FirestoreServices.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

List<NotificationObj> notifications = [];

class _NotificationViewState extends State<NotificationView> {
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

  Future getNotification() async {
    notifications.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .collection('notifications')
        .orderBy('datetime', descending: true)
        .get();

    DocumentSnapshot idSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .get();

    String userName = idSnapshot.get('username');

    for (var notification in snapshot.docs) {
      Timestamp t = notification.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0, 10);
      String nType = notification.get('IsfollowReq');
      String action = notification.get('notification');
      String senderId = notification.get('uid');
      DocumentSnapshot senderShot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(senderId)
          .get();
      String picUrl = senderShot.get('profileIm');
      print(notification.id);
      NotificationObj notObj = NotificationObj(
        nID: notification.id,
        profilePic: picUrl,
        action: action,
        timestamp: date,
        user: userName,
        sender: senderId,
        type: nType,
      );

      notifications.add(notObj);
    }
  }

  Future acceptFollowReq(senderuserID, NotificationId) async {
    DocumentSnapshot UserInfoSnap =
        await FirestoreService.userCollection.doc(currentUserID).get();
    List AllfollowerList = UserInfoSnap.get('followers');
    int totalFollower = UserInfoSnap.get('followerCount');
    List AllRequests = UserInfoSnap.get('followRequests');

    AllRequests.remove(senderuserID);
    AllfollowerList.add(senderuserID);
    totalFollower = totalFollower + 1;
    await FirestoreService.userCollection.doc(currentUserID).update({
      'followers': AllfollowerList,
      'followerCount': totalFollower,
      'followRequests': AllRequests,
    });

    DocumentSnapshot SenderSnap =
        await FirestoreService.userCollection.doc(senderuserID).get();

    List SenderFollowing = SenderSnap.get('following');
    String SenderName = SenderSnap.get("username");
    int Sendertotalfollowing = SenderSnap.get('followingCount');
    Sendertotalfollowing = Sendertotalfollowing + 1;
    SenderFollowing.add(currentUserID);

    await FirestoreService.userCollection.doc(senderuserID).update(
        {'following': SenderFollowing, 'followingCount': Sendertotalfollowing});

    await FirestoreService.userCollection
        .doc(currentUserID)
        .collection('notifications')
        .add({
      'datetime': DateTime.now(),
      'notification':
          'You accepted the follow request from $SenderName, you are now connected!',
      'Posturl': "",
      'uid': senderuserID,
      'IsfollowReq': 'followaccept',
      'postId': "",
    });
    await FirestoreService.userCollection
        .doc(currentUserID)
        .collection('notifications')
        .doc(NotificationId)
        .delete();
    setState(() {});
  }

  Future rejectFollowReq(senderuserID, NotificationId) async {
    DocumentSnapshot CurrentInfoSnap =
        await FirestoreService.userCollection.doc(currentUserID).get();
    DocumentSnapshot SenderSnap =
        await FirestoreService.userCollection.doc(senderuserID).get();
    String SenderName = SenderSnap.get("username");
    List AllRequests = CurrentInfoSnap.get('followRequests');

    AllRequests.remove(senderuserID);
    await FirestoreService.userCollection.doc(currentUserID).update({
      'followRequests': AllRequests,
    });
    await FirestoreService.userCollection
        .doc(currentUserID)
        .collection('notifications')
        .add({
      'datetime': DateTime.now(),
      'notification': 'You rejected the follow request from $SenderName!',
      'Posturl': "",
      'uid': senderuserID,
      'IsfollowReq': 'followreject',
      'postId': "",
    });

    await FirestoreService.userCollection
        .doc(currentUserID)
        .collection('notifications')
        .doc(NotificationId)
        .delete();
    setState(() {});
  }

  void deleteNotification(NotificationObj curr) {
    print(curr.nID);
    notifications.remove(curr);
    FirestoreService.userCollection
        .doc(currentUserID)
        .collection('notifications')
        .doc(curr.nID)
        .delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([getNotification()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading Notifications");
          }

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 0, 170, 229),
              title: const Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: notifications
                      .map((notification) => NotificationTile(
                            notificationObj: notification,
                            remove: () {
                              deleteNotification(notification);
                            },
                            accept: () {
                              print("accept yaptım");
                              acceptFollowReq(
                                  notification.sender, notification.nID);
                            },
                            reject: () {
                              print("reject yaptım");
                              rejectFollowReq(
                                  notification.sender, notification.nID);
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        });
  }
}
