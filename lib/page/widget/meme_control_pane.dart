import 'package:flutter/material.dart';

class MemeControlPane extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;

  const MemeControlPane({Key? key, this.onEdit, this.onCopy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var btns = <Widget>[];
    if (onCopy != null) {
      btns.add(IconButton(onPressed: onCopy, icon: const Icon(Icons.copy)));
    }
    if (onEdit != null) {
      btns.add(IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)));
    }
    return Transform.scale(
      scale: 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: btns,
      ),
    );
  }
}
