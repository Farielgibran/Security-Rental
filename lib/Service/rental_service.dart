import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:security_rental/Model/rental_model.dart';
import '../config/app_config.dart';

class RentalService extends ChangeNotifier {
  List<Rental> _rentals = [];
  bool _isLoading = false;
  String? _error;

  List<Rental> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter untuk rentals yang aktif
  List<Rental> get activeRentals => _rentals
      .where((rental) => rental.status == RentalStatus.onGoing)
      .toList();
  List<Rental> get approvedRentals => _rentals
      .where((rental) => rental.status == RentalStatus.approved)
      .toList();
  // Getter untuk rentals yang sudah selesai
  List<Rental> get completedRentals => _rentals
      .where((rental) => rental.status == RentalStatus.completed)
      .toList();

  // Getter untuk rentals yang pending/sedang diproses
  List<Rental> get pendingRentals => _rentals
      .where((rental) => rental.status == RentalStatus.pending)
      .toList();

  // Getter untuk rentals yang dibatalkan
  List<Rental> get cancelledRentals => _rentals
      .where((rental) => rental.status == RentalStatus.cancelled)
      .toList();

  // Getter untuk rentals yang ditolak
  List<Rental> get rejectedRentals => _rentals
      .where((rental) => rental.status == RentalStatus.rejected)
      .toList();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Mengambil data rental dari API
  Future<void> fetchRentals(String userid) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/transaksi/'),
        headers: {},
      );

      print(response.body);
      if (response.statusCode == 200) {
        // Handling untuk response berupa array JSON seperti di contoh data
        final List<dynamic> data = json.decode(response.body);
        print(_rentals);
        _rentals = data.map((item) => Rental.fromJson(item)).toList();
        notifyListeners();
      } else {
        _setError('Failed to load rentals. Status: ${response.statusCode}');
        print('Fetch rentals failed: ${response.body}');
      }
    } catch (e) {
      _setError('Error connecting to server: $e');
      print('Fetch rentals error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Membuat rental baru
  Future<bool> createRental({
    required String carId,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    String? note,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse('${AppConfig.apiUrl}/transaksi/creates');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobil_id': carId,
          'nama_penyewa': userName,
          'tanggal_mulai_sewa': startDate.toIso8601String(),
          'tanggal_akhir_sewa': endDate.toIso8601String(),
          'note': note ?? '',
        }),
      );

      if (response.statusCode == 201) {
        print('Transaksi berhasil dibuat');
        print(response.body);
        return true;
      } else {
        print('Gagal membuat transaksi: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      print('Error saat koneksi ke server: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mendapatkan detail rental berdasarkan ID
  Future<Rental?> getRentalById(int id) async {
    try {
      // Cari di cache dulu
      final cachedRental = _rentals.firstWhere((rental) => rental.id == id);
      return cachedRental;
    } catch (e) {
      // Jika tidak ada di cache, coba ambil dari API
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.apiUrl}/transaksi/detail/$id'),
        );

        if (response.statusCode == 200) {
          return Rental.fromJson(json.decode(response.body));
        } else {
          print('Get rental by ID failed: ${response.body}');
          return null;
        }
      } catch (e) {
        print('Get rental by ID error: $e');
        return null;
      }
    }
  }

  /// Method helper untuk mendapatkan rentals berdasarkan status tertentu
  List<Rental> getRentalsByStatus(RentalStatus status) {
    return _rentals.where((rental) => rental.status == status).toList();
  }

  /// Method untuk refresh data setelah verifikasi
  Future<void> refreshRentals(String userid) async {
    await fetchRentals(userid);
  }

  // ========== VERIFIKASI MOBIL KELUAR ==========
  /// Verifikasi mobil keluar (approved -> onGoing)
  Future<Map<String, dynamic>> verifyCarOut({
    required int transaksiId,
    required String kilometerKeluar,
    required String bensinKeluar,
    required String kondisiFisikKeluar,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse('${AppConfig.apiUrl}/verifikasi-keluar/$transaksiId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'kilometer_keluar': kilometerKeluar,
          'bensin_keluar': bensinKeluar,
          'kondisi_fisik_keluar': kondisiFisikKeluar,
        }),
      );

      final responseData = json.decode(response.body);
      print('Verify car out response: $responseData');

      if (response.statusCode == 200) {
        // Refresh data setelah verifikasi berhasil
        await refreshRentals(''); // Refresh data terbaru

        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Verifikasi mobil keluar berhasil',
          'data': responseData['data'],
        };
      } else {
        final errorMessage = responseData['message'] ??
            'Gagal melakukan verifikasi mobil keluar';
        _setError(errorMessage);

        return {
          'success': false,
          'message': errorMessage,
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      final errorMessage = 'Error saat koneksi ke server: $e';
      _setError(errorMessage);
      print('Verify car out error: $e');

      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      _setLoading(false);
    }
  }

  // ========== VERIFIKASI MOBIL MASUK ==========
  /// Verifikasi mobil masuk (onGoing -> completed)
  Future<Map<String, dynamic>> verifyCarIn({
    required int transaksiId,
    required String kilometerMasuk,
    required String bensinMasuk,
    required String kondisiFisikMasuk,
    DateTime? tanggalKembali,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse('${AppConfig.apiUrl}/verifikasi-masuk/$transaksiId');

    try {
      final requestBody = {
        'kilometer_masuk': kilometerMasuk,
        'bensin_masuk': bensinMasuk,
        'kondisi_fisik_masuk': kondisiFisikMasuk,
      };

      // Tambahkan tanggal kembali jika ada
      if (tanggalKembali != null) {
        requestBody['tanggal_kembali'] = tanggalKembali.toIso8601String();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);
      print('Verify car in response: $responseData');

      if (response.statusCode == 200) {
        // Refresh data setelah verifikasi berhasil
        await refreshRentals(''); // Refresh data terbaru

        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Verifikasi mobil masuk berhasil',
          'data': responseData['data'],
        };
      } else {
        final errorMessage =
            responseData['message'] ?? 'Gagal melakukan verifikasi mobil masuk';
        _setError(errorMessage);

        return {
          'success': false,
          'message': errorMessage,
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      final errorMessage = 'Error saat koneksi ke server: $e';
      _setError(errorMessage);
      print('Verify car in error: $e');

      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      _setLoading(false);
    }
  }

  // ========== GET TRANSACTION DETAIL FOR VERIFICATION ==========
  /// Mendapatkan detail transaksi untuk verifikasi
  Future<Map<String, dynamic>> getTransactionDetail(int transaksiId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.apiUrl}/car-verification/transaction/$transaksiId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);
      print('Get transaction detail response: $responseData');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Detail transaksi berhasil diambil',
          'data': responseData['data'],
        };
      } else {
        final errorMessage =
            responseData['message'] ?? 'Gagal mengambil detail transaksi';
        _setError(errorMessage);

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      final errorMessage = 'Error saat koneksi ke server: $e';
      _setError(errorMessage);
      print('Get transaction detail error: $e');

      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      _setLoading(false);
    }
  }

  // ========== HELPER METHODS ==========
  /// Cek apakah transaksi bisa diverifikasi keluar
  bool canVerifyOut(Rental rental) {
    return rental.status == RentalStatus.approved &&
        rental.statusMobilKeluar == false;
  }

  /// Cek apakah transaksi bisa diverifikasi masuk
  bool canVerifyIn(Rental rental) {
    return rental.status == RentalStatus.onGoing &&
        rental.statusMobilMasuk == false;
  }

  /// Get rentals yang siap untuk verifikasi keluar
  List<Rental> get rentalsReadyForOut =>
      _rentals.where((rental) => canVerifyOut(rental)).toList();

  /// Get rentals yang siap untuk verifikasi masuk
  List<Rental> get rentalsReadyForIn =>
      _rentals.where((rental) => canVerifyIn(rental)).toList();
}
