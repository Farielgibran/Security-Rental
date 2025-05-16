import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:security_rental/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Konstruktor untuk memuat data pengguna dari local storage
  AuthService() {
    _loadUser();
  }

  // Memuat data pengguna dari local storage
  Future<void> _loadUser() async {
    setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        _currentUser = User.fromJson(json.decode(userJson));
        _token = token;
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setLoading(false);
    }
  }

  // Menyimpan data pengguna ke local storage
  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUser != null && _token != null) {
        await prefs.setString('user', json.encode(_currentUser!.toJson()));
        await prefs.setString('token', _token!);
      }
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // // Registrasi pengguna baru
  // Future<bool> register({
  //   required String name,
  //   required String email,
  //   required String password,
  //   required String phone,
  // }) async {
  //   setLoading(true);

  //   try {
  //     final response = await http.post(
  //       Uri.parse('${AppConfig.apiUrl}/auth/register'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'phone': phone,
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       final data = json.decode(response.body);
  //       _currentUser = User.fromJson(data['user']);
  //       _token = data['token'];

  //       await _saveUser();
  //       return true;
  //     } else {
  //       print('Registration failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Registration error: $e');
  //     return false;
  //   } finally {
  //     setLoading(false);
  //   }
  // }

  // Login pengguna
  Future<bool> login(
      {required String username, required String password}) async {
    setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/login-alt'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data['user']);
        _token = data['token'];

        await _saveUser();
        return true;
      } else {
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Logout pengguna
  Future<void> logout() async {
    setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');

      _currentUser = null;
      _token = null;
    } catch (e) {
      print('Logout error: $e');
    } finally {
      setLoading(false);
    }
  }

  // Update profile pengguna
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? idCardNumber,
    String? drivingLicense,
  }) async {
    if (_currentUser == null || _token == null) return false;

    setLoading(true);

    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.apiUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'idCardNumber': idCardNumber,
          'drivingLicense': drivingLicense,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);

        await _saveUser();
        return true;
      } else {
        print('Update profile failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Update profile error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
