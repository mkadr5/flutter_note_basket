import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();
  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializedDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> _initializedDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "appDB.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "Notes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Map<String, dynamic>>> getCategory() async {
    var db = await _getDatabase();
    return (await db.query("category"));
  }

  Future<List<Category>> getCategoryList() async {
    var categoryMapList = await getCategory();
    var categoryList = List<Category>();
    for (Map items in categoryMapList) {
      categoryList.add(Category.fromMap(items));
    }
    return categoryList;
  }

  Future<int> insertCategory(Category category) async {
    var db = await _getDatabase();
    return (await db.insert("category", category.toMap()));
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    return (await db.update("category", category.toMap(),
        where: 'catID = ?', whereArgs: [category.catID]));
  }

  Future<int> deleteCategory(int catID) async {
    var db = await _getDatabase();
    return (await db
        .delete("category", where: 'catID = ?', whereArgs: [catID]));
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _getDatabase();
    var exc = await db.rawQuery(
        "SELECT * FROM notes INNER JOIN category ON category.catID = notes.noteID ORDER BY noteID DESC");
    return exc;
  }

  Future<List<Notes>> getNoteList() async {
    var noteMapList = await getNotes();
    var noteList = List<Notes>();
    for (Map items in noteMapList) {
      noteList.add(Notes.fromMap(items));
    }
    return noteList;
  }

  Future<int> insertNotes(Notes notes) async {
    var db = await _getDatabase();
    return (await db.insert("notes", notes.toMap()));
  }

  Future<int> updateNotes(Notes notes) async {
    var db = await _getDatabase();
    return (await db.update("notes", notes.toMap(),
        where: 'noteID = ?', whereArgs: [notes.noteID]));
  }

  Future<int> deleteNotes(int noteID) async {
    var db = await _getDatabase();
    return (await db.delete("notes", where: 'noteID = ?', whereArgs: [noteID]));
  }

  String dateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thurdsday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}
