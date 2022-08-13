import 'package:flutter/material.dart';

import '../messages/mlang.i18n.dart';
import '../util/lang_builder.dart';
import 'img_meme_editor.dart';
import 'text_meme_editor.dart';

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
              children: [TextMemeEditor(), ImgMemeEditor()],
            ),
          ),
        ));
  }
}
