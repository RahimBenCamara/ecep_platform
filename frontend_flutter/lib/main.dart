import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/cours.dart';
import 'models/examen.dart';
import 'providers/auth_provider.dart';
import 'providers/cours_provider.dart';
import 'providers/examen_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/message_provider.dart';
import 'screens/dashbord/admin_dashboard.dart';
import 'screens/dashbord/enseignant_dashboard.dart';
import 'screens/dashbord/parent_dashboard.dart';
import 'screens/dashbord/eleve_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/cours_screen.dart';
import 'screens/examen_screen.dart';
import 'screens/message_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CoursProvider()),
        ChangeNotifierProvider(create: (_) => ExamenProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        Provider(create: (_) => ApiService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCEP',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) {
          final role = Provider.of<AuthProvider>(context).role;
          switch (role) {
            case 'ELEVE':
              return EleveDashboard();
            case 'PARENT':
              return ParentDashboard();
            case 'ENSEIGNANT':
              return EnseignantDashboard();
            case 'ADMIN':
              return AdminDashboard();
            default:
              return LoginScreen();
          }
        },
        '/cours': (context) => CoursScreen(cours: ModalRoute.of(context)!.settings.arguments as Cours),
        '/examen': (context) => ExamenScreen(examen: ModalRoute.of(context)!.settings.arguments as Examen),
        '/messages': (context) => MessageScreen(),
      },
    );
  }
}