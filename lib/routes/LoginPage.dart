import 'dart:io';
import 'dart:ui';
import 'package:exchangeit/main.dart';
import 'package:exchangeit/models/Colors.dart';
import 'package:exchangeit/routes/ForgotPassPage.dart';
import 'package:exchangeit/routes/LoggedIn.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/Appanalytics.dart';
import '../services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  int loginCounter = 0;
  String email = '';
  String pass = '';

  final AuthService _auth = AuthService();
  Future loginUser() async {
    showDialogueForWaiting(context);
    dynamic result = await AuthService.signInWithEmailPass(email, pass);
    if (result is String) {
      hideProgressDialogue(context);
      _showDialog('Login Error', result);
    } else if (result is User) {
      //User signed in
      hideProgressDialogue(context);
      FirebaseAnalytics.instance.logEvent(name: 'Logged_In_Succesfully');
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/LoggedIn", (Route<dynamic> route) => false);
    } else {
      hideProgressDialogue(context);
      FirebaseAnalytics.instance.logEvent(name: 'Login_Error');
      _showDialog('Login Error', result.toString());
    }
  }

  Future<void> _showDialog(String title, String message) async {
    bool isAndroid = Platform.isAndroid;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (isAndroid) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(message),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          } else {
            return CupertinoAlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(message),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        });
  }

  void initState() {
    super.initState();

    _auth.getCurrentUser.listen((user) {
      if (user == null) {
        print('No user is currently signed in.');
      } else {
        print('${user.uid} is the current user uid');
      }
    });
  }

  showDialogueForWaiting(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => WaitingScreen(
            message: "Your account is being verified, please wait..."));
  }

  hideProgressDialogue(BuildContext context) {
    Navigator.of(context).pop(WaitingScreen(
        message: "Your account is being verified, please wait..."));
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "App Login Page");
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.appBackColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: sizeapp.height,
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "images/upper.png",
                width: sizeapp.width * 0.8,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientText("LOGIN",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      colors: [
                        Colors.blue,
                        Colors.deepPurpleAccent,
                        Colors.blueAccent,
                        Colors.deepPurpleAccent
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: sizeapp.width * 0.8,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          fillColor: AppColors.textFormColor,
                          filled: true,
                          hintText: "Email",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                        ),
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'Cannot leave e-mail empty';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'Please enter a valid e-mail address';
                            }
                          }
                        },
                        onSaved: (value) {
                          email = value ?? '';
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
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          fillColor: AppColors.textFormColor,
                          filled: true,
                          hintText: "Password",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                        ),
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'Cannot leave password empty';
                            }
                            if (value.length < 6) {
                              return 'Password too short';
                            }
                          }
                        },
                        onSaved: (value) {
                          pass = value ?? '';
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: sizeapp.width * 0.8,
                    alignment: Alignment.topRight,
                    child: TextButton(
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ForgetPass(analytics: widget.analytics)));
                      },
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: OutlinedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await loginUser();
                        } else {
                          _showDialog('Form Error', 'Your form is invalid');
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          fixedSize: Size(sizeapp.width * 0.75, 50)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(children: <Widget>[
                    Expanded(
                        child: Divider(
                      thickness: 2,
                      indent: 20.0,
                      endIndent: 10.0,
                    )),
                    Text("OR", style: TextStyle(fontSize: 15)),
                    Expanded(
                        child: Divider(
                      thickness: 2,
                      indent: 10.0,
                      endIndent: 20.0,
                    )),
                  ]),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: SignInButton(
                      imagePosition: ImagePosition.left, // left or right
                      buttonType: ButtonType.google,
                      buttonSize: ButtonSize.large,
                      btnText: "Login with Google",
                      elevation: 10,
                      onPressed: () async {
                        showDialogueForWaiting(context);
                        await _auth.googleSignIn();
                        print('Google Pressed');
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        bool _googlelogged =
                            await prefs.getBool('googlelogin') ?? false;
                        if (_googlelogged == true) {
                          hideProgressDialogue(context);
                          Appanalytics.setLogEventUtil(
                              eventName: 'Google_Logged_In_Successfully');
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "/LoggedIn", (Route<dynamic> route) => false);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: SignInButton(
                          imagePosition: ImagePosition.left, // left or right
                          buttonType: ButtonType.facebook,
                          buttonSize: ButtonSize.large,
                          btnText: "Login with Facebook",
                          elevation: 10,
                          onPressed: () async {
                            print('Facebook Pressed');
                            await _auth.FacebookSignIn();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            bool _facebooklogin =
                                await prefs.getBool('facebooklogin') ?? false;
                            if (_facebooklogin == true) {
                              Appanalytics.setLogEventUtil(
                                  eventName: 'Facebook_Logged_In_Successfully');
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  "/LoggedIn", (Route<dynamic> route) => false);
                            } else {
                              print('giremedim');
                            }
                          })),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Need an Account? "),
                      TextButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, "/SignUp");
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
