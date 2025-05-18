import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Auth/face-verification.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:security_rental/Screen/Utils/Theme/theme.dart';
import 'package:security_rental/Service/auth_service.dart';
import 'package:security_rental/Service/car_service.dart';
import 'package:security_rental/Service/face_verification_.dart';
import 'package:security_rental/Service/rental_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FaceVerificationService()),
        ChangeNotifierProvider(
          create: (_) => CarService(),
        ),
        ChangeNotifierProvider(create: (_) => RentalService()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            title: 'Security rental App',
            debugShowCheckedModeBanner: false,
            theme: Lightmode,
            home: LoginScreen(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/faceVerification': (context) => FaceVerificationScreen()
            },
          );
        },
        child:
            const SizedBox.shrink(), // atau bisa MaterialApp langsung di sini
      ),
    );
  }
}
