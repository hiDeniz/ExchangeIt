import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/main.dart';
import 'package:exchangeit/routes/UserSearch.dart';
import 'package:exchangeit/routes/private_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../Objects/NewPostClass.dart';
import '../services/FirestoreServices.dart';
import 'FeedProvider.dart';

class SearchMain extends StatefulWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  State<SearchMain> createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> with TickerProviderStateMixin {
  void buttonPressed() {
    print('Button Pressed in Function');
  }

  late TabController _controller = TabController(length: 4, vsync: this);
  @override
  Widget build(BuildContext context) {
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 170, 229),
        title: Text('Search'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent),
                indicatorColor: Colors.purpleAccent,
                indicatorWeight: 2,
                labelPadding: EdgeInsets.symmetric(horizontal: 40.0),
                tabs: [
                  Tab(
                    text: 'People',
                    icon: Icon(Icons.people_alt),
                  ),
                  Tab(
                    text: 'Post',
                    icon: Icon(Icons.comment),
                  ),
                  Tab(
                    text: 'Location',
                    icon: Icon(Icons.edit_location),
                  ),
                  Tab(
                    text: 'Topics',
                    icon: Icon(Icons.lightbulb_outlined),
                  ),
                ],
                controller: _controller,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                SingleChildScrollView(child: SearchPeople()),
                SingleChildScrollView(child: SearchPost()),
                SingleChildScrollView(child: SearchLocation()),
                SingleChildScrollView(child: SearchTopic()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key? key}) : super(key: key);
  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  List Searchposts = [];
  List checkher = [];
  final _currentuser = FirebaseAuth.instance.currentUser;
  int TotalLike = 0;
  int TotalDislike = 0;
  Future getPosts(var uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();

    for (var message in snapshot.docs) {
      TotalLike = message.get('totalLike');
      print(TotalLike);
      TotalDislike = message.get('totalDislike');
      List comment = message.get('comments');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0, 10);
      String posttopic = message.get('topic');
      String postLocation = message.get('location');
      if (postLocation.toLowerCase().contains(loc.toLowerCase())) {
        UserPost post = UserPost(
          postId: message.id,
          content: message.get('content').toString(),
          imageurl: message.get('imageUrl').toString(),
          date: date,
          totalLike: TotalLike,
          commentCount: comment.length,
          comments: comment,
          postownerID: uid,
          topic: posttopic,
          totalDislike: TotalDislike,
        );
        if (!checkher.contains(message.id)) {
          Searchposts.add(post);
          checkher.add(message.id);
        }
      }
    }
  }

  Future getUsers() async {
    Searchposts.clear();
    Searchposts = [];
    checkher=[];
    var DocumentUser =
        await FirebaseFirestore.instance.collection('Users').get();
    for (var doc in DocumentUser.docs) {
      var userid = doc['userId'];
      await getPosts(userid);
    }
  }

  final _firestore = FirebaseFirestore.instance;
  final myController = TextEditingController();
  void buttonPressed() {
    print('Button Pressed in Function');
  }

  String loc = "";
  void Starter(String val) {
    setState(() {
      loc = val.trim();
      Searchposts = [];
      checkher.clear();
      print(loc);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size app2size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            enableSuggestions: true,
            cursorColor: Colors.green,
            onChanged: (val) => Starter(val),
          ),
        ),
        FutureBuilder(
            future: getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: Column(
                      children: Searchposts.map((currentpost) => FeedProvider(
                          post: currentpost,
                          delete: () {},
                          like: () {},
                          searched: true)).toList(),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }
}

bool Private = false;
Future IsSearchProfilePrivate(var searchID) async {
  DocumentSnapshot docSnap =
      await FirestoreService.userCollection.doc(searchID).get();
  Private = await docSnap.get('checkPrivate');
}

class SearchPeople extends StatefulWidget {
  const SearchPeople({Key? key}) : super(key: key);
  @override
  State<SearchPeople> createState() => _SearchPeopleState();
}

class _SearchPeopleState extends State<SearchPeople> {
  final _firestore = FirebaseFirestore.instance;
  void buttonPressed() {
    print('Button Pressed in Function');
  }

  String user = "";
  void Starter(String val) {
    setState(() {
      user = val.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference usersRef = _firestore.collection('Users');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            enableSuggestions: true,
            cursorColor: Colors.green,
            onChanged: (val) => Starter(val),
          ),
        ),
        Container(
          color: Colors.white38,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(
                  color: Color.fromARGB(255, 0, 170, 229),
                  thickness: 5.0,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: user != "" && user != null
                        ? usersRef
                            .where("userSearch", arrayContains: user)
                            .snapshots()
                        : usersRef.where("username", isNull: false).snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return Center(
                            child: Text('Bir Hata Oluştu, Tekrar Deneyiniz'));
                      } else {
                        if (asyncSnapshot.hasData) {
                          List<DocumentSnapshot> listOfDocumentSnap =
                              asyncSnapshot.data!.docs;
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: listOfDocumentSnap.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        '${listOfDocumentSnap[index].get('profileIm')}',
                                      ),
                                      radius: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    child: Container(
                                      child: Text(
                                        '@${listOfDocumentSnap[index].get('username')}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UserSearch(
                                                  SearchedId:
                                                      listOfDocumentSnap[index]
                                                          .get('userId'))));

                                      /*
                                      await IsSearchProfilePrivate(
                                          listOfDocumentSnap[index]
                                              .get('userId'));
                                      if (Private) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  privateProfileView(
                                                      uid: listOfDocumentSnap[
                                                              index]
                                                          .get('userId'))),
                                        );
                                        print(
                                            '@${listOfDocumentSnap[index].get('userId')}');
                                      } else {}

                                       */
                                    },
                                  ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(
                              color: Color.fromARGB(255, 0, 170, 229),
                              thickness: 5.0,
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SearchTopic extends StatefulWidget {
  const SearchTopic({Key? key}) : super(key: key);

  @override
  State<SearchTopic> createState() => _SearchTopicState();
}

class _SearchTopicState extends State<SearchTopic> {
  List Searchposts = [];
  List checkher = [];
  final _currentuser = FirebaseAuth.instance.currentUser;
  int TotalLike = 0;
  int TotalDislike = 0;
  Future getPosts(var uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();

    for (var message in snapshot.docs) {
      TotalLike = message.get('totalLike');
      print(TotalLike);
      TotalDislike = message.get('totalDislike');
      List comment = message.get('comments');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0, 10);
      String posttopic = message.get('topic');
      String postLocation = message.get('location');
      if (posttopic.toLowerCase().contains(topic.toLowerCase())) {
        UserPost post = UserPost(
            postId: message.id,
            content: message.get('content').toString(),
            imageurl: message.get('imageUrl').toString(),
            date: date,
            totalLike: TotalLike,
            commentCount: comment.length,
            comments: comment,
            postownerID: uid,
            topic: posttopic,
            location: postLocation,
            totalDislike: TotalDislike);
        if (!checkher.contains(message.id)) {
          Searchposts.add(post);
          checkher.add(message.id);
        }
      }
    }
  }

  Future getUsers() async {
    Searchposts.clear();
    Searchposts = [];
    checkher=[];
    var DocumentUser =
        await FirebaseFirestore.instance.collection('Users').get();
    for (var doc in DocumentUser.docs) {
      var userid = doc['userId'];
      await getPosts(userid);
    }
  }

  String topic = "";
  void Starter(String val) {
    setState(() {
      topic = val.trim();
      Searchposts = [];
      checkher.clear();
      print(topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            enableSuggestions: true,
            cursorColor: Colors.green,
            onChanged: (val) => Starter(val),
          ),
        ),
        FutureBuilder(
            future: getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Searchposts.clear();
                return Container(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: Column(
                      children: Searchposts.map((currentpost) => FeedProvider(
                          post: currentpost,
                          delete: () {},
                          like: () {},
                          searched: true)).toList(),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class SearchPost extends StatefulWidget {
  const SearchPost({Key? key}) : super(key: key);

  @override
  State<SearchPost> createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  final _firestore = FirebaseFirestore.instance;
  void buttonPressed() {
    print('Button Pressed in Function');
  }

  List Searchposts = [];
  List checkher = [];
  final _currentuser = FirebaseAuth.instance.currentUser;
  int TotalLike = 0;
  int TotalDislike = 0;
  Future getPosts(var uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();

    for (var message in snapshot.docs) {
      TotalLike = message.get('totalLike');
      print(TotalLike);
      TotalDislike = message.get('totalDislike');
      List comment = message.get('comments');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String postcontent = message.get('content').toString();
      String date = d.toString().substring(0, 10);
      String posttopic = message.get('topic');
      String postLocation = message.get('location');
      if (postcontent.toLowerCase().contains(content.toLowerCase())) {
        UserPost post = UserPost(
            postId: message.id,
            content: postcontent,
            imageurl: message.get('imageUrl').toString(),
            date: date,
            totalLike: TotalLike,
            commentCount: comment.length,
            comments: comment,
            postownerID: uid,
            topic: posttopic,
            totalDislike: TotalDislike);
        if (!checkher.contains(message.id)) {
          Searchposts.add(post);
          checkher.add(message.id);
        }
      }
    }
  }

  Future getUsers() async {
    Searchposts.clear();
    Searchposts = [];
    checkher=[];
    var DocumentUser =
        await FirebaseFirestore.instance.collection('Users').get();
    for (var doc in DocumentUser.docs) {
      var userid = doc['userId'];
      await getPosts(userid);
    }
  }

  String content = "";
  void Starter(String val) {
    setState(() {
      content = val.trim();
      Searchposts = [];
      checkher.clear();
      print(content);
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference usersRef = _firestore.collection('Users');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            enableSuggestions: true,
            cursorColor: Colors.green,
            onChanged: (val) => Starter(val),
          ),
        ),
        FutureBuilder(
            future: getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Searchposts.clear();
                return Container(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: Column(
                      children: Searchposts.map((currentpost) => FeedProvider(
                          post: currentpost,
                          delete: () {},
                          like: () {},
                          searched: true)).toList(),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }
}
