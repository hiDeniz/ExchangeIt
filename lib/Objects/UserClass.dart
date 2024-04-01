class SettingUser {
  String university = '';
  String username = '';
  String age = '';
  String bio = '';
  String profile_image = '';
  SettingUser(
      this.username, this.university, this.age, this.bio, this.profile_image);
}

class appUser {
  String uid;
  String? university;
  String? username;
  String? age;
  String? bio;
  String? profile_image_URL;
  /*List<appUser> followers = [];
  List<appUser> following = [];
  List<PostBase> Posts = [];
  */

  appUser(
      {required this.uid,
      this.username,
      this.university,
      this.age,
      this.bio,
      this.profile_image_URL}
      /*
    this.followers,
    this.following,
    this.Posts,
  */
      );
}
