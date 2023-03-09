import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE employee(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        number TEXT,
        age TEXT,
        address TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbtech.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new Employee (Employee)
  static Future<int> createEmployee(
      String name, String? number, String? age, String? address) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'number': number,
      'age': age,
      'address': address
    };
    final id = await db.insert('employee', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all Employee (Employee)
  static Future<List<Map<String, dynamic>>> getEmployee() async {
    final db = await SQLHelper.db();
    return db.query('employee', orderBy: "id");
  }

  // Read a single Employee by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('name', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an Employee by id
  static Future<int> updateEmployee(
      int id, String name, String? number, String? age, String? address) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'number': number,
      'age': age,
      'address': address,
      //'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('employee', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteEmployee(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("employee", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
