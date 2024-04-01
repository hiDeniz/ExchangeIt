import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class PostInfo extends StatelessWidget {
  final String avatar;
  final String name;
  final String timeAgo;
  final String text;
  final String likes;
  final String comments;

  PostInfo({
    Key? key,
    required this.avatar,
    required this.name,
    required this.timeAgo,
    required this.text,
    required this.likes,
    required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(this.avatar),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        this.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      ' · $timeAgo',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  this.text,
                  overflow: TextOverflow.clip,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0, right: 20.0),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LikeButton(
                            size: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            child: Text(
                              this.likes,
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Icon(
                            IconData(0xe17e, fontFamily: 'MaterialIcons'),
                            size: 16.0,
                            color: Colors.black45,
                          ),
                          Container(
                            margin: const EdgeInsets.all(6.0),
                            child: Text(
                              this.comments,
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Icon(
                            IconData(0xf378, fontFamily: 'MaterialIcons'),
                            size: 16.0,
                            color: Colors.black45,
                          ),
                          Container(
                            margin: const EdgeInsets.all(6.0),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostState extends State<Post> {
  final List posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return posts[index];
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
          ),
          itemCount: posts.length,
        ),
      ),
    );
  }
}
