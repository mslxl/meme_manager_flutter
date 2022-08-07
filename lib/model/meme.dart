import 'dart:convert';

abstract class BasicMeme {
  final int id;
  String name;
  List<String> tags;

  BasicMeme({
    required this.id,
    required this.name,
    required this.tags,
  });

  String dumpAddition();

  String getType();

  bool isType(String d) {
    return getType() == d;
  }

  void loadAddition(String data);
}

class TextMeme extends BasicMeme {
  String text;

  TextMeme(
      {required super.id,
      required super.name,
      required super.tags,
      required this.text});

  @override
  String dumpAddition() {
    return text;
  }

  @override
  void loadAddition(String data) {
    text = data;
  }

  @override
  String getType() {
    return "text";
  }
}

class ImageMeme extends BasicMeme {
  String imgPath;

  ImageMeme(
      {required super.id,
      required super.name,
      required super.tags,
      required this.imgPath});

  @override
  String dumpAddition() {
    return imgPath;
  }

  @override
  void loadAddition(String data) {
    imgPath = data;
  }

  @override
  String getType() {
    return "image";
  }
}

class TextLabel {
  final int x;
  final int y;
  final int width;
  final int height;
  final int color;

  TextLabel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });
}

class ImageTemplateMeme extends ImageMeme {
  List<TextLabel> blank;

  ImageTemplateMeme(
      {required super.id,
      required super.name,
      required super.tags,
      required super.imgPath,
      required this.blank});

  @override
  String dumpAddition() {
    return json.encode({"blank": blank, "image": super.imgPath});
  }

  @override
  void loadAddition(String data) {
    Map<String, dynamic> map = json.decode(data);
    blank = map["black"];
    super.imgPath = map["image"];
  }

  @override
  String getType() {
    return "template";
  }
}
