import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/util/conf.dart';
import 'package:mmm/util/lang_builder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'page/homepage.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Config> initConf() async {
    Config cfg = await Config.getInstance();
    LangBuilder.setLang(cfg.lang);
    return cfg;
  }

  @override
  Widget build(BuildContext context) {
    Mlang lang = const Mlang();
    return FutureBuilder(
      future: initConf(),
      builder: (BuildContext context, AsyncSnapshot<Config> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: lang.home.title,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MyHomePage(
              cfg: snapshot.data!,
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },);
  }
}
