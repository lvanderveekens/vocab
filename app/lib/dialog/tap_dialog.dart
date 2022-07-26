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
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _buildDialogHeader(),
          _buildDialogContentWrapper(),
        ]));

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

  Widget _buildDialogContentWrapper() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    if (widget.tappedOnWord == null) {
      return Text("No word found.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tapped on word:",
        ),
        Container(
            margin: EdgeInsets.only(top: 32.0, bottom: 32.0),
            child: Center(
                child: Text(widget.tappedOnWord!,
                    style: TextStyle(
                      fontSize: 24.0,
                    )))),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(16.0),
            // primary: Colors.black, //<-- SEE HERE
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Translate'),
                  Icon(
                    Icons.translate,
                    size: 16.0,
                  ),
                ],
              )),
          onPressed: () {
            log("Pressed on translate");
          },
        ),
      ],
    );
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
