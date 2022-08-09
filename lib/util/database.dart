import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/util/conf.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class MemeDatabase {
  static final _lock = Lock();

  MemeDatabase();

  Future<String> getDBPath() async {
    return join(await getStorageFolder(), "meme_index.db");
  }

  Future<String> getStorageFolder() async {
    Config cfg = await Config.getInstance();
    return cfg.storageFolder;
  }

  Future<T> withDB<T>(FutureOr<T> Function(Database) op) async {
    return _lock.synchronized(() async {
      String path = await getDBPath();
      Database db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        debugPrint("Create database $path");
        await db.execute(
            "CREATE TABLE Meme(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT)");
        await db.execute(
            "CREATE TABLE Tag(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)");
        await db.execute("CREATE TABLE Meme_Tag(meme INTEGER, tag INTEGER)");
        await db.execute(
            "CREATE TABLE Addition(id INTEGER PRIMARY KEY, info TEXT)");

        await db.execute(
            "CREATE TABLE TagNSP(id INTEGER PRIMARY KEY AUTOINCREMENT, nsp TEXT)");
        await db
            .execute("CREATE TABLE TagNSPContent(id INTEGER, content TEXT)");
      });
      dynamic ret = await op(db);
      await db.close();
      return ret;
    });
  }

  void registerTagNSP(String tag, Database db) async {
    var tagSplit = tag.split(":");
    String nsp = tagSplit[0], tg = tagSplit[1];
    List<Map> list =
        await db.rawQuery("SELECT id FROM TagNSP WHERE nsp = ? LIMIT 1", [nsp]);
    int nspID = -1;
    if (list.isEmpty) {
      nspID = await db.rawInsert("INSERT INTO TagNSP(nsp) VALUES(?)", [nsp]);
    } else {
      nspID = list.first["id"];
    }
    if ((await db.rawQuery(
            "SELECT id FROM TagNSPContent WHERE id = ? and content = ? LIMIT 1",
            [nspID, tg]))
        .isEmpty) {
      await db.rawInsert(
          "INSERT INTO TagNSPContent(id,content) VALUES(?,?)", [nspID, tg]);
    }
  }

  Future<File> md5NameToFile(String name) async {
    String storagePath = await getStorageFolder();
    return File(join(storagePath, name));
  }

  Future<String> addImage(File image) async {
    String storagePath = await getStorageFolder();
    String imageMd5 = (await md5.bind(image.openRead()).first).toString();
    String ext = image.path.substring(image.path.indexOf("."));
    String newPath = join(storagePath, imageMd5 + ext);
    if (kDebugMode) {
      print("Copy to $newPath");
    }
    image.copySync(newPath);
    return imageMd5 + ext;
  }

  void addMeme(BasicMeme meme, {bool updateIfExists = true}) async {
    await withDB((db) async {
      List<int> tagId = List<int>.empty(growable: true);
      for (String tag in meme.tags) {
        List<Map> list = await db
            .rawQuery("SELECT id FROM Tag WHERE name = ? LIMIT 1", [tag]);
        if (list.isEmpty) {
          int id = await db.rawInsert("INSERT INTO Tag(name) VALUES(?)", [tag]);
          tagId.add(id);
        } else {
          int id = list.first['id'];
          tagId.add(id);
        }
        registerTagNSP(tag, db);
      }
      int memeId = -1;
      bool updateSuccessful = false;
      if (meme.id != -1 && updateIfExists) {
        memeId = meme.id;
        List<Map> record =
            await db.rawQuery("SELECT id FROM Meme WHERE id = ?", [memeId]);
        if (record.isNotEmpty) {
          await db.rawDelete("DELETE FROM Meme_Tag WHERE meme = ?", [memeId]);
          await db.rawUpdate("UPDATE Addition SET info = ? WHERE id = ?",
              [meme.dumpAddition(), memeId]);
          updateSuccessful = true;
        }
      }
      if (!updateSuccessful) {
        memeId = await db.rawInsert("INSERT INTO Meme(name, type) VALUES(?,?)",
            [meme.name, meme.getType()]);

        await db.rawInsert("INSERT INTO Addition(id, info) VALUES(?, ?)",
            [memeId, meme.dumpAddition()]);
      }
      for (int tagId in tagId) {
        await db.rawInsert(
            "INSERT INTO Meme_Tag(meme, tag) VALUES(?,?)", [memeId, tagId]);
      }
    });
  }

  Future<int> count() async {
    return await withDB((db) async {
      List<Map> res = await db.rawQuery("SELECT COUNT() FROM Meme");
      return res.first["COUNT()"];
    });
  }

  Future<BasicMeme> _convertToMemeFromIdx(
      Map<dynamic, dynamic> index, Database db) async {
    int memeId = index["id"];
    List<String> tag = List.empty(growable: true);
    String name = index["name"];
    String type = index["type"];

    List<Map> tagIds =
        await db.rawQuery("SELECT tag FROM Meme_Tag Where meme = ?", [memeId]);
    for (var idMap in tagIds) {
      int id = idMap["tag"];
      List<Map> tagMap =
          await db.rawQuery("SELECT name FROM Tag WHERE id = ?", [id]);
      for (var item in tagMap) {
        tag.add(item["name"]);
      }
    }
    String additionInfo =
        (await db.rawQuery("SELECT info FROM Addition WHERE id = ?", [memeId]))
            .first["info"]
            .toString();

    if (type == "text") {
      var meme = TextMeme(
        id: memeId,
        name: name,
        tags: tag,
      );
      meme.loadAddition(additionInfo);
      return meme;
    } else if (type == "image") {
      var meme = ImageMeme(
        id: memeId,
        name: name,
        tags: tag,
      );
      meme.loadAddition(additionInfo);
      return meme;
    } else {
      throw UnimplementedError();
    }
  }

  Future<BasicMeme> atDesc(int index) async {
    return await withDB((db) async {
      List<Map> idx = await db.rawQuery(
          "SELECT * FROM Meme ORDER BY id DESC LIMIT ?,?", [index, index + 1]);
      return _convertToMemeFromIdx(idx.first, db);
    });
  }

  Future<BasicMeme> getById(int id) async {
    return await withDB((db) async {
      List<Map> idx =
          await db.rawQuery("SELECT * FROM Meme WHERE id = ?", [id]);
      return _convertToMemeFromIdx(idx.first, db);
    });
  }

  Future<List<String>> findNSPWithPrefix(String prefix) async {
    return await withDB((db) async {
      List<Map> list = await db.rawQuery(
          "SELECT nsp FROM TagNSP WHERE nsp LIKE ? LIMIT 20", ["$prefix%"]);
      List<String> res =
          list.map((e) => e["nsp"].toString()).toList(growable: false);
      if (kDebugMode) {
        print("nsp with prefix: ${res.toString()}");
      }
      return res;
    });
  }

  Future<List<String>> findTagWithNSPAndPrefix(
      String nsp, String prefix) async {
    return await withDB((db) async {
      List<Map> list = await db.rawQuery(
          "SELECT content FROM TagNSPContent WHERE id = (SELECT id FROM TagNSP WHERE nsp = ?) AND content LIKE ? LIMIT 20",
          [nsp, "$prefix%"]);
      List<String> res =
          list.map((e) => e["content"].toString()).toList(growable: false);
      if (kDebugMode) {
        print("tag in nsp $nsp with prefix: ${res.toString()}");
      }
      return res;
    });
  }
}
