import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/db/config_db.dart';

import 'config_controller.dart';

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var configController = Get.find<ConfigData>();
    var controller = Get.put(ConfigController());
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text("Image row"),
                ),
                TextButton(
                    onPressed: configController.decreaseRow, child: Text("-")),
                Obx(() =>
                    Text(configController.previewRowNumber.value.toString())),
                TextButton(
                    onPressed: configController.increaseRow, child: Text("+"))
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Row(
              children: [
                Expanded(child: Text("Add .nomedia file")),
                Obx(() => Switch(
                    value: configController.isNoMedia.value,
                    onChanged: (v) {
                      configController.setNoMediaStatus(v);
                    }))
              ],
            ),
          ),
          ListTile(
            title: Text("Storage location"),
            subtitle: Obx(() => Text(configController.storageLocation.value)),
            onTap: controller.switchStorageLocation,
          ),
        ],
      ),
    );
  }
}
