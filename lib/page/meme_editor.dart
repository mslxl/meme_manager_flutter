import 'package:flutter/material.dart';
import 'package:mmm/page/widget/meme_common_field.dart';

import '../messages/mlang.i18n.dart';
import '../util/lang_builder.dart';

class MemeEditorPage extends StatefulWidget {
  const MemeEditorPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemeEditorPageState();
}

class _MemeEditorPageState extends State<MemeEditorPage> {
  final Mlang lang = LangBuilder.currentLang;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(lang.editor.title),
            bottom: TabBar(tabs: [
              Tab(
                  icon: const Icon(Icons.text_format),
                  text: lang.editor.type_text),
              Tab(icon: const Icon(Icons.image), text: lang.editor.type_image)
            ]),
          ),
          body: Container(
            padding: const EdgeInsets.all(15),
            child: const TabBarView(
              children: [TextMemeEditor(), Text("2")],
            ),
          ),
        ));
  }
}

class TextMemeEditor extends StatefulWidget {
  const TextMemeEditor({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextMemeEditorState();
}

class _TextMemeEditorState extends State<TextMemeEditor> {
  TextEditingController textController = TextEditingController();
  Mlang lang = LangBuilder.currentLang;

  void addMeme() {}

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
        const MemeCommonField(),
        Padding(
          padding: const EdgeInsets.all(10),
          child:
              ElevatedButton(onPressed: addMeme, child: Text(lang.editor.ok)),
        )
      ],
    );
  }
}
