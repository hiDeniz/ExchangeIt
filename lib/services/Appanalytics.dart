import 'package:firebase_analytics/firebase_analytics.dart';

class Appanalytics {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static Future<void> setLogEventUtil(
      {required String eventName, Map<String, dynamic?>? params}) async {
    await analytics.logEvent(
      name: eventName,
      parameters: params,
    );
  }

  static Future<void> setCurrentScreenUtil({required String screenName}) async {
    await analytics.setCurrentScreen(screenName: screenName);
  }

  static Future<void> setUserIdUtil({required String userId}) async {
    await analytics.setUserId(id: userId);
  }
}
