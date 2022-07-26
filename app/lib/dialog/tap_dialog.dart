import 'dart:developer';

import 'package:flutter/material.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final String? tappedOnWord;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.tappedOnWord,
  }) : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: _buildDialogChild(),
    );
  }

  Widget _buildDialogChild() {
    String dialogText =
        widget.tappedOnWord != null ? widget.tappedOnWord! : 'No word found...';

    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildDialogHeader(), _buildDialogContent(dialogText)]));

    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text('${widget.tappedOnWord}'),
    //     // TextButton(
    //     //     onPressed: () {
    //     //       widget.wordStorage.save("$tappedText->$translation");
    //     //     },
    //     //     child: const Text("Add to list"))
    //   ],
    // );
  }

  Widget _buildDialogContent(String text) {
    return Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 32), child: Text(text));
  }

  Widget _buildDialogHeader() {
    return Row(children: [
      Expanded(child: Container()),
      Text("Tap", style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      }))))
    ]);
  }

  // // TODO: move translation
  // String? translation;
  // final recognizedLanguages = block.recognizedLanguages;

  // if (_translateEnabled && recognizedLanguages.isNotEmpty) {
  //   final recognizedLanguage = recognizedLanguages[0];
  //   if (recognizedLanguage != "en") {
  //     log("Translating...");
  //     translation =
  //         await translate(tappedOnText, recognizedLanguage, "en");

  //     log("Translation: $translation");
  //   }
  // }
}
