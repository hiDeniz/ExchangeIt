class UserPost {
  String content;
  String imageurl;
  String date;
  int totalLike;
  int totalDislike;
  int commentCount;
  List<dynamic> comments;
  String postId;
  String postownerID = '';
  String ownername = '';
  String location = "";
  String topic = "";

  UserPost(
      {required this.postId,
      required this.content,
      required this.imageurl,
      required this.date,
      required this.totalLike,
      required this.totalDislike,
      required this.commentCount,
      required this.comments,
      this.postownerID = '',
      this.ownername = '',
      this.location = "",
      this.topic = ""});
}
