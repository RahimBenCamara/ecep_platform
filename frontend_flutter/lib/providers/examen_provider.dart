import 'dart:io';
import 'package:flutter/material.dart';
import '../models/examen.dart';
import '../models/soumission_examen.dart';
import '../services/api_service.dart';

class ExamenProvider with ChangeNotifier {
  List<Examen> _examens = [];
  List<SoumissionExamen> _soumissions = [];
  final ApiService _apiService = ApiService();

  List<Examen> get examens => _examens;
  List<SoumissionExamen> get soumissions => _soumissions;

  Future<void> fetchExamens() async {
    _examens = await _apiService.getExamens();
    notifyListeners();
  }

  Future<void> fetchSoumissions({int? eleveId}) async {
    _soumissions = await _apiService.getSoumissions(eleveId: eleveId);
    notifyListeners();
  }

  Future<void> soumettreExamen(int examenId, {Map<String, String>? reponses, File? fichier}) async {
    await _apiService.soumettreExamen(examenId, reponses: reponses, fichier: fichier);
    await fetchSoumissions();
  }

  Future<void> corrigerSoumission(int soumissionId, double note, String feedback) async {
    await _apiService.corrigerSoumission(soumissionId, note, feedback);
    await fetchSoumissions();
  }

  Future<void> createExamen(String titre, String typeExamen, int coursId, int duree, String dateDebut, String dateFin) async {
    await _apiService.createExamen(titre, typeExamen, coursId, duree, dateDebut, dateFin);
    await fetchExamens();
  }
}