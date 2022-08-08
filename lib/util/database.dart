import 'package:flutter/material.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/util/conf.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MemeDatabase {
  MemeDatabase();

  Future<String> getPath() async {
    Config cfg = await Config.getInstance();
    String path = join(cfg.storageFolder, "meme_index.db");
    return path;
  }

  Future<void> withDB(Function(Database) op) async {
    String path = await getPath();
    Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      debugPrint("Create database $path");
      await db.execute(
          "CREATE TABLE Meme(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT)");
      await db.execute(
          "CREATE TABLE Tag(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)");
      await db.execute("CREATE TABLE Meme_Tag(meme INTEGER, tag INTEGER)");
      await db.execute("CREATE TABLE Addition(id INTEGER, info TEXT)");

      await db.execute(
          "CREATE TABLE TagNSP(id INTEGER PRIMARY KEY AUTOINCREMENT, nsp TEXT)");
      await db.execute("CREATE TABLE TagNSPContent(id INTEGER, content TEXT)");
    });
    await op(db);
    await db.close();
  }

  void addMeme(BasicMeme meme) async {
    await withDB((db) async {
      List<int> tagId = List<int>.empty(growable: true);
      for (String tag in meme.tags) {
        List<Map> list = await db
            .rawQuery("SELECT 1 FROM Tag WHERE name = ? LIMIT 1", [tag]);
        if (list.isEmpty) {
          int id = await db.rawInsert("INSERT INTO Tag(name) VALUES(?)", [tag]);
          tagId.add(id);
        } else {
          int id = list.first['id'];
          tagId.add(id);
        }
      }

      int memeId = await db.rawInsert(
          "INSERT INTO Meme(name, type) VALUES(?,?)",
          [meme.name, meme.getType()]);

      for (int tagId in tagId) {
        await db.rawInsert(
            "INSERT INTO Meme_Tag(meme, tag) = (?,?)", [memeId, tagId]);
      }

      await db.rawInsert("INSERT INTO Addition(id, info) = (?, ?)",
          [memeId, meme.dumpAddition()]);
    });
  }
}
