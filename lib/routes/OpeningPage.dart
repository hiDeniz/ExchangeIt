import 'dart:async';

import 'package:exchangeit/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/Appanalytics.dart';

class Opening extends StatefulWidget {
  Opening({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  @override
  initState() {
    super.initState();
    new Timer(const Duration(seconds: 2), FirstSeen);
  }

  Future FirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = await prefs.getBool('seen') ?? false;
    final curruser = FirebaseAuth.instance.currentUser;
    print("ılk ${_seen},");
    if (_seen == true) {
      if (curruser != null) {
        print("Username: ${curruser.displayName}");
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/LoggedIn', (Route<dynamic> route) => false);
        /*Navigator.pushNamed(context, '/LoggedIn');*/
      } else {
        print("Still in Login");
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/Login', (Route<dynamic> route) => false);
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/Walkthrough', (Route<dynamic> route) => false);
    }
    print("SONRA ${_seen},");
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "Waiting Screen");

    return WaitingScreen(message: "Exchangeit is initializing...");
  }
}
