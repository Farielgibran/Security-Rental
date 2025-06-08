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

  // Membatalkan rental
  Future<bool> cancelRental(int rentalId, String token) async {
    _setLoading(true);

    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.apiUrl}/transaksi/$rentalId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final updatedRental = Rental.fromJson(json.decode(response.body));
        final index = _rentals.indexWhere((rental) => rental.id == rentalId);

        if (index != -1) {
          _rentals[index] = updatedRental;
          notifyListeners();
        }

        return true;
      } else {
        print('Cancel rental failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Cancel rental error: $e');

      // Update lokail status (untuk demo/development)
      try {
        final index = _rentals.indexWhere((rental) => rental.id == rentalId);
        if (index != -1) {
          // Kita tidak bisa mengubah langsung status karena rental immutable
          // Jadi kita buat rental baru dengan status cancelled
          Map<String, dynamic> rentalJson = _rentals[index].toJson();
          rentalJson['status'] = 'cancelled';

          _rentals[index] = Rental.fromJson(rentalJson);
          notifyListeners();
        }
      } catch (e) {
        print('Error updating local rental status: $e');
      }

      return true; // Untuk demo/development
    } finally {
      _setLoading(false);
    }
  }

  /// Verifikasi mobil keluar - mengubah status dari approved ke onGoing
  /// Endpoint: POST /pemeriksaan/verifikasi-keluar/{transaksi_id}
  Future<Map<String, dynamic>> verifikasiMobilKeluar({
    required String transaksiId,
    required bool oli,
    required bool tekananBan,
    required bool toolSet,
    required bool mesin,
    String? catatan,
    String? token,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse(
        '${AppConfig.apiUrl}/pemeriksaan/verifikasi-keluar/$transaksiId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oli': oli,
          'tekanan_ban': tekananBan,
          'tool_set': toolSet,
          'mesin': mesin,
          'catatan': catatan,
        }),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          debugPrint('Verifikasi mobil keluar berhasil');

          // Update local rental status jika ada
          try {
            final index = _rentals
                .indexWhere((rental) => rental.id.toString() == transaksiId);
            if (index != -1) {
              Map<String, dynamic> rentalJson = _rentals[index].toJson();
              rentalJson['status'] = oli && tekananBan && toolSet && mesin
                  ? 'onGoing'
                  : 'rejected';
              _rentals[index] = Rental.fromJson(rentalJson);
              notifyListeners();
            }
          } catch (e) {
            debugPrint('Error updating local rental: $e');
          }

          return {
            'success': true,
            'message': responseData['message'],
            'data': responseData['data'],
          };
        } else {
          _setError(responseData['message']);
          return {
            'success': false,
            'message': responseData['message'],
          };
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        _setError('Validation error: ${errorData['errors']}');
        return {
          'success': false,
          'message': 'Validation error',
          'errors': errorData['errors'],
        };
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message']);
        return {
          'success': false,
          'message': errorData['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        _setError('Gagal verifikasi mobil keluar: ${errorData['message']}');
        return {
          'success': false,
          'message': errorData['message'],
        };
      }
    } catch (e) {
      debugPrint('Error saat verifikasi mobil keluar: $e');
      _setError('Error saat verifikasi mobil keluar: $e');
      return {
        'success': false,
        'message': 'Error saat verifikasi mobil keluar: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Verifikasi mobil masuk - mengubah status dari onGoing ke completed
  /// Endpoint: POST /pemeriksaan/verifikasi-masuk/{transaksi_id}
  Future<Map<String, dynamic>> verifikasiMobilMasuk({
    required String transaksiId,
    required bool oli,
    required bool tekananBan,
    required bool toolSet,
    required bool mesin,
    String? catatan,
    String? token,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse(
        '${AppConfig.apiUrl}/pemeriksaan/verifikasi-masuk/$transaksiId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oli': oli,
          'tekanan_ban': tekananBan,
          'tool_set': toolSet,
          'mesin': mesin,
          'catatan': catatan,
        }),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          debugPrint('Verifikasi mobil masuk berhasil');

          // Update local rental status jika ada
          try {
            final index = _rentals
                .indexWhere((rental) => rental.id.toString() == transaksiId);
            if (index != -1) {
              Map<String, dynamic> rentalJson = _rentals[index].toJson();
              rentalJson['status'] = 'completed';
              _rentals[index] = Rental.fromJson(rentalJson);
              notifyListeners();
            }
          } catch (e) {
            debugPrint('Error updating local rental: $e');
          }

          return {
            'success': true,
            'message': responseData['message'],
            'data': responseData['data'],
          };
        } else {
          _setError(responseData['message']);
          return {
            'success': false,
            'message': responseData['message'],
          };
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        _setError('Validation error: ${errorData['errors']}');
        return {
          'success': false,
          'message': 'Validation error',
          'errors': errorData['errors'],
        };
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message']);
        return {
          'success': false,
          'message': errorData['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        _setError('Gagal verifikasi mobil masuk: ${errorData['message']}');
        return {
          'success': false,
          'message': errorData['message'],
        };
      }
    } catch (e) {
      debugPrint('Error saat verifikasi mobil masuk: $e');
      _setError('Error saat verifikasi mobil masuk: $e');
      return {
        'success': false,
        'message': 'Error saat verifikasi mobil masuk: $e',
      };
    } finally {
      _setLoading(false);
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
}
