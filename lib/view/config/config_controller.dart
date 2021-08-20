import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:meme_man/db/config_db.dart';
import 'package:meme_man/util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class ConfigController extends GetxController {
  switchStorageLocation() async {
    if (await requestStoragePermission()) {
      var db = Get.find<ConfigData>();
      String? path = await FilesystemPicker.open(
        title: 'Save to folder',
        context: Get.context!,
        rootDirectory: Directory("/sdcard/"),
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
      );
      if (path != null) {
        Get.defaultDialog(
            title: "Storage location changed",
            middleText: "Move database to new location?",
            onConfirm: () {
              _copyDatabase(
                      Directory(db.storageLocation.value), Directory(path))
                  .then((value) {
                db.setStorageLocation(path);
              });
            },
            onCancel: () {
              db.setStorageLocation(path);
            });
      }
    } else {
      Get.snackbar("Permission Limited", "Can not read local file!");
    }
  }

  Future _copyDatabase(Directory from, Directory target) async {
    if(from.path == target.path){
      // What???
      // Are you joking?
      return;
    }
    try {
      if (!from.existsSync()) {
        throw "$from must be existed!";
      }
      if (!target.existsSync()) {
        target.createSync(recursive: true);
      }

      File Function(Directory, String) relFile =
          (Directory parent, String fileName) {
        if (fileName.isEmpty) {
          throw "$fileName can not be empty";
        }
        var name;
        if (fileName.startsWith('/')) {
          name = basename(fileName);
        } else {
          name = fileName;
        }
        return File("${parent.path}/$name");
      };

      relFile(from, "meme.db").copySync(relFile(target, "meme.db").path);

      Directory("${from.path}/img")
          .listSync(recursive: true, followLinks: true)
          .map((e) => File(e.path))
          .forEach((element) {
        File targetFile = relFile(target, "img/" + basename(element.path));
        if (!targetFile.parent.existsSync()) {
          targetFile.parent.createSync(recursive: true);
        }
        element.copySync(targetFile.path);
      });
      Get.snackbar("Move database", "Succeed");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      throw e;
    }
  }
}
