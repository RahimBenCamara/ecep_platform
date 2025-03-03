import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _role;
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  User? get user => _user;
  String? get role => _role;

  Future<void> register(String username, String email, String password, String role, {int? parentId}) async {
    _user = await _apiService.register(username, email, password, role, parentId: parentId);
    _role = role;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    String? fcmToken = await _notificationService.getFcmToken();
    final data = await _apiService.login(email, password, fcmToken ?? '');
    _user = User.fromJson(data['user']);
    _role = data['user']['role'];
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _role = null;
    await _apiService.storage.deleteAll();
    notifyListeners();
  }
}