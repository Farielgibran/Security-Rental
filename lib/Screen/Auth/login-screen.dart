import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Screen/Home/homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavbar()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 64.h),

                  // Logo
                  Center(
                    child: Container(
                      height: 96.h,
                      width: 96.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 48.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Title
                  Center(
                    child: Text(
                      'Security Rental App',
                      style: theme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: Text(
                      'Log in to your account',
                      style: theme.headlineMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Username
                  Text(
                    'Username',
                    style: theme.labelLarge,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _usernameController,
                    style: theme.labelMedium?.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      hintStyle: theme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Password
                  Text(
                    'Password',
                    style: theme.labelLarge,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: theme.labelMedium?.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: theme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password tidak boleh kosong';
                      } else if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 36.h),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: _login,
                            child: Text(
                              'Login',
                              style: theme.headlineLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 24.h),

                  // Footer Text
                  Center(
                    child: Text(
                      'Security check for rental',
                      style: theme.headlineMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
