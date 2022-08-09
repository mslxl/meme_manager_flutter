import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mmm/model/meme.dart';
import 'package:mmm/page/widget/meme_common_field.dart';
import 'package:mmm/util/database.dart';
import 'package:mmm/util/lang_builder.dart';

import '../messages/mlang.i18n.dart';

class ImgMemeEditor extends StatefulWidget {
  final ImageMeme? editTarget;

  const ImgMemeEditor({Key? key, this.editTarget}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImgMemeEditorState();
}

class ImgMemeEditorState extends State<ImgMemeEditor> {
  File? imgFilePath;
  MemeCommonFieldController commonFieldController = MemeCommonFieldController();
  Mlang lang = LangBuilder.currentLang;

  void chooseImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ["png", "jpeg", "jpg"]);
    if (result != null) {
      setState(() {
        imgFilePath = File(result.files.single.path!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editTarget != null) {
      MemeDatabase().md5NameToFile(widget.editTarget!.imgName).then((path) {
        setState(() {
          imgFilePath = path;
          commonFieldController.tagMap = widget.editTarget!.tagsWithNSP;
          commonFieldController.nameController.text = widget.editTarget!.name;
        });
      });
    }
  }

  void addMeme(BuildContext ctx) async {
    MemeDatabase db = MemeDatabase();
    if (imgFilePath == null ||
        commonFieldController.nameController.text.trim().isEmpty) return;
    String imgPath = await db.addImage(imgFilePath!);
    ImageMeme meme = ImageMeme(
        id: widget.editTarget == null ? -1 : widget.editTarget!.id,
        name: commonFieldController.nameController.text.trim(),
        tags: commonFieldController.tag);
    meme.imgName = imgPath;
    db.addMeme(meme, updateIfExists: true);
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double minSize = min(screenSize.height, screenSize.width);
    return ListView(
      children: [
        GestureDetector(
            onTap: chooseImg,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: minSize * (2 / 3),
                maxWidth: minSize * (2 / 3),
              ),
              child: Card(
                child: imgFilePath == null
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(Icons.image),
                      )
                    : Image.file(imgFilePath!),
              ),
            )),
        const Divider(),
        MemeCommonField(controller: commonFieldController),
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
