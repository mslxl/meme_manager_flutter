import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/db/config_db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class ConfigController extends GetxController {
  switchStorageLocation() async {
    if (await Permission.storage.request().isGranted) {
      var db = Get.find<ConfigData>();
      String? path = await FilesystemPicker.open(
        title: 'Save to folder',
        context: Get.context!,
        rootDirectory: Directory("/sdcard/"),
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
      );
      if(path != null){
        db.storageLocation.value = path;
      }
    } else {
      Get.snackbar("Permission Limited", "Can not read local file!");
    }
  }
}
