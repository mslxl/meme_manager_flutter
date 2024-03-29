import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/page/img_meme_editor.dart';
import 'package:mmm/page/meme_preview_page.dart';
import 'package:mmm/page/page_wrapper.dart';
import 'package:mmm/page/text_meme_editor.dart';
import 'package:mmm/page/widget/meme_control_pane.dart';
import 'package:mmm/util/database.dart';
import 'package:mmm/util/lang_builder.dart';

class MemeCard extends StatelessWidget {
  final Future<BasicMeme> meme;

  const MemeCard({Key? key, required this.meme}) : super(key: key);

  Widget buildWidget(BasicMeme meme) {
    if (meme is TextMeme) {
      return TextMemeCardContent(meme: meme);
    } else if (meme is ImageMeme) {
      return ImageMemeCardContent(meme: meme);
    } else {
      return const Text("TODO");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder(
        future: meme,
        builder: (BuildContext context, AsyncSnapshot<BasicMeme> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            BasicMeme meme = snapshot.data!;
            return buildWidget(meme);
          } else {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: 200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class TextMemeCardContent extends StatelessWidget {
  final TextMeme meme;

  const TextMemeCardContent({Key? key, required this.meme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          GestureDetector(
            child: Text(
              meme.text,
              maxLines: 5,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => MemePreviewPage(memeId: meme.id)));
            },
          ),
          const Divider(),
          Text(meme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          MemeControlPane(
            onCopy: () {
              Clipboard.setData(ClipboardData(text: meme.text)).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(LangBuilder.currentLang.preview
                        .text_copied(meme.name))));
              });
            },
            onEdit: () {
              Navigator.push(
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
            },
          )
        ],
      ),
    );
  }
}

class ImageMemeCardContent extends StatelessWidget {
  final ImageMeme meme;

  const ImageMemeCardContent({Key? key, required this.meme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          GestureDetector(
            child: FutureBuilder(
              future: MemeDatabase().md5NameToFile(meme.imgName),
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.file(snapshot.data!);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => MemePreviewPage(memeId: meme.id)));
            },
          ),
          const Divider(),
          Text(meme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          MemeControlPane(
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PageWrapper(
                    title: meme.name,
                    child: ImgMemeEditor(
                      editTarget: meme,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
