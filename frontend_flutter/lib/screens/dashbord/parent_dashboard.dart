import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/examen_provider.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  List<User> enfants = [];

  @override
  void initState() {
    super.initState();
    _fetchEnfants();
  }

  Future<void> _fetchEnfants() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    enfants = await apiService.getEnfants();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final examenProvider = Provider.of<ExamenProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - Parent'),
        actions: [
          IconButton(icon: Icon(Icons.message), onPressed: () => Navigator.pushNamed(context, '/messages')),
          IconButton(icon: Icon(Icons.logout), onPressed: () => authProvider.logout()),
        ],
      ),
      body: Column(
        children: [
          Text('Bienvenue, ${authProvider.user?.username}', style: TextStyle(fontSize: 20)),
          ElevatedButton(onPressed: _fetchEnfants, child: Text('Charger les enfants')),
          Expanded(
            child: ListView.builder(
              itemCount: enfants.length,
              itemBuilder: (context, index) {
                final enfant = enfants[index];
                return ExpansionTile(
                  title: Text(enfant.username),
                  children: [
                    ListTile(
                      title: Text('Suivi des soumissions'),
                      onTap: () async {
                        await examenProvider.fetchSoumissions(eleveId: enfant.id);
                        setState(() {});
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: examenProvider.soumissions.length,
                      itemBuilder: (context, i) {
                        final soumission = examenProvider.soumissions[i];
                        return ListTile(
                          title: Text('Examen #${soumission.examenId}'),
                          subtitle: Text('Note: ${soumission.note ?? "Non corrigé"} - Feedback: ${soumission.feedback ?? "Aucun"}'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}