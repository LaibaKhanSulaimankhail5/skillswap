import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

/// Local SQLite cache — lets the app show the last-known profile and
/// discovery list when Firestore is unreachable (no internet).
class DbService {
  static Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'skillswap_cache.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_profiles (
            uid TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_discovery (
            id INTEGER PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> cacheProfile(UserModel user) async {
    final db = await _database;
    await db.insert('cached_profiles', {
      'uid': user.uid,
      'data': jsonEncode(user.toMap()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getCachedProfile(String uid) async {
    final db = await _database;
    final rows = await db.query(
      'cached_profiles',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (rows.isEmpty) return null;
    final map =
        jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
    return UserModel.fromMap(map, uid);
  }

  Future<void> cacheDiscoveryList(List<UserModel> students) async {
    final db = await _database;
    final encoded = jsonEncode(
      students.map((s) => {'uid': s.uid, ...s.toMap()}).toList(),
    );
    await db.insert('cached_discovery', {
      'id': 0,
      'data': encoded,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserModel>> getCachedDiscoveryList() async {
    final db = await _database;
    final rows = await db.query(
      'cached_discovery',
      where: 'id = ?',
      whereArgs: [0],
    );
    if (rows.isEmpty) return [];
    final list = jsonDecode(rows.first['data'] as String) as List<dynamic>;
    return list
        .map(
          (m) =>
              UserModel.fromMap(m as Map<String, dynamic>, m['uid'] as String),
        )
        .toList();
  }
}
