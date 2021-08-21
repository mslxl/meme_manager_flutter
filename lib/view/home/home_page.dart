import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:meme_man/view/add/add_page.dart';
import 'package:meme_man/db/config_db.dart';
import 'package:meme_man/view/config/config_page.dart';
import 'package:meme_man/db/meme_db.dart';
import 'package:meme_man/view/home/search_bar_delegate.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  Widget _waterfallBuilder(List<MemeModel> data) {
    final prefController = Get.find<ConfigData>();
    return WaterfallFlow.builder(
      padding: EdgeInsets.all(2),
      itemCount: data.length,
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: prefController.previewRowNumber.value,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        MemeModel item = data[index];
        return _MemeCard(item);
      },
    );
  }

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
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchBarDelegate(_waterfallBuilder));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
            ),
            onPressed: () => {Get.to(() => ConfigPage())},
          )
        ],
      ),
      body: Obx(() => _waterfallBuilder(dbController.data.cast())),
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
                      onSelected: (index) {},
                      itemBuilder: (BuildContext ctx) {
                        HomeController homeCtrl = Get.find<HomeController>();
                        List<Widget> list = List.empty(growable: true);

                        void Function(bool, String) buildItem =
                            (bool isAdd, String app) {
                          if (isAdd) {
                            var item = IconButton(
                              onPressed: () {
                                homeCtrl.shareMemeTo(model, app);
                              },
                              icon: Image.memory(homeCtrl.appIcons[app]),
                            );
                            list.add(item);
                          }
                        };
                        buildItem(homeCtrl.appWechat.value, "wechat");

                        buildItem(homeCtrl.appQQ.value, "qq");

                        buildItem(homeCtrl.appTim.value, "tim");
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

