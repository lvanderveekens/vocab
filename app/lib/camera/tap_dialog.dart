import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';
import 'package:http/http.dart' as http;
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/translation/google_translation_response.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback onClose;
  final String? tappedOnWord;
  final List<Language> supportedLanguages;
  final bool translationEnabled;
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;

  const TapDialog(
      {Key? key,
      required this.onClose,
      required this.tappedOnWord,
      required this.supportedLanguages,
      required this.translationEnabled,
      required this.deckStorage,
      required this.userPreferencesStorage})
      : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  ValueNotifier<bool> _showTranslateDialogPage = ValueNotifier(false);
  bool _showChangeLanguageDialogPage = false;

  // TODO: get from stored location (last used source language)
  // TODO: update language

  final ValueNotifier<Language> _sourceLanguage =
      ValueNotifier(Languages.italian);
  final ValueNotifier<Language> _targetLanguage =
      ValueNotifier(Languages.english);
  String? _translation;

  UserPreferences? _userPreferences;

  @override
  initState() {
    super.initState();

    log("Loading user preferences...");
    widget.userPreferencesStorage.get().then((value) {
      _userPreferences = value;

      if (value.sourceLanguage != null) {
        setState(() {
          _sourceLanguage.value = value.sourceLanguage!;
        });
      }
      if (value.targetLanguage != null) {
        setState(() {
          _targetLanguage.value = value.targetLanguage!;
        });
      }

      log("Adding listeners...");
      _showTranslateDialogPage.addListener(() => _translate());
      _sourceLanguage.addListener(onSourceLanguageChanged);
      _targetLanguage.addListener(onTargetLanguageChanged);
    });
  }

  void onSourceLanguageChanged() {
    _translate();
    if (_userPreferences != null) {
      _userPreferences!.sourceLanguage = _sourceLanguage.value;
      widget.userPreferencesStorage.save(_userPreferences!);
    }
  }

  void onTargetLanguageChanged() {
    _translate();
    if (_userPreferences != null) {
      _userPreferences!.targetLanguage = _targetLanguage.value;
      widget.userPreferencesStorage.save(_userPreferences!);
    }
  }

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
              if (_showTranslateDialogPage.value)
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
    log("@>_buildTranslateDialogPage");

    // TODO: if source or target language changed
    // if (widget.translationEnabled) {
    //   _translate();
    // }
    return [
      _buildDialogHeader(
          title: "Translate",
          onBack: () {
            setState(() {
              this._showTranslateDialogPage.value = false;
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
                value: _sourceLanguage.value,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: widget.supportedLanguages.map((Language language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language.name),
                  );
                }).toList(),
                onChanged: (Language? newValue) {
                  setState(() {
                    _sourceLanguage.value = newValue!;
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
              value: _targetLanguage.value,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: widget.supportedLanguages.map((Language language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language.name),
                );
              }).toList(),
              onChanged: (Language? newValue) {
                setState(() {
                  _targetLanguage.value = newValue!;
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
    // TODO: right place?
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
                    Text(this._sourceLanguage.value.name,
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
                    Text(this._targetLanguage.value.name,
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
                      const Text('Add to deck'),
                      const Icon(Icons.list, size: 24.0),
                    ],
                  )),
              onPressed: _translation != null
                  ? () async {
                      log("Pressed on 'Add to deck'");

                      await widget.deckStorage.get().then((deck) {
                        deck.cards.add(Flashcard(
                          sourceLanguage: _sourceLanguage.value,
                          sourceWord: widget.tappedOnWord!,
                          targetLanguage: _targetLanguage.value,
                          targetWord: _translation!,
                        ));

                        return widget.deckStorage.save(deck);
                      });

                      widget.onClose();

                      const snackBar = SnackBar(content: Text('Added to deck'));
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
              this._showTranslateDialogPage.value = true;
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

  void _translate() async {
    if (!widget.translationEnabled) {
      return;
    }
    log("Translating...");
    String? translation = await googleTranslate(widget.tappedOnWord!,
        _sourceLanguage.value.isoCode, _targetLanguage.value.isoCode);
    log("Translation: $translation");
    setState(() {
      _translation = translation;
    });
  }

  Future<String> googleTranslate(
      String text, String sourceCode, String targetCode) async {
    final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2')
            .replace(queryParameters: {
      'q': text,
      'source': sourceCode,
      'target': targetCode,
      'key': (await SecretsLoader().load()).apiKey,
    }));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to call Google Cloud Translation API: ${response.body}');
    }

    final googleTranslationResponse =
        GoogleTranslationResponse.fromJson(jsonDecode(response.body));

    return googleTranslationResponse.data.translations[0].translatedText;
  }
}
