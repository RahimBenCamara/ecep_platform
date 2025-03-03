import 'dart:io';
import 'package:flutter/material.dart';
import '../models/cours.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

class CoursProvider with ChangeNotifier {
  List<Cours> _cours = [];
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<Cours> get cours => _cours;

  Future<void> fetchCours() async {
    try {
      _cours = await _apiService.getCours();
      for (var cours in _cours) {
        await _dbService.saveCours(cours);
      }
    } catch (e) {
      _cours = await _dbService.getCoursOffline();
    }
    notifyListeners();
  }

  Future<void> createCours(String titre, String description, int matiereId, {File? fichier}) async {
    await _apiService.createCours(titre, description, matiereId, fichier: fichier);
    await fetchCours();
  }
}