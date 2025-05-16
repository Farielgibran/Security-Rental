import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:security_rental/Model/rental_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        Uri.parse('${AppConfig.apiUrl}/transaksi/security'),
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
}
