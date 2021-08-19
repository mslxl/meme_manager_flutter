import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:meme_man/db/meme_db.dart';
import 'package:permission_handler/permission_handler.dart';

class AddController extends GetxController {
  var imagePath = "".obs;
  var tags = List.empty(growable: true).obs;
  TextEditingController controllerName = new TextEditingController();

  selectImage() async {
    if (await Permission.storage.request().isGranted) {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        imagePath.value = file.path;
      }
    } else {
      Get.snackbar("Permission Limited", "Can not read local file!");
    }
  }

  addTag() {
    var textController = TextEditingController();
    Get.defaultDialog(
      title: "New tag",
      content: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: TextField(
          decoration: InputDecoration(labelText: "Tag"),
          controller: textController,
        ),
      ),
      onConfirm: () {
        if (textController.text.isNotEmpty) {
          var newTags = textController.text
              .split(",")
              .expand((element) => element.split("，"))
              .where((element) => !tags.contains(element));
          tags.addAll(newTags);
          Get.back();
        } else {
          Get.snackbar("Error", "New tag can not be empty!");
        }
      },
    );
  }

  addMeme() async {
    var memeController = Get.find<MemeData>();
    var model = MemeModel(controllerName.text, tags.cast(), imagePath.value);
    memeController.add(model);
    Get.back();
  }
}
