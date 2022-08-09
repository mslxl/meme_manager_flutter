import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/page/page_wrapper.dart';
import 'package:mmm/page/text_meme_editor.dart';
import 'package:mmm/page/widget/meme_control_pane.dart';
import 'package:mmm/page/widget/meme_tag_column.dart';
import 'package:mmm/util/database.dart';

import '../util/lang_builder.dart';

class MemePreviewPage extends StatefulWidget {
  final int memeId;

  const MemePreviewPage({Key? key, required this.memeId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MemePreviewPageState();
}

class MemePreviewPageState extends State<MemePreviewPage> {
  late Future<BasicMeme> meme;

  @override
  void initState() {
    super.initState();
    meme = MemeDatabase().getById(widget.memeId);
  }

  Widget buildMemeWidget(BuildContext context, BasicMeme meme) {
    if (meme is TextMeme) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                meme.text,
                maxLines: null,
              ),
            ),
          ),
          MemeControlPane(
            onCopy: () {
              Clipboard.setData(ClipboardData(text: meme.text)).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(LangBuilder.currentLang.preview
                        .text_copied(meme.name))));
              });
            },
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PageWrapper(
                    title: meme.name,
                    child: TextMemeEditor(
                      editTarget: meme,
                    ),
                  ),
                ),
              );
              setState(() {
                this.meme = MemeDatabase().getById(widget.memeId);
              });
            },
          )
        ],
      );
    } else {
      return const Text("TODO");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: meme,
        builder: (BuildContext context, AsyncSnapshot<BasicMeme> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            BasicMeme meme = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
                title: Text(meme.name),
              ),
              body: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  children: [
                    buildMemeWidget(context, meme),
                    const Divider(),
                    MemeTagColumn(tags: meme.tagsWithNSP)
                  ],
                ),
              ),
            );
          }
        });
  }
}
