import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:security_rental/Config/app_config.dart';
import 'package:security_rental/Model/car_model.dart';

class CarService extends ChangeNotifier {
  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Untuk demo/pengembangan, bisa menggunakan data dummy
  List<String> get carTypes =>
      ['Semua', 'SUV', 'Sedan', 'MPV', 'Hatchback', 'Sport'];

  CarService() {
    // Memuat data mobil dari cache saat inisialisasi
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Mengambil data mobil dari API
  Future<void> fetchCars() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/mobil'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cars = data.map((car) => Car.fromJson(car)).toList();
        print(_cars);
      } else {
        _setError('Failed to load cars. Status: ${response.statusCode}');
        print('Fetch cars failed: ${response.body}');
      }
    } catch (e) {
      _setError('Error connecting to server: $e');
      print('Fetch cars error: $e');

      // Jika API gagal, gunakan data dummy untuk demo/development
    } finally {
      _setLoading(false);
    }
  }

  // // Mendapatkan detail mobil berdasarkan ID
  // Future<Car?> getCarById(String id) async {
  //   try {
  //     // Cari di cache dulu
  //     final cachedCar = _cars.firstWhere((car) => car.id == id);
  //     return cachedCar;
  //   } catch (e) {
  //     // Jika tidak ada di cache, coba ambil dari API
  //     try {
  //       final response = await http.get(
  //         Uri.parse('${AppConfig.apiUrl}/cars/$id'),
  //       );

  //       if (response.statusCode == 200) {
  //         return Car.fromJson(json.decode(response.body));
  //       } else {
  //         print('Get car by ID failed: ${response.body}');
  //         return null;
  //       }
  //     } catch (e) {
  //       print('Get car by ID error: $e');
  //       return null;
  //     }
  //   }
  // }
}
