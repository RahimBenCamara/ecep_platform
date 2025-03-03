import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cours.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ecep_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cours (
            id INTEGER PRIMARY KEY,
            titre TEXT,
            description TEXT,
            enseignant_id INTEGER,
            fichier_url TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveCours(Cours cours) async {
    final db = await database;
    await db.insert('cours', cours.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cours>> getCoursOffline() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cours');
    return List.generate(maps.length, (i) {
      return Cours(
        id: maps[i]['id'],
        titre: maps[i]['titre'],
        description: maps[i]['description'],
        enseignantId: maps[i]['enseignant_id'],
        fichierUrl: maps[i]['fichier_url'],
      );
    });
  }
}