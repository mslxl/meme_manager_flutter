import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:meme_man/db/config_db.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:meme_man/view/config/config_controller.dart';
import 'package:sqflite/sqflite.dart';

class MemeData extends GetxController {
  final currentVersion = 2;
  var _isLoaded = false;

  Map<String, int> tag = new Map();
  var data = RxList.empty(growable: false);

  Future<Database> _getDB() async {
    try {
      var conf = Get.find<ConfigData>();
      var path = (await conf.getStorageLocation()) + "/meme.db";
      return await openDatabase(path, version: currentVersion,
          onCreate: (Database db, int version) async {
        db.execute(
            "create table Item ( id integer primary key autoincrement, name text, path text )");
        db.execute(
            "create table Tag ( id integer primary key autoincrement, tag text )");
        db.execute("create table Map ( item integer, tag integer )");
      }, onDowngrade: (Database db, int oldVersion, int newVersion) {
        Get.snackbar("Warning",
            "Database downgrade($oldVersion->$newVersion), we can not promise the program work normally.");
      }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
        Get.snackbar("Database upgrade", "$oldVersion -> $newVersion");
        switch (oldVersion) {
        }
      });
    } catch (e) {
      Get.snackbar("Database error", e.toString());
      throw e;
    }
  }

  load() async {
    if (!_isLoaded) {
      var conf = Get.find<ConfigData>();

      var db = await _getDB();
      var dbItems = await db.query("Item");
      var dbTags = await db.query("Tag");
      var dbMap = await db.query("Map");
      await db.close();

      // Gen tag -> id Mapping
      var id2Tag = Map<String, String>();
      dbTags.forEach((element) {
        var t = element["tag"].toString();
        var id = element["id"].toString();
        tag[t] = int.parse(id);
        id2Tag[id] = t;
      });

      // Gen id -> meme Mapping
      var id2Meme = Map<String, MemeModel>();
      dbItems.forEach((element) {
        var item = MemeModel(
            element["name"].toString(),
            List.empty(growable: true),
            conf.storageLocation.value + "/img/" + element["path"].toString());
        id2Meme[element["id"].toString()] = item;
      });

      // Build tags
      dbMap.forEach((element) {
        var obj = id2Meme[element["item"].toString()];
        if (obj != null) {
          MemeModel item = obj;
          var t = id2Tag[element["tag"].toString()].toString();
          item.tags.add(t);
        }
      });

      data.clear();
      data.addAll(id2Meme.values);

      _isLoaded = true;
    }
  }

  File _copyFile(File file) {
    var conf = Get.find<ConfigData>();
    var dirImg = Directory("${conf.storageLocation.value}/img");
    if (!dirImg.existsSync()) {
      dirImg.createSync();
    }
    var fileType = file.path.substring(file.path.lastIndexOf(".") + 1);
    var m5 = md5.convert(file.readAsBytesSync());
    var newPath = "${dirImg.path}/$m5.$fileType";
    printInfo(info: "Copy file from ${file.path} to $newPath");
    file.copySync(newPath);
    return File(newPath);
  }

  add(MemeModel memeModel) async {
    File newFile = _copyFile(File(memeModel.path));

    var db = await _getDB();
    // Store meme
    int memeId = await db.insert("Item", {
      "name": memeModel.name,
      "path": newFile.path.substring(newFile.path.lastIndexOf("/") + 1),
    });

    // Check and store tag
    var alreadyExistTags = tag.keys;
    var completeTags = 0;
    memeModel.tags.forEach((element) async {
      var tagId;
      if (alreadyExistTags.contains(element)) {
        tagId = tag[element];
      } else {
        tagId = await db.insert("Tag", {"tag": element});
        tag[element] = tagId;
      }
      // Connect map
      await db.insert("Map", {"item": memeId, "tag": tagId});

      completeTags++;
      if (completeTags == memeModel.tags.length) {
        // Refresh mem. To speed app, do not read from database again.
        data.add(memeModel);
        await db.close();
      }
    });
  }
}
