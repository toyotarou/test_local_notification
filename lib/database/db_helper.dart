// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static late Database _db;

  ///
  static Future<void> initDb() async {
    final String dbPath = await getDatabasesPath();

    _db = await openDatabase(
      join(dbPath, 'reminders.db'),
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          isActive INTEGER,
          reminderTime TEXT,
          category TEXT
        )
        ''');
      },
      version: 1,
    );
  }

  ///
  static Future<List<Map<String, dynamic>>> getReminders() async {
    return _db.query('reminders');
  }

  ///
  static Future<Map<String, dynamic>?> getRemindersById(int id) async {
    final List<Map<String, dynamic>> results =
        await _db.query('reminders', where: 'id = ?', whereArgs: <Object?>[id]);

    if (results.isNotEmpty) {
      return results.first;
    }

    return null;
  }

  ///
  static Future<int> addReminder(Map<String, dynamic> reminder) async {
    return _db.insert('reminders', reminder);
  }

  ///
  static Future<void> updateReminder(
      int id, Map<String, dynamic> reminder) async {
    await _db.update('reminders', reminder,
        where: 'id = ?', whereArgs: <Object?>[id]);
  }

  ///
  static Future<void> deleteReminder(int id) async {
    await _db.delete('reminders', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  ///
  static Future<void> toggleReminder(int id, bool isActive) async {
    await _db.update(
        'reminders', <String, Object?>{'isActive': isActive ? 1 : 0},
        where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
