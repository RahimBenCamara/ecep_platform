import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cours_provider.dart';
import '../../providers/examen_provider.dart';

class EnseignantDashboard extends StatefulWidget {
  const EnseignantDashboard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EnseignantDashboardState createState() => _EnseignantDashboardState();
}

class _EnseignantDashboardState extends State<EnseignantDashboard> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _titreCoursController = TextEditingController();
  final TextEditingController _descCoursController = TextEditingController();
  final TextEditingController _matiereController = TextEditingController();
  final TextEditingController _titreExamenController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  File? _fichierCours;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coursProvider = Provider.of<CoursProvider>(context);
    final examenProvider = Provider.of<ExamenProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - Enseignant'),
        actions: [
          IconButton(icon: Icon(Icons.message), onPressed: () => Navigator.pushNamed(context, '/messages')),
          IconButton(icon: Icon(Icons.logout), onPressed: () => authProvider.logout()),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Bienvenue, ${authProvider.user?.username}', style: TextStyle(fontSize: 20)),
            ElevatedButton(onPressed: () => coursProvider.fetchCours(), child: Text('Charger mes cours')),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Créer un cours'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: _titreCoursController, decoration: InputDecoration(labelText: 'Titre')),
                      TextField(controller: _descCoursController, decoration: InputDecoration(labelText: 'Description')),
                      TextField(controller: _matiereController, decoration: InputDecoration(labelText: 'ID Matière')),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null) setState(() => _fichierCours = File(result.files.single.path!));
                        },
                        child: Text('Choisir un fichier'),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        await coursProvider.createCours(
                          _titreCoursController.text,
                          _descCoursController.text,
                          int.parse(_matiereController.text),
                          fichier: _fichierCours,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: Text('Créer'),
                    ),
                  ],
                ),
              ),
              child: Text('Créer un cours'),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: coursProvider.cours.length,
              itemBuilder: (context, index) {
                final cours = coursProvider.cours[index];
                return ListTile(title: Text(cours.titre), subtitle: Text(cours.description));
              },
            ),
            ElevatedButton(onPressed: () => examenProvider.fetchExamens(), child: Text('Charger mes examens')),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Créer un examen'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: _titreExamenController, decoration: InputDecoration(labelText: 'Titre')),
                      DropdownButton<String>(
                        value: 'QCM',
                        onChanged: (val) {},
                        items: ['QCM', 'REDACTION', 'PRATIQUE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      ),
                      TextField(controller: _dureeController, decoration: InputDecoration(labelText: 'Durée (min)')),
                      TextField(controller: _dateDebutController, decoration: InputDecoration(labelText: 'Date début (YYYY-MM-DD HH:MM)')),
                      TextField(controller: _dateFinController, decoration: InputDecoration(labelText: 'Date fin (YYYY-MM-DD HH:MM)')),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        final coursId = coursProvider.cours.isNotEmpty ? coursProvider.cours.first.id : 1;
                        await examenProvider.createExamen(
                          _titreExamenController.text,
                          'QCM',
                          coursId,
                          int.parse(_dureeController.text),
                          _dateDebutController.text,
                          _dateFinController.text,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: Text('Créer'),
                    ),
                  ],
                ),
              ),
              child: Text('Créer un examen'),
            ),
            ElevatedButton(onPressed: () => examenProvider.fetchSoumissions(), child: Text('Charger les soumissions')),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: examenProvider.soumissions.length,
              itemBuilder: (context, index) {
                final soumission = examenProvider.soumissions[index];
                return ListTile(
                  title: Text('Soumission #${soumission.id}'),
                  subtitle: Text('Élève: ${soumission.eleveId} - Note: ${soumission.note ?? "Non corrigé"}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Corriger Soumission'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: _noteController, decoration: InputDecoration(labelText: 'Note'), keyboardType: TextInputType.number),
                              TextField(controller: _feedbackController, decoration: InputDecoration(labelText: 'Feedback')),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                await examenProvider.corrigerSoumission(
                                  soumission.id,
                                  double.parse(_noteController.text),
                                  _feedbackController.text,
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              },
                              child: Text('Valider'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}