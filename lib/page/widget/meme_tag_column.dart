import 'dart:io';

import 'package:flutter/material.dart';

typedef TagDeleteCallback = void Function(String nsp, String tag);

class MemeTagColumn extends StatefulWidget {
  final Map<String, List<String>> tags;
  final TagDeleteCallback? onDelete;

  const MemeTagColumn({Key? key, required this.tags, this.onDelete})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MemeTagColumnState();
}

class MemeTagColumnState extends State<MemeTagColumn> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: widget.tags.keys
            .map((key) => Padding(
                  padding: Platform.isWindows
                      ? const EdgeInsets.fromLTRB(0, 3, 0, 3)
                      : EdgeInsets.zero,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Chip(
                          backgroundColor: Colors.deepPurpleAccent,
                          label: Text(
                            key,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Wrap(
                          spacing: 5,
                          runSpacing:
                              Platform.isWindows || Platform.isLinux ? 3 : 0,
                          children: widget.tags[key]!
                              .map((tag) => Chip(
                                  backgroundColor: Colors.blue,
                                  label: Text(
                                    tag,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  deleteIconColor: Colors.white,
                                  onDeleted: widget.onDelete == null
                                      ? null
                                      : () {
                                          widget.onDelete!(key, tag);
                                        }))
                              .toList(growable: false),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
