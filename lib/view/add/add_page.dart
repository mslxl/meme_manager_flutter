import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_man/view/add/add_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddController());
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {Get.back()},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: deviceSize.height / 5,
                  maxWidth: deviceSize.width,
                  minWidth: deviceSize.width),
              child: TextButton(
                  onPressed: controller.selectImage,
                  child: Obx(() {
                    var contentWidget;
                    if (controller.imagePath.string.isEmpty) {
                      contentWidget = Icon(Icons.add);
                    } else {
                      contentWidget = Image.file(
                        new File(controller.imagePath.string),
                        fit: BoxFit.fill,
                      );
                    }
                    return contentWidget;
                  })),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                  ),
                  Obx(
                    () => Wrap(
                      spacing: 5,
                      children: controller.tags
                              .map((e) => Chip(
                                    label: Text(e),
                                    onDeleted: () {
                                      if (controller.tags.contains(e)) {
                                        controller.tags.remove(e);
                                      } else {
                                        throw "No tags in controller";
                                      }
                                    },
                                  ))
                              .toList()
                              .cast<Widget>() +
                          <Widget>[
                            ElevatedButton(
                                onPressed: controller.addTag,
                                child: Text("Add new tag"))
                          ],
                    ),
                  ),
                  TextField(
                    controller: controller.controllerName,
                    decoration: InputDecoration(labelText: "Meme Name"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.assignment_turned_in),
        onPressed: controller.addMeme,
      ),
    );
  }
}
