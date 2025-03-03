import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/examen.dart';
import '../providers/examen_provider.dart';

class ExamenScreen extends StatefulWidget {
  final Examen examen;

  const ExamenScreen({Key? key, required this.examen}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ExamenScreenState createState() => _ExamenScreenState();
}

class _ExamenScreenState extends State<ExamenScreen> {
  Map<String, String> reponses = {};
  File? fichier;
  final TextEditingController _redactionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final examenProvider = Provider.of<ExamenProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.examen.titre)),
      body: widget.examen.typeExamen == 'QCM'
          ? Text('QCM à implémenter avec questions')
          : widget.examen.typeExamen == 'REDACTION'
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _redactionController,
                    maxLines: 10,
                    decoration: InputDecoration(labelText: 'Votre réponse'),
                  ),
                )
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) setState(() => fichier = File(result.files.single.path!));
                      },
                      child: Text('Choisir un fichier'),
                    ),
                    if (fichier != null) Text('Fichier sélectionné: ${fichier!.path.split('/').last}'),
                  ],
                ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          if (widget.examen.typeExamen == 'QCM') {
            // À compléter avec QCM
          } else if (widget.examen.typeExamen == 'REDACTION') {
            await examenProvider.soumettreExamen(widget.examen.id, reponses: {'texte': _redactionController.text});
          } else {
            await examenProvider.soumettreExamen(widget.examen.id, fichier: fichier);
          }
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
        child: Text('Soumettre'),
      ),
    );
  }
}