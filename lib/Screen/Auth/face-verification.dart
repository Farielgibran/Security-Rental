import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:huawei_ml_body/huawei_ml_body.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Screen/Widget/Common/custom_buttom.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import 'package:security_rental/Service/face_verification_.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Main screen widget for face verification
class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  final MLLivenessCapture livenessCapture = MLLivenessCapture();
  Uint8List? capturedImage;
  String livenessResult = '';
  File? _timestampedPhoto;
  DeviceControlHelper dc = DeviceControlHelper();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    dc.setBrightness(1.0); // Set maximum brightness for better detection
    startLivenessDetection();
  }

  Future<void> startLivenessDetection() async {
    setState(() {
      isProcessing = true;
    });

    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      showToast("Camera permission is required for liveness detection");
      failderretry();
      return;
    }

    try {
      MLLivenessCaptureResult result =
          await livenessCapture.startDetect(detectMask: false);

      if (result.isLive == null || result.isLive == false) {
        showToast("Liveness Not Detected");
        failderretry();
        return;
      }

      if (result.bitmap == null) {
        showToast("Please clean your camera and try again");
        failderretry();
        return;
      }

      // Jika lolos semua validasi
      capturedImage = result.bitmap;
      livenessResult = "Liveness Detected";

      await _processVerification(result.bitmap!);
    } catch (e) {
      print('Liveness Error: $e');
      showToast("Error during liveness detection");
      failderretry();
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _processVerification(Uint8List imageBytes) async {
    try {
      final faceService =
          Provider.of<FaceVerificationService>(context, listen: false);
      final result = await faceService.verifyFace(imageBytes);

      if (result.success) {
        showToast("Face verification successful!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainNavbar()),
          (route) => false,
        );
      } else {
        showToast(result.message);
        // Pass the bestMatch to VerificationFlowScreen
        _redirectToRetry(result.bestMatch);
      }
    } catch (e) {
      print('Error during verification process: $e');
      showToast("Verification process failed");
      _redirectToRetry(null);
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _redirectToRetry([String? bestMatch]) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => VerificationFlowScreen(detectedFace: bestMatch),
      ),
      (route) => false,
    );
  }

  void failderretry() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const Verifcationfailed(),
      ),
      (route) => false,
    );
  }

  // Utility function to show toast messages
  void showToast(String message) {
    // Implementation depends on your app's toast helper
    // For example:
    // ToastHelper.show(message, context);
    print(message); // Fallback for this example
  }

  @override
  void dispose() {
    dc.resetBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget(),
                  const SizedBox(height: 20),
                  Text(
                    "Processing Face Verification",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please keep your face in the frame and wait...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )
            : LoadingWidget(),
      ),
    );
  }
}

// Modified VerificationFlowScreen to show username and detected face
class VerificationFlowScreen extends StatefulWidget {
  final String? detectedFace;

  const VerificationFlowScreen({super.key, this.detectedFace});

  @override
  _VerificationFlowScreenState createState() => _VerificationFlowScreenState();
}

class _VerificationFlowScreenState extends State<VerificationFlowScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = json.decode(userJson);
        setState(() {
          username = userData['username'];
        });
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Try again Face Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Face Verification Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (username != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Verification Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Logged in as: $username',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Face detected as: ${widget.detectedFace ?? "Not detected"}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'We need to verify your identity using face recognition. This helps maintain security for all users.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Try Face Verification Again',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => FaceVerificationService(),
                      child: const FaceVerificationScreen(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 12,
            ),
            CustomButton(
              text: 'Kembali',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            SizedBox(
              height: 24,
            ),
            CustomButton(
              text: 'Demo mode',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavbar()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Modified Verifcationfailed to show username
class Verifcationfailed extends StatefulWidget {
  const Verifcationfailed({super.key});

  @override
  _VerifcationfailedState createState() => _VerifcationfailedState();
}

class _VerifcationfailedState extends State<Verifcationfailed> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = json.decode(userJson);
        setState(() {
          username = userData['username'];
        });
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Face Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (username != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Verification Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Logged in as: $username',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Face verification failed or not attempted',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'We need to verify your identity using face recognition. This helps maintain security for all users.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Start Face Verification',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => FaceVerificationService(),
                      child: const FaceVerificationScreen(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 12,
            ),
            CustomButton(
              text: 'Kembali',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            SizedBox(
              height: 24,
            ),
            CustomButton(
              text: 'Demo mode',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavbar()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
