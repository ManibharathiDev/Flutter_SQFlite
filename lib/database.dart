import 'package:database_app/note.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class SqliteService{
  final String databaseName = "Notes.db";

  Future<Database> initializeDb() async{
      String path = await getDatabasesPath();

      return openDatabase(
        join(path,databaseName),
        onCreate: (database,version) async{
          await database.execute(
            'CREATE TABLE Notes(id INTEGER PRIMARY KEY AUTOINCREMENT,description TEXT NOT NULL)'
          );
        },
        version: 1
      );
  }

  Future<int> createItem(Note note) async{
    int result = 0;
    final Database db = await initializeDb();
    final id = await db.insert('Notes', note.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Note>> getItems() async {
    final db = await initializeDb();
    final List<Map<String, Object?>> queryResult = 
      await db.query('Notes');
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> deleteItem(String id) async {
   final db = await initializeDb();    try {
      await db.delete("Notes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}