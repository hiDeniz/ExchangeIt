import 'package:exchangeit/models/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static final appBarStyle = GoogleFonts.signika(
      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w100);

  static final hintTextStyle = GoogleFonts.signika(
      color: AppColors.hintTextColor, fontSize: 15, letterSpacing: 3);

  static final appNamePage = GoogleFonts.signika(
    color: Colors.white,
    fontSize: 60,
  );
  static final enableInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static final focusedInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static final borderInput = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static final WalkTextStyle = GoogleFonts.signika(
    color: Colors.black,
    fontSize: 18,
  );

  static final profileName = GoogleFonts.nunito(
      color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700);

  static final profileText = GoogleFonts.signika(
    color: AppColors.appTextColor,
    fontSize: 18,
  );

  static final profileTextName = GoogleFonts.signika(
    color: AppColors.appTextColor,
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );

  static final postText = GoogleFonts.signika(
    color: AppColors.postTextColor,
    fontSize: 18,
  );

  static final postLocation = GoogleFonts.signika(
    color: AppColors.locationTextColor,
    fontSize: 15,
  );

  static final postOwnerText = GoogleFonts.signika(
    color: AppColors.postTextColor,
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  static final signUp = GoogleFonts.signika(
      color: Colors.black, fontSize: 17, fontWeight: FontWeight.w700);

  static final buttonText = GoogleFonts.signika(
    color: Colors.black,
    fontSize: 17,
  );
  static final WelcomeText = GoogleFonts.signika(
      fontWeight: FontWeight.w900,
      fontSize: 35,
      color: Colors.green,
      fontStyle: FontStyle.italic);

  static final LikeText = GoogleFonts.signika(
      color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic);
}
