import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../services/api_service.dart';

class BadgeProvider with ChangeNotifier {
  List<AttributionBadge> _badges = [];
  final ApiService _apiService = ApiService();

  List<AttributionBadge> get badges => _badges;

  Future<void> fetchBadges() async {
    _badges = await _apiService.getBadgesUtilisateur();
    notifyListeners();
  }
}