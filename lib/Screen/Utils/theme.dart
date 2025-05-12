import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData Darkmode = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xff03A9F5),
    scaffoldBackgroundColor: Color(0xff121212),
    colorScheme: ColorScheme.dark(
        primary: Color(0xff03A9F5),
        // warna teks
        onPrimary: Colors.black,
        onSecondary: Colors.white),
    textTheme: GoogleFonts.nunitoTextTheme(TextTheme(
        bodyLarge: TextStyle(
            fontSize: 48.sp, fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(
            fontSize: 36.sp, fontWeight: FontWeight.bold, color: Colors.white),
        bodySmall: TextStyle(
            fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayLarge: TextStyle(
            fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(
            fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineLarge: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
        labelLarge: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelSmall: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white))));

ThemeData Lightmode = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xff03A9F5),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
        primary: Color(0xff03A9F5),
        //warna teks
        onPrimary: Colors.black,
        onSecondary: Colors.white),
    textTheme: GoogleFonts.nunitoTextTheme(TextTheme(
        bodyLarge: TextStyle(
            fontSize: 48.sp, fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(
            fontSize: 36.sp, fontWeight: FontWeight.bold, color: Colors.white),
        bodySmall: TextStyle(
            fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayLarge: TextStyle(
            fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(
            fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineLarge: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
        labelLarge: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelSmall: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white))));
