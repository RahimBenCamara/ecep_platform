import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cours_provider.dart';
import '../../providers/examen_provider.dart';
import '../../providers/badge_provider.dart';

class EleveDashboard extends StatelessWidget {
  const EleveDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coursProvider = Provider.of<CoursProvider>(context);
    final examenProvider = Provider.of<ExamenProvider>(context);
    final badgeProvider = Provider.of<BadgeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - Élève'),
        actions: [
          IconButton(icon: Icon(Icons.message), onPressed: () => Navigator.pushNamed(context, '/messages')),
          IconButton(icon: Icon(Icons.logout), onPressed: () => authProvider.logout()),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Bienvenue, ${authProvider.user?.username}', style: TextStyle(fontSize: 20)),
            ElevatedButton(onPressed: () => coursProvider.fetchCours(), child: Text('Charger les cours')),
            ElevatedButton(onPressed: () => examenProvider.fetchExamens(), child: Text('Charger les examens')),
            ElevatedButton(onPressed: () => badgeProvider.fetchBadges(), child: Text('Voir mes badges')),
            ElevatedButton(onPressed: () => examenProvider.fetchSoumissions(eleveId: authProvider.user!.id), child: Text('Voir mes résultats')),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: coursProvider.cours.length,
              itemBuilder: (context, index) {
                final cours = coursProvider.cours[index];
                return ListTile(
                  title: Text(cours.titre),
                  subtitle: Text(cours.description),
                  onTap: () => Navigator.pushNamed(context, '/cours', arguments: cours),
                );
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: examenProvider.examens.length,
              itemBuilder: (context, index) {
                final examen = examenProvider.examens[index];
                return ListTile(
                  title: Text(examen.titre),
                  subtitle: Text('Type: ${examen.typeExamen}'),
                  onTap: () => Navigator.pushNamed(context, '/examen', arguments: examen),
                );
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: badgeProvider.badges.length,
              itemBuilder: (context, index) {
                final badge = badgeProvider.badges[index];
                return ListTile(title: Text(badge.badge.nom), subtitle: Text(badge.badge.description));
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: examenProvider.soumissions.length,
              itemBuilder: (context, index) {
                final soumission = examenProvider.soumissions[index];
                return ListTile(
                  title: Text('Examen #${soumission.examenId}'),
                  subtitle: Text('Note: ${soumission.note ?? "Non corrigé"} - Feedback: ${soumission.feedback ?? "Aucun"}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}