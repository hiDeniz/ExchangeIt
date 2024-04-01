import 'package:exchangeit/routes/NotificationPage.dart';
import 'package:exchangeit/routes/profile_page.dart';
import 'package:exchangeit/routes/SearchPage.dart';
import 'package:exchangeit/routes/share_post.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../services/Appanalytics.dart';
import '../services/auth.dart';
import 'FeedPage.dart';

class LoggedIn extends StatefulWidget {
  const LoggedIn({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  int _selectedIndex = 0;
  PageController _PageController = PageController();
  static List<String> page_names = [
    "Home",
    "Search",
    "Add Post",
    "Notifications",
    "Profile"
  ];
  void _BarTapped(int index) {
    _PageController.jumpToPage(index);
  }

  void _PageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initState() {
    super.initState();

    AuthService().getCurrentUser.listen((user) {
      if (user == null) {
        print('No user is currently signed in.');
      } else {
        print('${user.username} is the current user');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //setCurrentScreenUtil(screenName: "Logged In Screen");
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageView(
          controller: _PageController,
          children: [
            FeedPage(analytics: widget.analytics),
            SearchMain(),
            SharePostScreen(analytics: widget.analytics),
            NotificationView(),
            ProfileView(analytics: widget.analytics),
          ],
          onPageChanged: _PageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: 'Add'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Account'),
          ],
          selectedItemColor: Colors.blue.shade600,
          unselectedItemColor: Colors.black,
          onTap: _BarTapped,
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }
}
