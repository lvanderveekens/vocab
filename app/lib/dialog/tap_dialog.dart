import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';

import '../storage/word_storage.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback onClose;
  final String? tappedOnWord;
  final WordStorage wordStorage;
  final List<Language> supportedLanguages;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.tappedOnWord,
    required this.wordStorage,
    required this.supportedLanguages,
  }) : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  bool _showTranslateDialogPage = false;
  bool _showChangeLanguageDialogPage = false;

  Language originalLanguage = Languages.english;
  Language translationLanguage = Languages.russian;
  String? _translation = "monkey";

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (_showTranslateDialogPage)
                if (_showChangeLanguageDialogPage)
                  ..._buildChangeLanguageDialogPage()
                else
                  ..._buildTranslateDialogPage()
              else
                ..._buildTapDialogPage()
            ])));
  }

  List<Widget> _buildTapDialogPage() {
    return [
      _buildDialogHeader(title: "Tap"),
      _buildDialogContentWrapper(child: _buildTapDialogPageContent())
    ];
  }

  List<Widget> _buildTranslateDialogPage() {
    return [
      _buildDialogHeader(
          title: "Translate",
          onBack: () {
            setState(() {
              this._showTranslateDialogPage = false;
            });
          }),
      _buildDialogContentWrapper(child: _buildTranslateDialogPageContent())
    ];
  }

  List<Widget> _buildChangeLanguageDialogPage() {
    return [
      _buildDialogHeader(
          title: "Change language",
          onBack: () {
            setState(() {
              this._showChangeLanguageDialogPage = false;
            });
          }),
      _buildDialogContentWrapper(child: _buildChangeLanguageDialogPageContent())
    ];
  }

  Widget _buildChangeLanguageDialogPageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Original"),
              DropdownButton(
                value: originalLanguage,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: widget.supportedLanguages.map((Language language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language.name),
                  );
                }).toList(),
                onChanged: (Language? newValue) {
                  setState(() {
                    originalLanguage = newValue!;
                  });
                },
              )
            ])),
        Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Translation"),
            DropdownButton(
              value: translationLanguage,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: widget.supportedLanguages.map((Language language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language.name),
                );
              }).toList(),
              onChanged: (Language? newValue) {
                setState(() {
                  translationLanguage = newValue!;
                });
              },
            ),
          ],
        ))
      ],
    );
  }

  Widget _buildDialogContentWrapper({required Widget child}) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: child,
    );
  }

  Widget _buildTranslateDialogPageContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 32.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: where to get source language from?
                    Text(this.originalLanguage.name,
                        style: TextStyle(fontSize: 10.0)),
                    Text('${widget.tappedOnWord}',
                        style: TextStyle(fontSize: 24.0)),
                  ])),
          Divider(
            color: Colors.black,
            height: 1.0,
            thickness: 1.0,
          ),
          Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: where to get target language from?
                    Text(this.translationLanguage.name,
                        style: TextStyle(fontSize: 10.0)),
                    // TODO: translation
                    Text(_translation != null ? _translation! : "",
                        style: TextStyle(fontSize: 24.0)),
                  ])),
        ]),
      ),
      Container(
          margin: EdgeInsets.only(bottom: 8.0),
          child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                // side: BorderSide(color: Colors.black),
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
                      const Text('Add to list'),
                      const Icon(Icons.list, size: 24.0),
                    ],
                  )),
              onPressed: _translation != null
                  ? () {
                      log("Pressed on 'Add to list'");
                      widget.wordStorage
                          .save("${widget.tappedOnWord}->${_translation!}");
                      widget.onClose();

                      const snackBar = SnackBar(content: Text('Added to list'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  : null)),
      Container(
          child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16.0),
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
                const Text('Change language'),
                const Icon(Icons.language, size: 24.0),
              ],
            )),
        onPressed: () {
          log("Pressed on 'Change language'");
          setState(() {
            this._showChangeLanguageDialogPage = true;
          });
        },
      )),
    ]);
  }

  Widget _buildTapDialogPageContent() {
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
                  const Text('Translate'),
                  const Icon(Icons.translate, size: 24.0),
                ],
              )),
          onPressed: () {
            log("Pressed on translate");
            setState(() {
              this._showTranslateDialogPage = true;
            });
          },
        ),
      ],
    );
  }

  // TODO: convert to separate widget with properties
  Widget _buildDialogHeader({required String title, VoidCallback? onBack}) {
    return Row(children: [
      Expanded(
          child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: onBack == null
                    ? Container()
                    : IconButton(
                        icon: Icon(Icons.arrow_back), onPressed: onBack),
              ))),
      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        if (widget.onClose != null) {
                          widget.onClose();
                        }
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
