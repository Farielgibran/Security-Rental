import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Service/auth_service.dart';

import '../../config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu minimal 2.5 detik untuk menampilkan splash screen
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // Tunggu hingga AuthService selesai memuat data user
    while (authService.isLoading && !authService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Navigasi berdasarkan status login
    if (authService.isLoggedIn) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavbar(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.security,
                          size: 60.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          AppConfig.appName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Security Car Pinjam App',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 48.h),
                        SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3.0,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            String loadingText = 'Memuat aplikasi...';

                            if (authService.isLoading &&
                                !authService.isInitialized) {
                              loadingText = 'Memeriksa data login...';
                            }

                            return Text(
                              loadingText,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
