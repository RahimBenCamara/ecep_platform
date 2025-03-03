import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cours.dart';

class CoursScreen extends StatelessWidget {
  final Cours cours;

  const CoursScreen({Key? key, required this.cours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cours.titre)),
      body: Column(
        children: [
          Text(cours.description),
          if (cours.fichierUrl != null)
            ElevatedButton(
              onPressed: () async => await launchUrl(Uri.parse(cours.fichierUrl!)),
              child: Text('Ouvrir fichier'),
            ),
        ],
      ),
    );
  }
}