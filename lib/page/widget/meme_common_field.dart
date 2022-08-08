import 'dart:io';

import 'package:flutter/material.dart';

import '../../messages/mlang.i18n.dart';
import '../../util/lang_builder.dart';

class MemeCommonField extends StatefulWidget {
  const MemeCommonField({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemeCommonFieldState();
}

class _MemeCommonFieldState extends State<MemeCommonField> {
  Mlang lang = LangBuilder.currentLang;
  TextEditingController nameController = TextEditingController();
  Map<String, List<String>> tags = {};

  void addTag(String nsp, String tag) {
    setState(() {
      if (!tags.containsKey(nsp)) {
        tags[nsp] = [tag];
      } else {
        tags[nsp]!.add(tag);
      }
    });
  }

  void showAddTagPopup() {
    showDialog(
        context: context,
        builder: (_) {
          var nspController = TextEditingController();
          var tagController = TextEditingController();
          return AlertDialog(
            title: Text(lang.editor.btn_add_tag),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nspController,
                    decoration:
                        InputDecoration(hintText: lang.dialogTag.text_nsp),
                  ),
                  TextFormField(
                    controller: tagController,
                    decoration:
                        InputDecoration(hintText: lang.dialogTag.text_tag),
                    validator: (text) {
                      if (text?.trim().isNotEmpty ?? false) {
                        return null;
                      } else {
                        return "Cannot be empty";
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang.dialogTag.btn_cancel)),
              TextButton(
                  onPressed: () {
                    if (tagController.text.trim().isEmpty) {
                      tagController.text = " ";
                      return;
                    }
                    addTag(
                        nspController.text.trim().isEmpty
                            ? "misc"
                            : nspController.text.trim(),
                        tagController.text.trim());
                    Navigator.pop(context);
                  },
                  child: Text(lang.dialogTag.btn_ok))
            ],
          );
        });
  }

  Widget buildTagsColumn(BuildContext content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: tags.keys
            .map((key) => Padding(
                  padding: Platform.isWindows
                      ? const EdgeInsets.fromLTRB(0, 3, 0, 3)
                      : EdgeInsets.zero,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Chip(
                          backgroundColor: Colors.deepPurpleAccent,
                          label: Text(
                            key,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Wrap(
                          spacing: 5,
                          runSpacing:
                              Platform.isWindows || Platform.isLinux ? 3 : 0,
                          children: tags[key]!
                              .map((tag) => Chip(
                                    backgroundColor: Colors.blue,
                                    label: Text(
                                      tag,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(growable: false),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: nameController,
          decoration: InputDecoration(
              labelText: lang.editor.text_name,
              hintText: lang.editor.text_name_tip,
              prefixIcon: const Icon(Icons.textsms)),
        ),
        buildTagsColumn(context),
        Row(
          children: [
            TextButton(
                onPressed: () {
                  showAddTagPopup();
                },
                child: Row(
                  children: [
                    const Icon(Icons.add),
                    Text(lang.editor.btn_add_tag),
                  ],
                ))
          ],
        )
      ],
    );
  }
}
