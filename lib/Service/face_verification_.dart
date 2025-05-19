import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Device brightness control utility class
class DeviceControlHelper {
  final double _originalBrightness = 0.5;
  bool _hasSetBrightness = false;

  Future<void> setBrightness(double brightness) async {
    try {
      // Implementation would use platform-specific code to change brightness
      // This is a placeholder - actual implementation would need platform channel
      _hasSetBrightness = true;
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  Future<void> resetBrightness() async {
    if (_hasSetBrightness) {
      try {
        // Reset to original brightness
        // Implementation would use platform-specific code
      } catch (e) {
        print('Error resetting brightness: $e');
      }
    }
  }
}

// Face verification service class
class FaceVerificationService extends ChangeNotifier {
  static const String _apiUrl =
      'https://e1cb-35-227-113-117.ngrok-free.app/verify-face';
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<File> _uint8ListToFile(Uint8List uint8list) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/verify_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(uint8list);
    return file;
  }

  Future<FaceVerificationResult> verifyFace(Uint8List imageBytes) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson == null) {
        return FaceVerificationResult(
          success: false,
          message: 'User data not found. Please login again.',
        );
      }

      final userData = json.decode(userJson);
      final username = userData['username'];

      final File imageFile = await _uint8ListToFile(imageBytes);

      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      /// Debugging logs
      print('Raw Response Data: $responseData');
      print('Decoded JSON Response: $jsonResponse');
      if (response.statusCode == 200) {
        final bestMatch = jsonResponse['best_match'];
        final similarity = jsonResponse['similarity'] ?? 0.0;
        final successFlag = jsonResponse['success'] ?? false;
        final message =
            jsonResponse['message'] ?? 'Verification result received.';

        print(
            "Logged in user: $username, Best match: $bestMatch, Similarity: $similarity");

        if (bestMatch != null &&
            bestMatch.toString().toLowerCase() == username.toLowerCase()) {
          return FaceVerificationResult(
            success: true,
            message: 'Verification success (username matched)!',
            bestMatch: bestMatch,
          );
        } else {
          return FaceVerificationResult(
            success: false,
            message: message,
          );
        }
      } else {
        return FaceVerificationResult(
          success: false,
          message: 'API Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Verification error: $e');
      return FaceVerificationResult(
        success: false,
        message: 'Error during verification: $e',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}

class FaceVerificationResult {
  final bool success;
  final String message;
  final String? bestMatch;

  FaceVerificationResult({
    required this.success,
    required this.message,
    this.bestMatch,
  });
}
