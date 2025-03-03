import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: unused_import
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';
import '../models/cours.dart';
import '../models/examen.dart';
import '../models/soumission_examen.dart';
import '../models/badge.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  final storage = FlutterSecureStorage();

  Future<User> register(String username, String email, String password, String role, {int? parentId}) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password, 'role': role, 'parent': parentId}),
    );
    if (response.statusCode == 201) return User.fromJson(jsonDecode(response.body));
    throw Exception('Échec de l\'inscription');
  }

  Future<Map<String, dynamic>> login(String email, String password, String fcmToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      await storage.write(key: 'role', value: data['user']['role']);
      await http.patch(
        Uri.parse('${baseUrl}users/${data['user']['id']}/update-fcm/'),
        headers: {'Authorization': 'Bearer ${data['access']}', 'Content-Type': 'application/json'},
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      return data;
    }
    throw Exception('Échec de la connexion');
  }

  Future<List<Cours>> getCours() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(Uri.parse('${baseUrl}cours/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Cours.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des cours');
  }

  Future<List<Examen>> getExamens() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(Uri.parse('${baseUrl}examens/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Examen.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des examens');
  }

  Future<void> soumettreExamen(int examenId, {Map<String, String>? reponses, File? fichier}) async {
    final token = await storage.read(key: 'access_token');
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}examens/$examenId/soumettre/'));
    request.headers['Authorization'] = 'Bearer $token';
    if (reponses != null) request.fields['reponses'] = jsonEncode(reponses);
    if (fichier != null) request.files.add(await http.MultipartFile.fromPath('fichier', fichier.path));
    final response = await request.send();
    if (response.statusCode != 201) throw Exception('Échec de la soumission');
  }

  Future<List<User>> getEnfants() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(Uri.parse('${baseUrl}users/enfants/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => User.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des enfants');
  }

  Future<List<SoumissionExamen>> getSoumissions({int? eleveId}) async {
    final token = await storage.read(key: 'access_token');
    final url = eleveId != null ? '${baseUrl}soumissions/?eleve=$eleveId' : '${baseUrl}soumissions/';
    final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => SoumissionExamen.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des soumissions');
  }

  Future<void> corrigerSoumission(int soumissionId, double note, String feedback) async {
    final token = await storage.read(key: 'access_token');
    final response = await http.patch(
      Uri.parse('${baseUrl}soumissions/$soumissionId/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'note': note, 'feedback': feedback}),
    );
    if (response.statusCode != 200) throw Exception('Échec de la correction');
  }

  Future<List<AttributionBadge>> getBadgesUtilisateur() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(Uri.parse('${baseUrl}attributions-badges/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => AttributionBadge.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des badges');
  }

  Future<List<Message>> getMessages() async {
    final token = await storage.read(key: 'access_token');
    final response = await http.get(Uri.parse('${baseUrl}messages/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Message.fromJson(data)).toList();
    }
    throw Exception('Échec du chargement des messages');
  }

  Future<void> sendMessage(int destinataireId, String contenu) async {
    final token = await storage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('${baseUrl}messages/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'destinataire': destinataireId, 'contenu': contenu}),
    );
    if (response.statusCode != 201) throw Exception('Échec de l\'envoi du message');
  }

  Future<void> createCours(String titre, String description, int matiereId, {File? fichier}) async {
    final token = await storage.read(key: 'access_token');
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}cours/'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['matiere'] = matiereId.toString();
    if (fichier != null) request.files.add(await http.MultipartFile.fromPath('fichier', fichier.path));
    final response = await request.send();
    if (response.statusCode != 201) throw Exception('Échec de la création du cours');
  }

  Future<void> createExamen(String titre, String typeExamen, int coursId, int duree, String dateDebut, String dateFin) async {
    final token = await storage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('${baseUrl}examens/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'titre': titre,
        'type_examen': typeExamen,
        'cours': coursId,
        'duree': duree,
        'date_debut': dateDebut,
        'date_fin': dateFin,
      }),
    );
    if (response.statusCode != 201) throw Exception('Échec de la création de l\'examen');
  }
}