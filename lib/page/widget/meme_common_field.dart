import 'package:flutter/material.dart';
import 'package:mmm/page/widget/meme_tag_column.dart';
import 'package:mmm/util/database.dart';

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
          String? nspText;
          String? tagText;
          var formKey = GlobalKey<FormState>();

          return AlertDialog(
            title: Text(lang.editor.btn_add_tag),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    RawAutocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        nspText = textEditingValue.text;
                        return MemeDatabase()
                            .findNSPWithPrefix(textEditingValue.text);
                      },
                      fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) =>
                          TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onFieldSubmitted: (_) {
                          onFieldSubmitted();
                        },
                        decoration:
                            InputDecoration(hintText: lang.dialogTag.text_nsp),
                        validator: (text) {
                          if (text!.contains(":")) {
                            return lang.editor.field_col_tip;
                          }
                          return null;
                        },
                      ),
                      optionsViewBuilder: (context, onSelected, options) =>
                          Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(4.0)),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            width: (formKey.currentContext!.findRenderObject()
                                    as RenderBox)
                                .size
                                .width, // <-- Right here !
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              shrinkWrap: false,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    RawAutocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        tagText = textEditingValue.text;
                        if (nspText != null) {
                          return MemeDatabase().findTagWithNSPAndPrefix(
                              nspText!, textEditingValue.text);
                        } else {
                          return List.empty(growable: false);
                        }
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) {
                            onFieldSubmitted();
                          },
                          decoration: InputDecoration(
                              hintText: lang.dialogTag.text_tag),
                          validator: (text) {
                            if (text?.trim().isEmpty ?? true) {
                              return lang.editor.field_empty_tip;
                            }
                            if (text!.contains(":")) {
                              return lang.editor.field_col_tip;
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) =>
                          Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(4.0)),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            width: (formKey.currentContext!.findRenderObject()
                                    as RenderBox)
                                .size
                                .width, // <-- Right here !
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              shrinkWrap: false,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                    if (tagText!.trim().isEmpty) {
                      return;
                    }
                    if (formKey.currentState!.validate()) {
                      addTag(
                          nspText?.trim().isEmpty ?? true
                              ? "misc"
                              : nspText!.trim(),
                          tagText!.trim());
                      Navigator.pop(context);
                    }
                  },
                  child: Text(lang.dialogTag.btn_ok))
            ],
          );
        });
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
        MemeTagColumn(
          tags: widget.controller.tagMap,
          onDelete: removeTag,
        ),
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
              ),
            )
          ],
        )
      ],
    );
  }
}
