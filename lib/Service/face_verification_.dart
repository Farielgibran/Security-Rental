import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VerificationResult {
  final bool success;
  final String message;

  VerificationResult({
    required this.success,
    required this.message,
  });
}

class FaceVerificationService extends ChangeNotifier {
  // Ubah baseUrl sesuai dengan endpoint API verifikasi wajah Anda
  final String baseUrl = 'http://10.0.2.2:5000'; // Untuk emulator Android
  // final String baseUrl = 'http://localhost:5000'; // Untuk iOS simulator
  // final String baseUrl = 'https://your-api-domain.com'; // Untuk produksi

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  // Metode untuk melakukan verifikasi wajah
  Future<VerificationResult> verifyFace(File imageFile) async {
    _isVerifying = true;
    notifyListeners();

    try {
      // Membuat request multipart untuk mengirim file gambar
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verify-face'),
      );

      // Menambahkan file gambar ke request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Mengirim request dan menunggu respons
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Memeriksa status code dari respons
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        bool success = data['success'] ?? false;
        String message = data['message'] ?? 'Verifikasi selesai';

        return VerificationResult(
          success: success,
          message: message,
        );
      } else {
        return VerificationResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return VerificationResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }
}
