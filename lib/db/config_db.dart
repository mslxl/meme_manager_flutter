import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigData extends GetxController {
  var _isInit = false;

  RxString storageLocation = RxString("");
  RxInt previewRowNumber = RxInt(2);
  RxBool isNoMedia = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    read();
  }

  Future<String> getStorageLocation() async {
    var prefs = await SharedPreferences.getInstance();
    storageLocation.value = prefs.getString("storage_location") ??
        (await getExternalStorageDirectory())!.path;
    return storageLocation.value;
  }

  read() async {
    if (_isInit) {
      return;
    }
    var prefs = await SharedPreferences.getInstance();
    storageLocation.value = prefs.getString("storage_location") ??
        (await getExternalStorageDirectory())!.path;
    previewRowNumber.value = prefs.getInt('row') ?? 2;
    setNoMediaStatus(prefs.getBool("nomedia") ?? false);
  }

  setNoMediaStatus(bool status) async {
    isNoMedia.value = status;
    var filePath = (await getStorageLocation()) + "/.nomedia";
    var file = File(filePath);
    if (status) {
      if (!file.existsSync()) {
        file.createSync();
      }
    } else {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  increaseRow() {
    if (previewRowNumber < 5) {
      previewRowNumber.value++;
      SharedPreferences.getInstance()
          .then((value) => value.setInt("row", previewRowNumber.value));
    }
  }

  decreaseRow() {
    if (previewRowNumber > 1) {
      previewRowNumber.value--;
      SharedPreferences.getInstance()
          .then((value) => value.setInt("row", previewRowNumber.value));
    }
  }

  setStorageLocation(String path) {
    storageLocation.value = path;
    SharedPreferences.getInstance()
        .then((value) => value.setString("storage_location", path));
  }
}
