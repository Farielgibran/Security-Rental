import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Config/app_config.dart';
import 'package:security_rental/Screen/Auth/face-verification.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Screen/Widget/Component/custom_button.dart';
import 'package:security_rental/Screen/Widget/Component/custom_textfield.dart';
import 'package:security_rental/Service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (_) => HomeScreen()),
    // );
    // return;
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    final success = await authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // // Cek apakah verifikasi wajah diperlukan
      // if (AppConfig.faceVerificationRequired &&
      //     authService.currentUser!.faceId == null) {
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (_) => FaceVerificationScreen()),
      //   );
      // } else {
      //   // Jika tidak perlu verifikasi wajah, langsung ke HomeScreen
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (_) => MainNavbar()),
      //   );
      // }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainNavbar()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal. Periksa email dan password Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 64.h),
                  Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 80.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: Text('Selamat Datang Kembali',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: Colors.grey)),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'Login untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Masukkan Username Anda',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Masukkan password Anda',
                    obscureText: !_obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(height: 32.h),
                  CustomButton(text: 'Login', onPressed: _login),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
