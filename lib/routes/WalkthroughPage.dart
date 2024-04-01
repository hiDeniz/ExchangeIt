import 'package:exchangeit/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:exchangeit/models/WalkModel.dart';
import 'dart:async';

import '../services/Appanalytics.dart';

class WalkthroughScreen {
  String header;
  String bottom;
  String imagename;
  int currPage;
  WalkthroughScreen(
      {required this.header,
      required this.bottom,
      required this.imagename,
      required this.currPage});
}

class Walkthrough extends StatefulWidget {
  const Walkthrough({Key? key, required this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  int _currentPage = 0;

  final PageController _pageController = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    if (_currentPage != 0 &&
        _currentPage < 2) //sayfa saysına göre güncelleme olacak
    {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _PageChanged(int idx) {
    setState(() {
      _currentPage = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    Appanalytics.setCurrentScreenUtil(screenName: "Walkthrough Page");
    return Container(
      color: Colors.grey,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
              child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              PageView.builder(
                itemBuilder: (context, index) => WalkItem(index),
                itemCount: WalkPagesList.length,
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: _PageChanged,
              ),
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (int i = 0; i < WalkPagesList.length; i++)
                          if (i == _currentPage)
                            WalkDots(true)
                          else
                            WalkDots(false)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }
}
