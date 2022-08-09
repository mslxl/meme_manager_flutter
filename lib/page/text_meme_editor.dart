import 'package:flutter/material.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/page/widget/meme_common_field.dart';
import 'package:mmm/util/database.dart';

import '../messages/mlang.i18n.dart';
import '../util/lang_builder.dart';

class TextMemeEditor extends StatefulWidget {
  final TextMeme? editTarget;

  const TextMemeEditor({Key? key, this.editTarget}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextMemeEditorState();
}

class _TextMemeEditorState extends State<TextMemeEditor> {
  TextEditingController textController = TextEditingController();
  Mlang lang = LangBuilder.currentLang;
  MemeCommonFieldController commonFieldController = MemeCommonFieldController();

  @override
  void initState() {
    super.initState();
    if (widget.editTarget != null) {
      setState(() {
        textController.text = widget.editTarget!.text;
        commonFieldController.tagMap = widget.editTarget!.tagsWithNSP;
        commonFieldController.nameController.text = widget.editTarget!.name;
      });
    }
  }

  void addMeme(BuildContext ctx) async {
    if (textController.text.trim().isEmpty) return;

    TextMeme meme = TextMeme(
        id: widget.editTarget == null ? -1 : widget.editTarget!.id,
        name: commonFieldController.nameController.text,
        tags: commonFieldController.tag);
    meme.text = textController.text;

    MemeDatabase().addMeme(meme, updateIfExists: true);

    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          decoration: InputDecoration(
              labelText: lang.editor.text_content,
              hintText: lang.editor.text_content_tip,
              prefixIcon: const Icon(Icons.short_text)),
          controller: textController,
          maxLines: null,
          autofocus: true,
        ),
        MemeCommonField(
          controller: commonFieldController,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
              onPressed: () {
                addMeme(context);
              },
              child: Text(widget.editTarget == null
                  ? lang.editor.ok
                  : lang.editor.ok_edit)),
        )
      ],
    );
  }
}
