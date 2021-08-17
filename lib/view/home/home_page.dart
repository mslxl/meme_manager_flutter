import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/view/add/add_page.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: Text("Meme Manager"),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            semanticLabel: "drawer",
          ),
          onPressed: () => {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              semanticLabel: "search",
            ),
            onPressed: () => {},
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: "search",
            ),
            onPressed: () => {},
          )
        ],
      ),
      body: WaterfallFlow.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(2),
        children: [MemeCard('name', [], "")],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Get.to(() => AddPage())},
        tooltip: 'Add new meme',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MemeCard extends StatelessWidget {
  MemeCard(this.name, this.tags, this.filePath);

  final String name;
  final List<String> tags;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text("Image"),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 7.0),
                Divider(height: 1.0),
                Text("Name"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        semanticLabel: "send",
                      ),
                      onPressed: () => {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        semanticLabel: "save",
                      ),
                      onPressed: () => {},
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
