import 'package:flutter/material.dart';

import '../messages/mlang.i18n.dart';
import '../util/lang_builder.dart';

class MemeEditorPage extends StatefulWidget {
  final Mlang lang = LangBuilder.currentLang;

  @override
  State<StatefulWidget> createState() => _MemeEditorPageState();
}

class _MemeEditorPageState extends State<MemeEditorPage> {
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
            title: Text(widget.lang.editor.title),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined),
                tooltip: widget.lang.editor.cancel,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
                tooltip: widget.lang.editor.ok,
              )
            ],
            bottom: TabBar(tabs: [
              Tab(
                  icon: const Icon(Icons.text_format),
                  text: widget.lang.editor.type_text),
              Tab(icon: const Icon(Icons.image), text: widget.lang.editor.type_image)
            ]),
          ),
          body: const TabBarView(
            children: [Text("1"), Text("2")],
          ),
        ));
  }
}
