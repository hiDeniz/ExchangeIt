import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  static Future<bool> IsUsernameTaken(String username) async {
    QuerySnapshot snap =
        await userCollection.where('username', isEqualTo: username).get();
    if (snap.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future addUser(String uid, String name) async {
    List<String> allpop = [];
    for (int i = 1; i <= name.length; i++) {
      allpop.add(name.substring(0, i).toLowerCase());
    }
    await userCollection.doc(uid).set({
      'username': name,
      "age": "",
      "bio": '',
      "profileIm": 'https://png.pngitem.com/pimgs/s/64-646593_thamali-k-i-s-user-default-image-jpg.png',
      'userSearch': allpop,
      'userId': uid,
      'checkPrivate': false,
      'followers': [],
      'followerCount': 0,
      'following': [uid],
      'followingCount': 0,
      'university': "",
      'followRequests': [],
      'locations': [],
    });
  }

  static Future SignUpUseradd(
      String uid, String username, String uni, String age, String image) async {
    List<String> allpos = [];
    for (int i = 1; i <= username.length; i++) {
      allpos.add(username.substring(0, i).toLowerCase());
    }
    await userCollection.doc(uid).set({
      'username': username,
      "age": age,
      "bio": '',
      "profileIm": image,
      'userSearch': allpos,
      'userId': uid,
      'checkPrivate': false,
      'followers': [],
      'followerCount': 0,
      'following': [uid],
      'followingCount': 0,
      'university': uni,
      'followRequests': [],
      'locations': [],
    });
  }
}
