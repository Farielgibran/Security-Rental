import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Home/Navbar/navbar.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import 'package:security_rental/Screen/Widget/Component/custom_button.dart';
import 'package:security_rental/Service/face_verification_.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isLoading = true;
  bool _isProcessing = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras!.first,
          ),
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
      });

      // Kirim gambar ke layanan verifikasi wajah
      final result =
          await Provider.of<FaceVerificationService>(context, listen: false)
              .verifyFace(_capturedImage!);

      if (result.success) {
        // Jika verifikasi berhasil, perbarui status pengguna dan navigasi ke beranda
        // await Provider.of<AuthService>(context, listen: false)
        //     .updateVerificationStatus(true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verifikasi wajah berhasil!')));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainNavbar()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Verifikasi wajah gagal: ${result.message}')));
        setState(() {
          _capturedImage = null;
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi kesalahan saat mengambil gambar')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verifikasi Wajah')),
        body: Center(child: LoadingWidget()),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verifikasi Wajah')),
        body: const Center(
          child: Text('Tidak dapat mengakses kamera'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Wajah')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _capturedImage != null
                  ? Image.file(_capturedImage!)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_cameraController!),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Pastikan wajah Anda terlihat jelas dalam frame kamera untuk verifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                _isProcessing
                    ? LoadingWidget()
                    : CustomButton(
                        text: _capturedImage != null
                            ? 'Ambil Ulang'
                            : 'Verifikasi Wajah',
                        onPressed: _capturedImage != null
                            ? () {
                                setState(() {
                                  _capturedImage = null;
                                });
                              }
                            : _captureImage,
                      ),
                if (_capturedImage != null) ...[
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Proses Verifikasi',
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            setState(() {
                              _isProcessing = true;
                            });

                            try {
                              final result =
                                  await Provider.of<FaceVerificationService>(
                                          context,
                                          listen: false)
                                      .verifyFace(_capturedImage!);

                              if (result.success) {
                                // await Provider.of<AuthService>(context,
                                //         listen: false)
                                //     .updateVerificationStatus(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Verifikasi wajah berhasil!')));
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => MainNavbar()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Verifikasi wajah gagal: ${result.message}')));
                                setState(() {
                                  _capturedImage = null;
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Terjadi kesalahan saat memproses verifikasi')));
                            } finally {
                              setState(() {
                                _isProcessing = false;
                              });
                            }
                          },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
