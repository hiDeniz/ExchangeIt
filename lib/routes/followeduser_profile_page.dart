import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/Objects/PostBase.dart';
import 'package:exchangeit/main.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/models/Styles.dart';
import 'package:exchangeit/routes/FeedProvider.dart';
import 'package:exchangeit/routes/ZoomPhotoView.dart';
import 'package:exchangeit/routes/profile_page_gallery.dart';
import 'package:exchangeit/services/Appanalytics.dart';
import 'package:exchangeit/services/FirestoreServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/routes/profile_page_base_screen.dart';
import 'package:exchangeit/routes/profile_page_location.dart';
import 'package:provider/provider.dart';

import '../Objects/NewPostClass.dart';
import '../Objects/UserClass.dart';
import '../designs/reportSystem.dart';
import 'FF_list.dart';

class followedProfilePage extends StatefulWidget {
  followedProfilePage({Key? key, required this.userId}) : super(key: key);
  final dynamic userId;
  @override
  State<followedProfilePage> createState() => _followedProfilePageState();
}

final currUser = FirebaseAuth.instance.currentUser!.uid;
String username = '';
String uname = "";
Future getusername(var uid) async {
  DocumentSnapshot idSnapshot =
      await FirebaseFirestore.instance.collection('Users').doc(currUser).get();

  uname = await idSnapshot.get('username');
  if (uid != null) {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(uid).get();
    username = docSnap.get('username');
    totalFollower = docSnap.get('followerCount');
    totalFollowing = docSnap.get('followingCount');
  }
  print('Provider uid:$uid');
  print('Provider usernama: $username');
}

/*
currentusercheck() {
  var _user = FirebaseAuth.instance.currentUser;
  if (_user == null) {
    print('user yok');
  } else {
    print('user var');
    print('Firebase user:${_user.uid}');
  }
}
 */
int totalLike = 0;
int TotalDislike = 0;
List<UserPost> myPosts = [];
Future getPosts(var uid) async {
  myPosts = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('posts')
      .orderBy('datetime', descending: true)
      .get();

  for (var message in snapshot.docs) {
    totalLike = message.get('totalLike');
    print(totalLike);
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
    myPosts.add(post);
  }
}

int totalFollower = 0;
int totalFollowing = 0;
String profilepp = "";
String Bio = "";
String uni = "";

class _followedProfilePageState extends State<followedProfilePage>
    with SingleTickerProviderStateMixin {
  Future getuserInfo() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.userId).get();
    totalFollower = await docSnap.get('followerCount');
    totalFollowing = await docSnap.get('followingCount');
    profilepp = await docSnap.get('profileIm');
    Bio = await docSnap.get('bio');
    uni = await docSnap.get('university');
  }

  void initState() {
    setState(() {});
  }

  Future updateFollower() async {
    List allFollowers = [];
    List allFollowings = [];
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.userId).get();

    int currFollowers = docSnap.get('followerCount');
    allFollowers = docSnap.get('followers');
    allFollowers.add(currId);

    await FirestoreService.userCollection.doc(widget.userId).update(
        {'followers': allFollowers, 'followerCount': currFollowers + 1});

    docSnap = await FirestoreService.userCollection.doc(currId).get();

    int currFollowing = docSnap.get('followingCount');
    allFollowings = docSnap.get('following');
    allFollowings.add(widget.userId);

    await FirestoreService.userCollection.doc(currId).update(
        {'following': allFollowings, 'followingCount': currFollowing + 1});

    setState(() {});
  }

  Future negUpdateFollower() async {
    List nAllFollowers = [];
    List nAllFollowings = [];
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(widget.userId).get();

    int currFollowers = docSnap.get('followerCount');
    nAllFollowers = docSnap.get('followers');
    nAllFollowers.remove(currId);

    await FirestoreService.userCollection.doc(widget.userId).update(
        {'followers': nAllFollowers, 'followerCount': currFollowers - 1});

    docSnap = await FirestoreService.userCollection.doc(currId).get();

    int currFollowing = docSnap.get('followingCount');
    nAllFollowings = docSnap.get('following');
    nAllFollowings.remove(widget.userId);

    await FirestoreService.userCollection.doc(currId).update(
        {'following': nAllFollowings, 'followingCount': currFollowing - 1});

    setState(() {});
  }

  String followState = "Follow";

  Future isFollowCheck() async {
    DocumentSnapshot CurrentuserSnap =
        await FirestoreService.userCollection.doc(currId).get();
    List allfollowings = [];
    allfollowings = CurrentuserSnap.get('following');
    if (allfollowings.contains(widget.userId)) {
      followState = "Unfollow";
    } else {
      followState = "Follow";
    }
  }

  final currId = FirebaseAuth.instance.currentUser!.uid;

  late TabController _ProfileController = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    Appanalytics.setLogEventUtil(eventName: 'Profile_Page_Viewed');
    return FutureBuilder(
        future: Future.wait(
          [
            getusername(widget.userId),
            getPosts(widget.userId),
            getuserInfo(),
            isFollowCheck()
          ],
        ),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading profile page");
          }
          print("mypost array lenght: ${myPosts.length}");
          final NetworkImage pp = NetworkImage(profilepp);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              elevation: 0.0,
              title: Text(
                username,
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
                    showAlertDialog(context, widget.userId, uname);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: <Widget>[
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
                                      child: TextButton(
                                        child: Text(
                                          '$totalFollower',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FFList(
                                                    pageName: "Followers",
                                                    userId: widget.userId))),
                                      ),
                                    ),
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                      child: TextButton(
                                        child: Text(
                                          '$totalFollowing',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FFList(
                                                    pageName: "Follow",
                                                    userId: widget.userId))),
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
                                if (followState == "Unfollow") {
                                  followState = "Follow";
                                  totalFollower = totalFollower - 1;
                                  negUpdateFollower();
                                } else {
                                  followState = "Unfollow";
                                  totalFollower = totalFollower + 1;
                                  updateFollower();
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
                                  child: Center(child: Text(followState)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              splashColor: Colors.blueAccent,
                              onTap: () {
                                //Send Message page
                                Navigator.pushNamed(context, "DM");
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
                                  child: Center(child: Text("Send Message")),
                                ),
                              ),
                            ),
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
                    Material(
                      color: Colors.white,
                      child: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey[400],
                        indicatorWeight: 1,
                        indicatorColor: Colors.black,
                        controller: _ProfileController,
                        tabs: [
                          Tab(
                            icon: Icon(
                                IconData(0xf435, fontFamily: 'MaterialIcons')),
                          ),
                          Tab(
                            icon: Icon(
                                IconData(0xf131, fontFamily: 'MaterialIcons')),
                          ),
                          Tab(
                            icon: Icon(
                                IconData(0xf193, fontFamily: 'MaterialIcons')),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _ProfileController,
                        children: [
                          Container(
                            child: SingleChildScrollView(
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 200),
                                  child: Column(
                                      children: myPosts
                                          .map((mappingpost) => FeedProvider(
                                              post: mappingpost,
                                              delete: () {},
                                              like: () {},
                                              searched: true))
                                          .toList()),
                                ),
                              ),
                            ),
                          ),
                          Gallery(GmyPosts: myPosts),
                          Location(),
                        ],
                      ),
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
