import 'package:exchangeit/Objects/UserClass.dart';
import 'package:exchangeit/SettingsOptions/ChangePassword.dart';
import 'package:exchangeit/routes/DMPage.dart';
import 'package:exchangeit/routes/LoggedIn.dart';
import 'package:exchangeit/routes/LoginPage.dart';
import 'package:exchangeit/routes/OpeningPage.dart';
import 'package:exchangeit/routes/SettingsPage.dart';
import 'package:exchangeit/routes/SignupPage.dart';
import 'package:exchangeit/routes/WalkthroughPage.dart';
import 'package:exchangeit/routes/private_profile_page.dart';
import 'package:exchangeit/routes/profile_page.dart';
import 'package:exchangeit/routes/share_post.dart';
import 'package:exchangeit/services/Appanalytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/routes/WelcomePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<FirebaseApp> _fbappinit = Firebase.initializeApp();
  runApp(Myfirebaseapp(init: _fbappinit));
}

class Myfirebaseapp extends StatefulWidget {
  const Myfirebaseapp({Key? key, this.init}) : super(key: key);
  final Future<FirebaseApp>? init;
  @override
  State<Myfirebaseapp> createState() => _MyfirebaseappState();
}

class _MyfirebaseappState extends State<Myfirebaseapp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.init,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
                home: ErrorScreen(message: snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            FlutterError.onError =
                FirebaseCrashlytics.instance.recordFlutterError;
            return MainBase();
          }
          return MaterialApp(home: WaitingScreen(message: "Loading..."));
        });
  }
}

class MainBase extends StatelessWidget {
  MainBase({Key? key}) : super(key: key);
  FirebaseAnalytics appanalytics = Appanalytics.analytics;
  @override
  Widget build(BuildContext context) {
    return StreamProvider<appUser?>.value(
      value: AuthService().getCurrentUser,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => Opening(analytics: appanalytics),
          '/Welcome': (context) => WelcomePage(analytics: appanalytics),
          '/Walkthrough': (context) => Walkthrough(analytics: appanalytics),
          '/SignUp': (context) => SignUp(analytics: appanalytics),
          '/Login': (context) => LoginScreen(analytics: appanalytics),
          '/LoggedIn': (context) => LoggedIn(analytics: appanalytics),
          'Settings': (context) => SettingsPage(analytics: appanalytics),
          'PassChange': (context) => PassChange(analytics: appanalytics),
          'SharePost': (context) => SharePostScreen(analytics: appanalytics),
          'DM': (context) => DMPage(analytics: appanalytics),
          //'PrivProfile': (context) => privateProfileView(),
          'Profile': (context) => ProfileView(analytics: appanalytics),
          'ProviderMain': (context) => ProvideMain(analytics: appanalytics),
        },
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  ErrorScreen({Key? key, required this.message}) : super(key: key);

  String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error Occurred'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

class WaitingScreen extends StatelessWidget {
  WaitingScreen({Key? key, required this.message}) : super(key: key);
  String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          SizedBox(
            height: 20,
          ),
          Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}

class ProvideMain extends StatelessWidget {
  ProvideMain({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ErrorScreen(message: 'Error Occured,try again');
            } else if (snapshot.hasData) {
              print(snapshot);
              return LoggedIn(analytics: analytics);
            } else {
              return Text('Some strange things');
            }
          }),
    );
  }
}
