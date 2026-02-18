import 'dart:async';
import 'package:sanad_app/model/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _db;
  static const int _version = 2;
  static const String _tableName = 'tasks';
  Future<Database> get mydb async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    try {
      String _path = join(await getDatabasesPath(), 'tasks.db');
      return await openDatabase(
        _path,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      print("DB Init Error: $e");
      rethrow;
    }
  }

  FutureOr<void> _onCreate(db, version) async {
    await db.execute('''
            CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          interval TEXT,
          dueDate TEXT,
          isCompleted INTEGER,
          category TEXT,
          time TEXT,
          progress REAL,
          color TEXT,
          icon TEXT
        )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _ensureSchema(db);
      await _migrateLegacyColumns(db);
    }
  }

  Future<void> _onOpen(Database db) async {
    await _ensureSchema(db);
  }

  Future<void> _ensureSchema(Database db) async {
    final existingColumns = await _getExistingColumns(db);
    await _addColumnIfMissing(db, existingColumns, 'description TEXT');
    await _addColumnIfMissing(db, existingColumns, 'interval TEXT');
    await _addColumnIfMissing(db, existingColumns, 'dueDate TEXT');
    await _addColumnIfMissing(db, existingColumns, 'isCompleted INTEGER');
    await _addColumnIfMissing(db, existingColumns, 'category TEXT');
    await _addColumnIfMissing(db, existingColumns, 'time TEXT');
    await _addColumnIfMissing(db, existingColumns, 'progress REAL');
    await _addColumnIfMissing(db, existingColumns, 'color TEXT');
    await _addColumnIfMissing(db, existingColumns, 'icon TEXT');
  }

  Future<Set<String>> _getExistingColumns(Database db) async {
    final rows = await db.rawQuery('PRAGMA table_info($_tableName)');
    return rows.map((row) => row['name'] as String).toSet();
  }

  Future<void> _addColumnIfMissing(
    Database db,
    Set<String> existingColumns,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    if (existingColumns.contains(columnName)) return;
    await db.execute('ALTER TABLE $_tableName ADD COLUMN $columnDefinition');
  }

  Future<void> _migrateLegacyColumns(Database db) async {
    final existingColumns = await _getExistingColumns(db);
    if (existingColumns.contains('desc') &&
        existingColumns.contains('description')) {
      await db.execute(
        'UPDATE $_tableName SET description = desc WHERE description IS NULL',
      );
    }
    if (existingColumns.contains('date') &&
        existingColumns.contains('dueDate')) {
      await db.execute(
        'UPDATE $_tableName SET dueDate = date WHERE dueDate IS NULL',
      );
    }
  }

  Future<int> insert(Task task) async {
    final db = await mydb;
    return await db.insert(_tableName, task.toJson());
  }

  Future<List<Map<String, dynamic>>> query() async {
    final db = await mydb;
    return await db.query(_tableName);
  }

  Future<int> delete(Task task) async {
    final db = await mydb;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> updateCompleted(int id) async {
    final db = await mydb;
    return await db.rawUpdate(
      '''
      UPDATE $_tableName
      SET isCompleted = ?
      WHERE id = ?
      ''',
      [1, id],
    );
  }

  Future<int> updateTask(Task task) async {
    final db = await mydb;
    return await db.update(
      _tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
