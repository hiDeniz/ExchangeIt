import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/Objects/NewPostClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart';
import '../models/Colors.dart';
import 'package:path/path.dart';

class PostEditScreen extends StatefulWidget {
  PostEditScreen({Key? key, required this.ourPost}) : super(key: key);
  UserPost ourPost;

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

showDialogueForWaiting(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) =>
          WaitingScreen(message: "Your post is being edited, please wait..."));
}

hideProgressDialogue(BuildContext context) {
  Navigator.of(context)
      .pop(WaitingScreen(message: "Your post is being edited, please wait..."));
}

class _PostEditScreenState extends State<PostEditScreen> {
  Future pickNewImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      newImageFile = File(pickedFile!.path);
    });
  }

  Future uploadPostwithImage(BuildContext context, content) async {
    String fileName = basename(newImageFile!.path);
    final storageRef = FirebaseStorage.instance.ref();
    final Firebaseref = storageRef
        .child('All_App_Posts')
        .child(currentuser!.uid)
        .child('/$fileName');

    final FirebaseData = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    UploadTask storageuploader;

    storageuploader =
        Firebaseref.putFile(File(newImageFile!.path), FirebaseData);
    await Future.value(storageuploader)
        .then((value) async => {
              EditedUrl = await value.ref.getDownloadURL(),
              print(EditedUrl),
              print("Upload file path ${value.ref.fullPath}"),
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  elevation: 10,
                  content:
                      Text("Your Post successfully edited,check feed page"),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            })
        .onError((error, stackTrace) =>
            {print("Upload file path error ${error.toString()} ")});
  }

  Future FirebasePostUpdate(
      UserPost ourpost, uid, url, content, topic, location) async {
    final firestoreInstance = FirebaseFirestore.instance;

    List<String> locationList = [];

    for (int i = 1; i <= location.length; i++) {
      locationList.add(location.substring(0, i).toLowerCase());
    }
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(ourpost.postownerID)
        .collection('posts')
        .doc(ourpost.postId)
        .update({
      "imageUrl": url,
      "content": content,
      "datetime": DateTime.now(),
      "location": location,
      'searchLoc': locationList,
      "topic": topic,
    });
  }

  final currentuser = FirebaseAuth.instance.currentUser;
  File? newImageFile = null;
  String newContent = '';
  String newLocation = '';
  String EditedUrl = '';
  String newTopic = '';
  final _EditPostKey = GlobalKey<FormState>();
  final editlocationcontrol = TextEditingController();
  final editcontentcontrol = TextEditingController();
  final edittopiccontrol = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post Screen'),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Text('Post'),
            onPressed: () async {
              if (_EditPostKey.currentState!.validate()) {
                if (newImageFile == null) {
                  await FirebasePostUpdate(widget.ourPost, currentuser!.uid,
                      EditedUrl, newContent, newTopic, newLocation);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      elevation: 10,
                      content:
                          Text("Your Post successfully edited,check feed page"),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  uploadPostwithImage(context, newContent);
                }
              }
              setState(() {
                newImageFile = null;
              });
              editcontentcontrol.clear();
              editlocationcontrol.clear();
              edittopiccontrol.clear();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              key: _EditPostKey,
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
                        child: newImageFile != null
                            ? InkWell(
                                onTap: pickNewImage,
                                child: Image.file(newImageFile!),
                              )
                            : OutlinedButton(
                                child: Text("Click for Add new photo"),
                                onPressed: pickNewImage,
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
                        controller: editcontentcontrol,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        decoration: new InputDecoration(
                          hintText: "Write your new content",
                          fillColor: Colors.black,
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
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            newContent = widget.ourPost.content;
                          } else {
                            newContent = value;
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
                        controller: editlocationcontrol,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter New Location",
                          fillColor: Colors.black,
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
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            newLocation = widget.ourPost.location;
                          } else {
                            newLocation = value;
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
                        controller: edittopiccontrol,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter New Topic",
                          fillColor: Colors.black,
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
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return null;
                          } else {
                            newTopic = value;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
