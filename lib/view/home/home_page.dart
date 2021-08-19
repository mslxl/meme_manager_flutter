import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:meme_man/view/add/add_page.dart';
import 'package:meme_man/db/config_db.dart';
import 'package:meme_man/view/config/config_page.dart';
import 'package:meme_man/db/meme_db.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final dbController = Get.put(MemeData());
    final prefController = Get.put(ConfigData());

    dbController.load();
    return Scaffold(
      appBar: AppBar(
        title: Text("Meme Manager"),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            semanticLabel: "drawer",
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              semanticLabel: "search",
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: "settings",
            ),
            onPressed: () => {Get.to(() => ConfigPage())},
          )
        ],
      ),
      body: Obx(() => WaterfallFlow.builder(
            padding: EdgeInsets.all(2),
            itemCount: dbController.data.length,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: prefController.previewRowNumber.value,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              MemeModel item = dbController.data[index];
              return _MemeCard(item);
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Get.to(() => AddPage())},
        tooltip: 'Add new meme',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _MemeCard extends StatelessWidget {
  _MemeCard(this.model);

  final MemeModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.file(
            File(model.path),
            fit: BoxFit.fill,
          ),
          Divider(height: 1.0),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 0.7,
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 5,
                    children: model.tags
                        .map((e) => Chip(
                              label: Text(e),
                            ))
                        .toList(growable: false),
                  ),
                ),
                Text(model.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        semanticLabel: "send",
                      ),
                      onPressed: () {
                        var ctrl = Get.find<HomeController>();
                        ctrl.shareMeme(model);
                      },
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      onSelected: (index){},
                      itemBuilder: (BuildContext ctx) {
                        HomeController homeCtrl = Get.find<HomeController>();
                        List<Widget> list = List.empty(growable: true);
                        list.addIf(
                            homeCtrl.appWechat.value,
                            IconButton(
                              onPressed: () {},
                              icon: Image.memory(homeCtrl.appIcons["wechat"]),
                            ));
                        list.addIf(
                            homeCtrl.appTim.value,
                            IconButton(
                              onPressed: () {
                                homeCtrl.sendToTim(model);
                              },
                              icon: Image.memory(homeCtrl.appIcons["tim"]),
                            ));
                        return list
                            .map((e) => PopupMenuItem(child: e))
                            .toList(growable: false);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
