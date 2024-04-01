import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/FirestoreServices.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class locationInfo extends StatelessWidget {
  final String locationText;

  locationInfo({
    Key? key,
    required this.locationText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size sizeapp = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      //margin: const EdgeInsets.all(3.0),
                      //padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      primary: Colors.black,
                      textStyle: const TextStyle(fontSize: 18),
                      fixedSize: Size(sizeapp.width * 0.75, 50),
                    ),
                    onPressed: () {},
                    child: Text(this.locationText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationState extends State<Location> {
  final _currentuser = FirebaseAuth.instance.currentUser;
  final List<locationInfo> locationInfos = [];
  Future getLocations() async {
    DocumentSnapshot LocdocSnap =
        await FirestoreService.userCollection.doc(_currentuser!.uid).get();
    List AllLoc = LocdocSnap.get('locations');
    for (var loc in AllLoc) {
      locationInfos.add(locationInfo(locationText: loc));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 20,
              height: 20,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return Container(
            color: Colors.white,
            child: ListView.separated(
              controller: ScrollController(),
              itemBuilder: (BuildContext context, int index) {
                return locationInfos[index];
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 3,
              ),
              itemCount: locationInfos.length,
            ),
          );
        });
  }
}
