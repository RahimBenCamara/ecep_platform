import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatelessWidget {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _badgeIdController = TextEditingController();

  AdminDashboard({Key? key}) : super(key: key);
  
  get http => null;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - Administrateur'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: () => authProvider.logout())],
      ),
      body: Column(
        children: [
          Text('Bienvenue, ${authProvider.user?.username}', style: TextStyle(fontSize: 20)),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Attribuer un badge'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _userIdController, decoration: InputDecoration(labelText: 'ID Utilisateur')),
                    TextField(controller: _badgeIdController, decoration: InputDecoration(labelText: 'ID Badge')),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      final token = await apiService.storage.read(key: 'access_token');
                      await http.post(
                        Uri.parse('${ApiService.baseUrl}attributions-badges/'),
                        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
                        body: jsonEncode({'user': int.parse(_userIdController.text), 'badge': int.parse(_badgeIdController.text)}),
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: Text('Attribuer'),
                  ),
                ],
              ),
            ),
            child: Text('Attribuer un badge'),
          ),
        ],
      ),
    );
  }
}