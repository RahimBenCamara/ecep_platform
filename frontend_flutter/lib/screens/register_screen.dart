import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _parentIdController = TextEditingController();
  String _selectedRole = 'ELEVE';
  final List<String> _roles = ['ELEVE', 'PARENT', 'ENSEIGNANT', 'ADMIN'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Nom d\'utilisateur')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            if (_selectedRole == 'ELEVE')
              TextField(controller: _parentIdController, decoration: InputDecoration(labelText: 'ID du parent (optionnel)'), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value!),
              items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).register(
                  _usernameController.text,
                  _emailController.text,
                  _passwordController.text,
                  _selectedRole,
                  parentId: _parentIdController.text.isNotEmpty ? int.parse(_parentIdController.text) : null,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}