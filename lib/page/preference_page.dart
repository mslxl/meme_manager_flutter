import 'package:flutter/material.dart';
import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/util/conf.dart';
import 'package:file_picker/file_picker.dart';

import '../util/lang_builder.dart';

class PreferencePage extends StatefulWidget {
  PreferencePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  final Mlang lang = LangBuilder.currentLang;
  String storageFolder = "";
  double numberColumn = 2;

  void loadPreference() async {
    Config cfg = await Config.getInstance();
    setState(() {
      storageFolder = cfg.storageFolder;
      numberColumn = cfg.homeRow.toDouble();
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

  void setNumberColumn(double value) async {
    var cfg = await Config.getInstance();
    await cfg.setHomeRow(value.round());
    setState(() {
      numberColumn = value;
    });
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
        title: Text(lang.preference.title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              lang.preference.tip,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            leading: const Icon(Icons.warning),
          ),
          const Divider(),
          ListTile(
            title: Text(lang.preference.storage_location),
            subtitle: Text(storageFolder),
            onTap: setStorageFolder,
          ),
          const Divider(),
          ListTile(
            title: Text(lang.preference.number_colum),
            subtitle: Slider(
              value: numberColumn.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: numberColumn.round().toString(),
              onChanged: setNumberColumn,
            ),
          )
        ],
      ),
    );
  }
}
