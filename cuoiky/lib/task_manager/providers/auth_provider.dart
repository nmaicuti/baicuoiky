import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  Future<void> register(String username, String email, String password, String role) async {
    try {
      final data = await _apiService.register(username, email, password, role);
      _user = User.fromJson(data['user']);
      _token = data['token'];
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final data = await _apiService.login(email, password);
      _user = User.fromJson(data['user']);
      _token = data['token'];
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();
  }
}