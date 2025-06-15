import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:security_rental/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _token != null;
  bool get isInitialized => _isInitialized;

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
        print('Auto-login successful');
      }
    } catch (e) {
      print('Error loading user: $e');
      await _clearUserData();
    } finally {
      _isInitialized = true;
      setLoading(false);
    }
  }

  // Membersihkan data user dari local storage
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
      _currentUser = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Menyimpan data pengguna ke local storage
  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUser != null && _token != null) {
        await prefs.setString('user', json.encode(_currentUser!.toJson()));
        await prefs.setString('token', _token!);
        print('User data saved successfully');
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

  // Login pengguna
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    setLoading(true);

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}/login-alt'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['user'] != null && data['token'] != null) {
          _currentUser = User.fromJson(data['user']);
          _token = data['token'];

          await _saveUser();

          print('Login successful for user: ${_currentUser?.username}');
          return true;
        } else {
          print('Login failed: Invalid response format');
          return false;
        }
      } else {
        print(
            'Login failed with status ${response.statusCode}: ${response.body}');
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
      // Beritahu server bahwa user logout (opsional)
      if (_token != null) {
        try {
          await http.post(
            Uri.parse('${AppConfig.apiUrl}/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          print('Server logout notification failed: $e');
          // Continue with local logout even if server notification fails
        }
      }

      await _clearUserData();
      print('Logout completed successfully');
    } catch (e) {
      print('Logout error: $e');
      // Tetap clear data meskipun ada error
      await _clearUserData();
    } finally {
      setLoading(false);
    }
  }

  // Force logout (without server notification)
  Future<void> forceLogout() async {
    setLoading(true);
    await _clearUserData();
    setLoading(false);
    print('Force logout completed');
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
      final response = await http
          .patch(
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
          )
          .timeout(const Duration(seconds: 15));

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

  // Get authorization header
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_token ?? ''}',
    };
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.lvlUsers == role;
  }

  // Get token
  String? get token => _token;
}
