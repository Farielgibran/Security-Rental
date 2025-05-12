import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Auth/face-verification.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:security_rental/Screen/Utils/theme.dart';
import '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Security rental App',
          debugShowCheckedModeBanner: false,
          theme: Lightmode,
          darkTheme: Darkmode,
          home: LoginScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/faceVerification': (context) => FaceVerification()
          },
        );
      },
      child: const SizedBox.shrink(), // atau bisa MaterialApp langsung di sini
    );
  }
}
