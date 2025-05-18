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
  static const String _apiUrl = 'https://granvsa.my.id/facepy/register-face';
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  // Convert Uint8List to File
  Future<File> _uint8ListToFile(Uint8List uint8list) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/face_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(uint8list);
    return file;
  }

  // Register face with API
  Future<FaceVerificationResult> registerFace(Uint8List imageBytes) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Get user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson == null) {
        return FaceVerificationResult(
          success: false,
          message: 'User data not found. Please login again.',
        );
      }

      final userData = json.decode(userJson);
      final userId = userData['user_id'];
      final username = userData['username'];

      // Convert image bytes to File
      final File imageFile = await _uint8ListToFile(imageBytes);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Add text fields
      request.fields['user_id'] = userId.toString();
      request.fields['name'] = username;

      // Add file
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        // Update user data with face ID
        final Map<String, dynamic> updatedUser = {...userData};
        updatedUser['face_id'] = jsonResponse['user_id'];
        updatedUser['face_registered_at'] = DateTime.now().toIso8601String();
        updatedUser['verification_status'] = 'verified';

        // Save updated user data
        await prefs.setString('user', json.encode(updatedUser));

        return FaceVerificationResult(
          success: true,
          message: 'Face verification successful',
          faceId: jsonResponse['user_id'],
        );
      } else {
        return FaceVerificationResult(
          success: false,
          message: jsonResponse['message'] ?? 'Face verification failed',
        );
      }
    } catch (e) {
      print('Face verification error: $e');
      return FaceVerificationResult(
        success: false,
        message: 'Error during face verification: $e',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}

// Result model class
class FaceVerificationResult {
  final bool success;
  final String message;
  final String? faceId;

  FaceVerificationResult({
    required this.success,
    required this.message,
    this.faceId,
  });
}
