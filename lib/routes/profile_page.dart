import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/Objects/PostBase.dart';
import 'package:exchangeit/main.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/models/Styles.dart';
import 'package:exchangeit/routes/SettingsPage.dart';
import 'package:exchangeit/routes/ZoomPhotoView.dart';
import 'package:exchangeit/routes/profile_page_gallery.dart';
import 'package:exchangeit/services/Appanalytics.dart';
import 'package:exchangeit/services/FirestoreServices.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/routes/profile_page_base_screen.dart';
import 'package:exchangeit/routes/profile_page_posts.dart';
import 'package:exchangeit/routes/profile_page_location.dart';
import 'package:provider/provider.dart';

import '../Objects/NewPostClass.dart';
import '../Objects/UserClass.dart';
import 'FF_list.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics? analytics;
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

String username = '';
Future getusername(var uid) async {
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

currentusercheck() {
  var _user = FirebaseAuth.instance.currentUser;
  if (_user == null) {
    print('user yok');
  } else {
    print('user var');
    print('Firebase user:${_user.uid}');
  }
}

int totalLike = 0;
int TotalDislike = 0;

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  int totalFollower = 0;
  int totalFollowing = 0;
  String profilepp = "";
  String Bio = "";
  String uni = "";
  List<UserPost> myPosts = [];
  List checkher = [];
  Future getPosts(var uid) async {
    myPosts = [];
    checkher = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();

    for (var message in snapshot.docs) {
      totalLike = message.get('totalLike');
      print(totalLike);
      TotalDislike = message.get('totalDislike');
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
      if (!checkher.contains(message.id)) {
        myPosts.add(post);
        checkher.add(message.id);
      }
    }
  }

  void initState() {
    setState(() {
      myPosts.clear();
      checkher.clear();
    });
  }

  Future getuserInfo() async {
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(_userid).get();
    totalFollower = await docSnap.get('followerCount');
    totalFollowing = await docSnap.get('followingCount');
    profilepp = await docSnap.get('profileIm');
    Bio = await docSnap.get('bio');
    uni = await docSnap.get('university');
  }

  var _userid;
  late TabController _ProfileController = TabController(length: 3, vsync: this);
  String buttonChanger = "Follow";
  @override
  Widget build(BuildContext context) {
    currentusercheck();
    var user = Provider.of<appUser?>(context);
    _userid = user?.uid;
    if (_userid != FirebaseAuth.instance.currentUser?.uid) {
      print("user null döndü");
      _userid = FirebaseAuth.instance.currentUser?.uid;
    }
    Appanalytics.setLogEventUtil(eventName: 'Profile_Page_Viewed');
    return FutureBuilder(
        future: Future.wait(
          [getusername(_userid), getPosts(_userid), getuserInfo()],
        ),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingScreen(message: "Loading profile page");
          }
          print("mypost array lenght: ${myPosts.length}");
          NetworkImage pp = NetworkImage(profilepp);
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
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            CurrentuserID: _userid,
                          ),
                        )).then((value) => setState(() {}));
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
                                                      userId: _userid,
                                                    ))),
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
                                                      userId: _userid,
                                                    ))),
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
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 200),
                                    child: Column(
                                        children: myPosts
                                            .map(
                                                (mappingpost) => BaseDesingPost(
                                                    post: mappingpost,
                                                    delete: () {
                                                      FirestoreService
                                                          .userCollection
                                                          .doc(_userid)
                                                          .collection('posts')
                                                          .doc(mappingpost
                                                              .postId)
                                                          .delete();
                                                      setState(() {});
                                                    },
                                                    like: () {},
                                                    searched: false))
                                            .toList()),
                                  ),
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
