import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Objects/UserClass.dart';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _currentuser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String university = '';
  String username = '';
  String age = '';
  String bio = '';
  String profile_image = '';
  File? newImage = null;
  SettingUser curruser_profile = SettingUser('', '', '', '', '');
  //TO DO:image picker backend
  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      pickedFile != null ? newImage = File(pickedFile.path) : newImage = null;
    });
  }

  Future<bool> UsernameTaken(String username) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();

    if (snap.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future uploadPostwithImage(BuildContext context) async {
    String fileName = basename(newImage!.path);
    final storageRef = FirebaseStorage.instance.ref();
    final FireRef = storageRef
        .child('All_App_Posts')
        .child(_currentuser!.uid)
        .child('/$fileName');

    var Imageurl;

    final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    UploadTask FirebaseuploadTask;

    FirebaseuploadTask = FireRef.putFile(File(newImage!.path), metadata);
    await Future.value(FirebaseuploadTask)
        .then((value) async => {
              Imageurl = await value.ref.getDownloadURL(),
              print(url),
              UpdateProfile(username, university, age, bio, Imageurl),
              print("Upload file path ${value.ref.fullPath}"),
            })
        .onError((error, stackTrace) =>
            {print("Upload file path error ${error.toString()} ")});
  }

  Future UpdateProfile(String username, String university, String age,
      String bio, String profile_pic) async {
    final firestoreInst = FirebaseFirestore.instance;
    DocumentSnapshot docsnap =
        await firestoreInst.collection('Users').doc(_currentuser!.uid).get();
    String oldname = docsnap.get('username');
    List oldSearch = docsnap.get('userSearch');
    String olduni = docsnap.get('university');
    String oldage = docsnap.get('age');
    String oldbio = docsnap.get('bio');
    String oldprofileIm = docsnap.get('profileIm');
    List<String> newusernameList = [];
    for (int i = 1; i <= username.length; i++) {
      newusernameList.add(username.substring(0, i).toLowerCase());
    }
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_currentuser!.uid)
        .update({
      'username': username == "" ? oldname : username,
      'userSearch': newusernameList.isEmpty ? oldSearch : newusernameList,
      'userId': _currentuser!.uid,
      'university': (university == '') ? olduni : university,
      'age': (age == '') ? oldage : age,
      'bio': (bio == '') ? oldbio : bio,
      'profileIm': (profile_pic == '') ? oldprofileIm : profile_pic,
    });
  }

  @override
  Widget build(BuildContext context) {
    Size sizeapp = MediaQuery.of(context).size;
    print("Cuurentuser id: ${_currentuser!.uid}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile Settings"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () {
                        //TO DO:İmage picker function
                        pickImage();
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColors.appBackColor,
                        child: ClipOval(
                          // !!change later
                          child: newImage == null
                              ? Image.asset(
                                  'images/addphoto.png',
                                  fit: BoxFit.fitHeight,
                                )
                              : Image.file(newImage!),
                        ),
                        radius: 50,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      width: sizeapp.width * 0.8,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        enableSuggestions: true,
                        autocorrect: false,
                        decoration: InputDecoration(
                          label: Text("Username"),
                          fillColor: Colors.grey[200],
                          filled: true,
                          hintText: "New username",
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
                          if (value!.isEmpty || value == '') {
                            username = ''; //değişmediğini belirtmek için
                          } else {
                            if (value.length < 4) {
                              return 'new username too short';
                            }
                            username = value;
                          }
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      width: sizeapp.width * 0.8,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        enableSuggestions: true,
                        autocorrect: false,
                        decoration: InputDecoration(
                          label: Text("University"),
                          fillColor: Colors.grey[200],
                          filled: true,
                          hintText: "New university",
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
                          if (value!.isEmpty || value == '') {
                            university = ''; //değişmediğini belirtmek için
                          } else {
                            university = value;
                          }
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: sizeapp.width * 0.8,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text("Age"),
                          fillColor: Colors.grey[200],
                          filled: true,
                          hintText: " New Age",
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
                          if (value == null || value == "") {
                            age = "";
                          } else {
                            age = value;
                          }
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: sizeapp.width * 0.8,
                      child: TextFormField(
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          label: Text("Bio"),
                          fillColor: Colors.grey[200],
                          filled: true,
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
                          if (value == null || value == "") {
                            bio = "";
                          } else {
                            print(bio);
                            bio = value;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: OutlinedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              UsernameTaken(username).then((ourvalue) async {
                                if (ourvalue) {
                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              Text('Username already taken!'),
                                          content: Text(
                                              'Please select another one!'),
                                        );
                                      });
                                } else {
                                  if (newImage == null) {
                                    UpdateProfile(
                                        username, university, age, bio, "");
                                    Navigator.pop(context);
                                  } else {
                                    uploadPostwithImage(context);
                                    //TO DO:update profile  image function
                                    Navigator.pop(context);
                                  }
                                  setState(() {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        elevation: 10,
                                        content: Text('Profile Updated'),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  });
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
