import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_man/db/meme_db.dart';
import 'package:meme_man/model/MemeModel.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  late List<String> tags;
  late List<String> title;
  MemeData db = Get.find<MemeData>();
  final Widget Function(List<MemeModel>) _waterfallBuilder;

  SearchBarDelegate(this._waterfallBuilder) {
    var items = db.data.cast<MemeModel>();
    tags =
        items.expand((element) => element.tags).toSet().toList(growable: false);
    title = items.map((e) => e.name).toSet().toList(growable: false);
    title.sort();
    tags.sort();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[IconButton(onPressed: () {}, icon: Icon(Icons.search))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, "");
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var inputs = query
        .split(" ")
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList(growable: false);
    List<MemeModel> result = List.empty(growable: true);
    ctrl:
    for (int i = 0; i < db.data.length; i++) {
      MemeModel e = db.data[i];
      for (int j = 0; j < inputs.length; j++) {
        if (!isTextInList(inputs[j], e.tags) &&
            !e.name.toLowerCase().contains(inputs[j].toLowerCase())) {
          continue ctrl;
        }
      }
      result.add(db.data[i]);
    }
    return _waterfallBuilder(result);
  }

  bool isTextInList(String text, List<String> array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].toLowerCase().contains(text.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  List<String> _analyseQuery(String text) {
    if (text.isEmpty) {
      var all = this.tags + this.title;
      all.sort();
      return all;
    }
    var allInput = text
        .split(" ")
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty);
    var input = allInput.last;
    var properTag =
        this.tags.where((element) => element.startsWith(input)).toList();
    var properName =
        this.title.where((element) => element.startsWith(input)).toList();
    var result = properTag + properName;

    if (result.contains(input)) {
      result = _analyseQuery("");
    }

    allInput.forEach((element) {
      if (result.contains(element)) {
        result.remove(element);
      }
    });

    return result;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Widget Function(Widget) wrap = (Widget w) => Padding(
          padding: EdgeInsets.all(10),
          child: w,
        );
    return wrap(Wrap(
      spacing: 8,
      children: _analyseQuery(query)
          .map((e) => GestureDetector(
                child: Chip(
                  label: Text(e),
                  deleteIcon: Icon(Icons.arrow_drop_up),
                  onDeleted: () {},
                ),
                onTap: () {
                  var allInput = query
                      .split(" ")
                      .map((e) => e.trim())
                      .where((element) => e.isNotEmpty)
                      .toList();
                  if (e.startsWith(allInput.last)) {
                    allInput[allInput.length - 1] = e;
                  } else {
                    allInput.add(e);
                  }
                  query =
                      allInput.reduce((value, element) => "$value $element");
                },
              ))
          .toList(growable: false),
    ));
  }
}
