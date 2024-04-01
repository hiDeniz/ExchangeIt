import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:exchangeit/models/Styles.dart';
import 'package:exchangeit/services/FirestoreServices.dart';
import 'package:exchangeit/services/auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:path/path.dart';
import '../main.dart';
import '../services/Appanalytics.dart';
import 'LoginPage.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<SignUp> createState() => _SignUpState();
}

showDialogueForWaiting(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => WaitingScreen(
          message: "Your account is being created, please wait..."));
}

hideProgressDialogue(BuildContext context) {
  Navigator.of(context).pop(
      WaitingScreen(message: "Your account is being created, please wait..."));
}

class _SignUpState extends State<SignUp> {
  final formKeySign = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String username = "";
  String age = "";
  String uni = "";
  File? PicPath;
  var ppUrl;
  Future pickImage() async {
    final Image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (Image == null) {
        PicPath = null;
      } else {
        PicPath = File(Image.path);
      }
    });
  }

  Future uploadPostwithImage() async {
    String fileName = basename(PicPath!.path);
    final storageRef = FirebaseStorage.instance.ref();
    final Firebaseref = storageRef.child('All_PP').child('/$fileName');
    final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    UploadTask FirebaseuploadTask;

    FirebaseuploadTask = Firebaseref.putFile(File(PicPath!.path), metadata);
    await Future.value(FirebaseuploadTask)
        .then((value) async => {
              ppUrl = await value.ref.getDownloadURL(),
              print(url),
              print("Upload file path ${value.ref.fullPath}"),
            })
        .onError((error, stackTrace) =>
            {print("Upload file path error ${error.toString()} ")});
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "SignUp Page");
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xF3F3F3F3),
      body: SafeArea(
        child: Container(
          //margin: EdgeInsets.fromLTRB(0, 10, 0, 25),
          padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GradientText("SIGN UP",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      colors: [
                        Colors.blue,
                        Colors.deepPurpleAccent,
                        Colors.blueAccent,
                        Colors.deepPurpleAccent
                      ]),
                ]),
                SizedBox(height: 10),
                Form(
                  key: formKeySign,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //dokunmalı widget yapma
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            hoverColor: Colors.red,
                            onTap: () {
                              pickImage();
                              print("Pressed add profile page");
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              radius: 50,
                              child: ClipOval(
                                // !!change later
                                child: PicPath == null
                                    ? Image.asset(
                                        'images/addphoto.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(PicPath!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          width: sizeapp.width * 0.8,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            enableSuggestions: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: "Username",
                              enabledBorder: AppStyles.enableInputBorder,
                              focusedBorder: AppStyles.focusedInputBorder,
                              border: AppStyles.borderInput,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Cannot leave username empty';
                                } else if (value.length < 4) {
                                  return 'username too short';
                                } else {
                                  username = value;
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          width: sizeapp.width * 0.8,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            enableSuggestions: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: "Password",
                              enabledBorder: AppStyles.enableInputBorder,
                              focusedBorder: AppStyles.focusedInputBorder,
                              border: AppStyles.borderInput,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Cannot leave password empty';
                                } else if (value.length < 8) {
                                  return 'password too short';
                                } else {
                                  password = value;
                                }
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
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: "Email",
                              enabledBorder: AppStyles.enableInputBorder,
                              focusedBorder: AppStyles.focusedInputBorder,
                              border: AppStyles.borderInput,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Cannot leave e-mail empty';
                                } else if (!EmailValidator.validate(value)) {
                                  return 'Please enter a valid e-mail address';
                                } else {
                                  email = value;
                                }
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
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: "Age",
                              enabledBorder: AppStyles.enableInputBorder,
                              focusedBorder: AppStyles.focusedInputBorder,
                              border: AppStyles.borderInput,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Cannot leave age empty';
                                } else if (int.parse(value) < 0 ||
                                    int.parse(value) > 100) {
                                  return 'Please enter a valid age';
                                } else {
                                  age = value;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          width: sizeapp.width * 0.8,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            enableSuggestions: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: "Exchange University",
                              enabledBorder: AppStyles.enableInputBorder,
                              focusedBorder: AppStyles.focusedInputBorder,
                              border: AppStyles.borderInput,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Cannot leave University empty';
                                } else if (value.length < 3) {
                                  return 'University name too short';
                                } else {
                                  uni = value;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: OutlinedButton(
                          onPressed: () async {
                            if (formKeySign.currentState!.validate()) {
                              print('Sign up pressed');
                              await FirestoreService.IsUsernameTaken(username)
                                  .then((value) async {
                                if (value) {
                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              Text('Username already taken!'),
                                          content: Text(
                                              'Please select another username!'),
                                        );
                                      });
                                } else {
                                  username = username.toLowerCase().trim();
                                  showDialogueForWaiting(context);
                                  if (PicPath == null) {
                                    await AuthService.registerUser(
                                        email,
                                        username,
                                        uni,
                                        age,
                                        password,
                                        'https://png.pngitem.com/pimgs/s/64-646593_thamali-k-i-s-user-default-image-jpg.png');
                                  } else {
                                    await uploadPostwithImage();
                                    await AuthService.registerUser(email,
                                        username, uni, age, password, ppUrl);
                                  }
                                  hideProgressDialogue(context);
                                  setState(() {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        elevation: 10,
                                        content: Text(
                                            'Registration Successful! You are redirecting to the home page'),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  });
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      "/LoggedIn",
                                      (Route<dynamic> route) => false);
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 22,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              primary: Colors.black,
                              fixedSize: Size(sizeapp.width * 0.75, 70)),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already a user?"),
                          TextButton(
                              onPressed: () {
                                Navigator.popAndPushNamed(context, "/Login");
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blueAccent,
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                )
              ],
            )), //scrollanabilir liste
          ),
        ),
      ),
    );
  }
}
