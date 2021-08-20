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
                  delegate: _SearchBarDelegate(_waterfallBuilder));
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

class _SearchBarDelegate extends SearchDelegate<String> {
  late List<String> tags;
  late List<String> title;
  MemeData db = Get.find<MemeData>();
  final Widget Function(List<MemeModel>) _waterfallBuilder;

  _SearchBarDelegate(this._waterfallBuilder) {
    var items = db.data.cast<MemeModel>();
    tags = items.expand((element) => element.tags).toList(growable: false);
    title = items.map((e) => e.name).toList(growable: false);
    title.sort();
    tags.sort();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[IconButton(onPressed: () {}, icon: Icon(Icons.search))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, "");
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var inputs = query
        .split(" ")
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList(growable: false);
    List<MemeModel> result = List.empty(growable: true);
    ctrl:
    for (int i = 0; i < db.data.length; i++) {
      MemeModel e = db.data[i];
      for (int j = 0; j < inputs.length; j++) {
        if (!e.tags.contains(inputs[j]) &&
            !e.name.toLowerCase().contains(inputs[j].toLowerCase())) {
          continue ctrl;
        }
      }
      result.add(db.data[i]);
    }
    return _waterfallBuilder(result);
  }

  List<String> _analyseQuery(String text) {
    if (text.isEmpty) {
      var all = this.tags + this.title;
      all.sort();
      return all;
    }
    var allInput = text
        .split(" ")
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty);
    var input = allInput.last;
    var properTag =
        this.tags.where((element) => element.startsWith(input)).toList();
    var properName =
        this.title.where((element) => element.startsWith(input)).toList();
    var result = properTag + properName;

    if (result.contains(input)) {
      result = _analyseQuery("");
    }

    allInput.forEach((element) {
      if (result.contains(element)) {
        result.remove(element);
      }
    });

    return result;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Widget Function(Widget) wrap = (Widget w) => Padding(
          padding: EdgeInsets.all(10),
          child: w,
        );
    return wrap(Wrap(
      spacing: 8,
      children: _analyseQuery(query)
          .map((e) => GestureDetector(
                child: Chip(
                  label: Text(e),
                  deleteIcon: Icon(Icons.arrow_drop_up),
                  onDeleted: () {},
                ),
                onTap: () {
                  var allInput = query
                      .split(" ")
                      .map((e) => e.trim())
                      .where((element) => e.isNotEmpty)
                      .toList();
                  if (e.startsWith(allInput.last)) {
                    allInput[allInput.length - 1] = e;
                  } else {
                    allInput.add(e);
                  }
                  query =
                      allInput.reduce((value, element) => "$value $element");
                },
              ))
          .toList(growable: false),
    ));
  }
}
