import 'package:email_validator/email_validator.dart';
import 'package:exchangeit/services/Appanalytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../models/Colors.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final ForgetformKey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  @override
  void dispose() {
    emailcontroller.dispose();
    super.dispose();
  }

  String email = "";
  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: 'ForgotPassword');
    Size sizeapp = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: ForgetformKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: sizeapp.width * 0.3,
                    height: sizeapp.height * 0.3,
                    padding: EdgeInsets.all(80),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: AssetImage("images/lock-icon.png"),
                            fit: BoxFit.contain)),
                  ),
                ],
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: sizeapp.width * 0.8,
                  child: TextFormField(
                    //controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      hintText: "Email",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                    validator: (value) {
                      if (value == null || value == "") {
                        return 'Cannot leave e-mail empty';
                      } else {
                        if (!EmailValidator.validate(value)) {
                          return 'Please enter a valid e-mail address';
                        } else {
                          email = value;
                          return null;
                        }
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: sizeapp.width * 0.8,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        primary: Colors.green,
                      ),
                      onPressed: () {
                        if (ForgetformKey.currentState!.validate()) {
                          ForgetformKey.currentState!.save();
                          print('Email: $email');
                          //_resetPass;
                        }
                      },
                      icon: Icon(Icons.email_outlined),
                      label: Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /*Future _resetPass() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) => Navigator.of(context).pop());
    } on FirebaseAuthException catch (mes) {
      print(mes);
    }
  } qwec*/
}
