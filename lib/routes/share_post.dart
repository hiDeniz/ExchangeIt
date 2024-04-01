import 'dart:io' as io;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart';
import '../services/Appanalytics.dart';
import 'package:path/path.dart';

import '../services/FirestoreServices.dart';

class SharePostScreen extends StatefulWidget {
  const SharePostScreen({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<SharePostScreen> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  File? _holdImage = null;
  final _currentuser = FirebaseAuth.instance.currentUser;
  String contentPost = '';
  String location = '';
  String Posttopic = '';
  final _PostKey = GlobalKey<FormState>();
  final locationcontrol = TextEditingController();
  final contentcontrol = TextEditingController();
  final topiccontrol = TextEditingController();

  showDialogueForWaiting(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => WaitingScreen(
            message: "Your post is being created, please wait..."));
  }

  hideProgressDialogue(BuildContext context) {
    Navigator.of(context).pop(
        WaitingScreen(message: "Your post is being created, please wait..."));
  }

  Future pickImage() async {
    // ignore: deprecated_member_use
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _holdImage = File(pickedFile!.path);
    });
  }

  Future uploadPostwithImage(BuildContext context, message) async {
    showDialogueForWaiting(context);
    String fileName = basename(_holdImage!.path);
    final storageRef = FirebaseStorage.instance.ref();
    final Firebaseref = storageRef
        .child('All_App_Posts')
        .child(_currentuser!.uid)
        .child('/$fileName');

    var url;

    final FirebaseData = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    UploadTask Firestoreup;

    Firestoreup = Firebaseref.putFile(File(_holdImage!.path), FirebaseData);
    await Future.value(Firestoreup)
        .then((value) async => {
              url = await value.ref.getDownloadURL(),
              print(url),
              FirebasePostUpload(_currentuser!.uid, 0, url, message, Posttopic),
              print("Upload file path ${value.ref.fullPath}"),
              hideProgressDialogue(context),
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  elevation: 10,
                  content:
                      Text("Your Post successfully uploaded,check feed page"),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            })
        .onError((error, stackTrace) =>
            {print("Upload file path error ${error.toString()} ")});
  }

  Future FirebasePostUpload(uid, like, url, content, topic) async {
    final firestoreInstance = FirebaseFirestore.instance;

    List<String> locationList = [];
    List<String> TopicList = [];

    for (int i = 1; i <= location.length; i++) {
      locationList.add(location.substring(0, i).toLowerCase());
    }
    for (int i = 1; i <= topic.length; i++) {
      TopicList.add(topic.substring(0, i).toLowerCase());
    }
    firestoreInstance
        .collection("Users")
        .doc(_currentuser!.uid)
        .collection('posts')
        .add({
      "imageUrl": url,
      "totalLike": like,
      "comments": [],
      "content": content,
      "datetime": DateTime.now(),
      "location": location,
      "likedBy": [],
      'searchLoc': locationList,
      "userID": _currentuser!.uid,
      "topic": topic,
      "searchTopic": TopicList,
      'totalDislike': 0,
      "dislikedBy": [],
    }).then((value) {});
    DocumentSnapshot docSnap =
        await FirestoreService.userCollection.doc(uid).get();
    List AllLoc = docSnap.get('locations');
    AllLoc.add(location);
    firestoreInstance.collection("Users").doc(_currentuser!.uid).update({
      'locations': AllLoc,
    });
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "Share Post Page");
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        actions: [
          const Spacer(),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Text('Post'),
            onPressed: () async {
              if (_PostKey.currentState!.validate()) {
                if (_holdImage == null) {
                  await FirebasePostUpload(
                      _currentuser!.uid, 0, '', contentPost, Posttopic);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      elevation: 10,
                      content: Text(
                          "Your Post successfully uploaded,check feed page"),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  uploadPostwithImage(context, contentPost);
                }
              }
              locationcontrol.clear();
              topiccontrol.clear();
              contentcontrol.clear();
              setState(() {
                _holdImage = null;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              key: _PostKey,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      height: sizeapp.width * 0.8,
                      width: sizeapp.height * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 3.0, color: AppColors.buttonColor),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      margin: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 25.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(70)),
                        child: _holdImage != null
                            ? InkWell(
                                onTap: pickImage,
                                child: Image.file(_holdImage!),
                              )
                            : OutlinedButton(
                                child: Text("Click for Add Photo"),
                                onPressed: pickImage,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Container(
                      child: TextFormField(
                        controller: contentcontrol,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        decoration: new InputDecoration(
                          hintText: "Write your content",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          fillColor: Colors.grey[200],
                          filled: true,
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return 'Please enter some content';
                          } else {
                            contentPost = value;
                            print(contentPost);
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Container(
                      child: TextFormField(
                        controller: locationcontrol,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Location",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          fillColor: Colors.grey[200],
                          filled: true,
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return null;
                          } else {
                            location = value;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Container(
                      child: TextFormField(
                        controller: topiccontrol,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                            fillColor: Colors.grey[200],
                            filled: true,
                            hintText: "Enter Topic",
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return null;
                          } else {
                            Posttopic = value;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
