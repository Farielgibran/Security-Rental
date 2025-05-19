import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:huawei_ml_body/huawei_ml_body.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Screen/Home/homepage.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import 'package:security_rental/Screen/Widget/Component/custom_button.dart';
import 'package:security_rental/Service/face_verification_.dart';

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
      _redirectToRetry();
      return;
    }

    try {
      MLLivenessCaptureResult result =
          await livenessCapture.startDetect(detectMask: false);

      if (result.isLive == null || result.isLive == false) {
        showToast("Liveness Not Detected");
        _redirectToRetry();
        return;
      }

      if (result.bitmap == null) {
        showToast("Please clean your camera and try again");
        _redirectToRetry();
        return;
      }

      // Jika lolos semua validasi
      capturedImage = result.bitmap;
      livenessResult = "Liveness Detected";

      await _processVerification(result.bitmap!);
    } catch (e) {
      print('Liveness Error: $e');
      showToast("Error during liveness detection");
      _redirectToRetry();
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
          MaterialPageRoute(builder: (context) => Homepage()),
          (route) => false,
        );
      } else {
        showToast(result.message);
        _redirectToRetry();
      }
    } catch (e) {
      print('Error during verification process: $e');
      showToast("Verification process failed");
      _redirectToRetry();
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _redirectToRetry() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const VerificationFlowScreen(),
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

// Usage example in a verification flow screen
class VerificationFlowScreen extends StatelessWidget {
  const VerificationFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Try Again Face Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Complete Face Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
          ],
        ),
      ),
    );
  }
}
