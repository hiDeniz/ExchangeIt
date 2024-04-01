import 'package:flutter/material.dart';

class NotificationObj {
  String nID;
  String profilePic;
  String action;
  String timestamp;
  String user;
  String sender;
  String type;

  NotificationObj({
    required this.nID,
    required this.profilePic,
    required this.action,
    required this.timestamp,
    required this.user,
    required this.sender,
    required this.type,
  });
}