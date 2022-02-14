import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {
//we want to create our DataBAse Table
  static Future<void> createTable(Database database) async {
    await database.execute(
        """CREATE TABLE dictionary (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, description TEXT,createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)""");
  }

//create Database
  static Future<Database> db() async {
    return openDatabase('dictionary.db', version: 1,
        onCreate: (Database database, int version) async {
      await createTable(database);
    });
  }

//add item to database
  static Future<int> insertData(String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {'title': title, 'description': description};

    final id = await db.insert('dictionary', data,
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

//Read All Data from Database
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SqlHelper.db();

    return db.query('dictionary', orderBy: "id");
  }

//Update Data
  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result =
        db.update('dictionary', data, where: "id=?", whereArgs: [id]);

    return result;
  }

//delete Item
  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();

    try {
      await db.delete('dictionary', where: "id=?", whereArgs: [id]);
    } catch (error) {
      debugPrint('Some thing went wrong when deleting item $error ');
    }
  }
}
