import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'user.dart';

class DbHelperUser {
  static const int _version = 1;
  static const String _dbName = 'dailyQuest.db';

  // Initializer for the database, if it doesn't exist, create it.
  static Future<Database> _getDB() async {
    String projPath = await getDatabasesPath();
    return openDatabase(join(projPath, _dbName),
      onCreate: (db, version) async => await db.execute( '''
        CREATE TABLE Users(
          username TEXT PRIMARY KEY,
          password TEXT,
          currXp INTEGER,
          level INTEGER
        )
      '''), version: _version
    );
  }

  // Insert a new user into the database
  static Future<int> insertUser(String uName, String pWord) async {
    User newUser = User(uName, pWord);
    final db = await _getDB();
    return await db.insert('Users', newUser.toJson());
  }

  // Update an existing user's data in the database
  static Future<int> updateUser(User user) async {
    final db = await _getDB();
    return await db.update('Users', user.toJson(),
      where: 'username = ?', 
      whereArgs: [user.username]);
  }

  // Check if a user exists in the database
  static Future<bool> userExists(String username) async {
    final db = await _getDB();
    final maps = await db.query('Users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1
    );
    return maps.isNotEmpty;
  }

  // Return the user object for a given username, or null if not found
  static Future<User?> getUser(String username) async {
    final db = await _getDB();
    final maps = await db.query('Users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Validate login credentials
  static Future<bool> validateLogin(String username, String password) async {
    final user = await getUser(username);
    if (user == null) return false;
    return user.password == password;
  }
}