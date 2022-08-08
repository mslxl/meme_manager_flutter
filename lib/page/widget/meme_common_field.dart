import 'dart:io';

import 'package:flutter/material.dart';

import '../../messages/mlang.i18n.dart';
import '../../util/lang_builder.dart';

class MemeCommonFieldController {
  TextEditingController nameController = TextEditingController();
  Map<String, List<String>> tagMap = {};

  List<String> get tag {
    List<String> res = [];
    for (var e in tagMap.entries) {
      for (var v in e.value) {
        res.add("${e.key}:$v");
      }
    }
    return res;
  }
}

class MemeCommonField extends StatefulWidget {
  final MemeCommonFieldController controller;

  const MemeCommonField({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemeCommonFieldState();
}

class _MemeCommonFieldState extends State<MemeCommonField> {
  Mlang lang = LangBuilder.currentLang;

  void addTag(String nsp, String tag) {
    setState(() {
      if (!widget.controller.tagMap.containsKey(nsp)) {
        widget.controller.tagMap[nsp] = [tag];
      } else {
        widget.controller.tagMap[nsp]!.add(tag);
      }
    });
  }

  void removeTag(String nsp, String tag) {
    setState(() {
      if (widget.controller.tagMap.containsKey(nsp)) {
        widget.controller.tagMap[nsp]!.remove(tag);
        if (widget.controller.tagMap[nsp]!.isEmpty) {
          widget.controller.tagMap.remove(nsp);
        }
      }
    });
  }

  void showAddTagPopup() {
    showDialog(
        context: context,
        builder: (_) {
          var nspController = TextEditingController();
          var tagController = TextEditingController();
          var formKey = GlobalKey<FormState>();
          return AlertDialog(
            title: Text(lang.editor.btn_add_tag),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nspController,
                      decoration:
                          InputDecoration(hintText: lang.dialogTag.text_nsp),
                      validator: (text) {
                        if (text!.contains(":")) {
                          return "Cannot contains ':'";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: tagController,
                      decoration:
                          InputDecoration(hintText: lang.dialogTag.text_tag),
                      validator: (text) {
                        if (text?.trim().isEmpty ?? true) {
                          return "Cannot be empty";
                        }
                        if (text!.contains(":")) {
                          return "Cannot contains ':'";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
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
                    if (formKey.currentState!.validate()) {
                      addTag(
                          nspController.text.trim().isEmpty
                              ? "misc"
                              : nspController.text.trim(),
                          tagController.text.trim());
                      Navigator.pop(context);
                    }
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
        children: widget.controller.tagMap.keys
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
                          children: widget.controller.tagMap[key]!
                              .map((tag) => Chip(
                                  backgroundColor: Colors.blue,
                                  label: Text(
                                    tag,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  deleteIconColor: Colors.white,
                                  onDeleted: () {
                                    removeTag(key, tag);
                                  }))
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
          controller: widget.controller.nameController,
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
