import 'package:flutter/material.dart';
import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/page/meme_editor.dart';
import 'package:mmm/page/preference.dart';
import 'package:mmm/util/lang_builder.dart';

import '../util/database.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  final Mlang lang = LangBuilder.currentLang;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    MemeDatabase().withDB((p0) {});
  }

  @override
  Widget build(BuildContext context) {
    // MemeDatabase().withDB((p0) {
    //
    // });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang.home.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
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
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => MemeEditorPage()));
        },
        label: Text(widget.lang.home.btn_add),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
