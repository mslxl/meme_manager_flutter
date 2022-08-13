import 'package:flutter/material.dart';
import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/page/meme_editor_page.dart';
import 'package:mmm/page/preference_page.dart';
import 'package:mmm/page/widget/meme_card.dart';
import 'package:mmm/util/lang_builder.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../util/conf.dart';
import '../util/database.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.cfg}) : super(key: key);
  final Config cfg;
  final Mlang lang = LangBuilder.currentLang;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<int>? memeCount;
  MemeDatabase dbHelper = MemeDatabase();

  @override
  void initState() {
    super.initState();
    memeCount = dbHelper.count();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang.home.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
            future: memeCount,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return WaterfallFlow.builder(
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.cfg.homeRow,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: snapshot.data!,
                    itemBuilder: (BuildContext context, int itemIndex) {
                      return MemeCard(meme: dbHelper.atDesc(itemIndex));
                    });
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: null,
          ),
          ListTile(
            title: Text(widget.lang.home.nav_preference),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => PreferencePage()));
            },
          ),
          const Divider()
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => const MemeEditorPage()));
          setState(() {
            memeCount = dbHelper.count();
          });
        },
        label: Text(widget.lang.home.btn_add),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
