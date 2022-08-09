import 'package:flutter/material.dart';
import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/util/conf.dart';
import 'package:file_picker/file_picker.dart';

import '../util/lang_builder.dart';

class PreferencePage extends StatefulWidget {
  final Mlang lang = LangBuilder.currentLang;

  PreferencePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  String storageFolder = "";

  void loadPreference() async {
    Config cfg = await Config.getInstance();
    setState(() {
      storageFolder = cfg.storageFolder;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPreference();
  }

  void setStorageFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      Config cfg = await Config.getInstance();
      cfg.setStorageFolder(selectedDirectory);
      setState(() {
        storageFolder = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.lang.preference.title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(widget.lang.preference.storage_location),
            subtitle: Text(storageFolder),
            onTap: setStorageFolder,
          )
        ],
      ),
    );
  }
}
