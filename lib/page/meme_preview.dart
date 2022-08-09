import 'package:flutter/material.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/page/widget/meme_tag_column.dart';
import 'package:mmm/util/database.dart';

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
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
            meme.text,
            maxLines: null,
          ),
        ),
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
