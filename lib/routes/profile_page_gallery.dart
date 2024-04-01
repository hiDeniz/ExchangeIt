import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exchangeit/Objects/NewPostClass.dart';
import 'package:exchangeit/routes/post_page.dart';
import 'package:exchangeit/routes/profile_page.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  Gallery({required this.GmyPosts});
  final List<UserPost> GmyPosts;
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<UserPost> NewList = [];
  Future postcounter() async {
    for (var post in widget.GmyPosts) {
      if (post.imageurl != "") {
        NewList.add(post);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postcounter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 20,
              height: 20,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return Scaffold(
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                crossAxisCount: 3,
              ),
              itemCount: NewList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => postPageView(
                                pf: NewList[index],
                                pID: NewList[index].postId,
                                ownerID: NewList[index].postownerID,
                              )),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(NewList[index].imageurl),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
