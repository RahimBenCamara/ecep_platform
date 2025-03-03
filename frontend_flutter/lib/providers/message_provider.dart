import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  final ApiService _apiService = ApiService();

  List<Message> get messages => _messages;

  Future<void> fetchMessages() async {
    _messages = await _apiService.getMessages();
    notifyListeners();
  }

  Future<void> sendMessage(int destinataireId, String contenu) async {
    await _apiService.sendMessage(destinataireId, contenu);
    await fetchMessages();
  }
}