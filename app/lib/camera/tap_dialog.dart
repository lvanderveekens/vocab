import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';
import 'package:vocab/translation/google_cloud_translation_response.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback onClose;
  final String? tappedOnWord;
  final bool translationEnabled;
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;
  final List<GoogleCloudTranslationLanguage> googleTranslationLanguages;
  final UserPreferences? userPreferences;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.tappedOnWord,
    required this.translationEnabled,
    required this.deckStorage,
    required this.userPreferencesStorage,
    required this.googleTranslationLanguages,
    required this.userPreferences,
  }) : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  GoogleCloudTranslationLanguage? _translatePageSourceLanguage;
  GoogleCloudTranslationLanguage? _translatePageTargetLanguage;
  String? _translation;

  @override
  Widget build(BuildContext context) {
    log("@>TapDialogState#build (widget.userPreferences=${widget.userPreferences})");

    if (widget.userPreferences != null) {
      log("setting source and target languages");
      setState(() {
        _translatePageSourceLanguage = getGoogleTranslationLanguageByCode(
            widget.userPreferences!.sourceLanguageCode);
        _translatePageTargetLanguage = getGoogleTranslationLanguageByCode(
            widget.userPreferences!.targetLanguageCode);
      });
      _translate();
    }

    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _buildTapDialogPageContent(),
            ])));
  }

  void _setTranslatePageSourceLanguage(
      GoogleCloudTranslationLanguage newSourceLanguage) {
    log("@>_setChangeLanguagePageSourceLanguage");

    var oldSourceLanguage = _translatePageSourceLanguage;

    setState(() {
      _translatePageSourceLanguage = newSourceLanguage;
      if (_translatePageTargetLanguage == newSourceLanguage) {
        _translatePageTargetLanguage = oldSourceLanguage;
      }
    });
    _saveLanguagesInUserPreferences();
  }

  void _setTranslatePageTargetLanguage(
      GoogleCloudTranslationLanguage newTargetLanguage) {
    log("@>_setTranslatePageTargetLanguage");

    var oldTargetLanguage = _translatePageTargetLanguage;

    setState(() {
      _translatePageTargetLanguage = newTargetLanguage;
      if (_translatePageSourceLanguage == newTargetLanguage) {
        _translatePageSourceLanguage = oldTargetLanguage;
      }
    });

    _saveLanguagesInUserPreferences();
  }

  GoogleCloudTranslationLanguage getGoogleTranslationLanguageByCode(
      String code) {
    return widget.googleTranslationLanguages.firstWhere((gtl) {
      return gtl.language.hasCode(code);
    });
  }

  void _saveLanguagesInUserPreferences() {
    if (widget.userPreferences != null) {
      widget.userPreferences!.sourceLanguageCode =
          _translatePageSourceLanguage!.code;
      widget.userPreferences!.targetLanguageCode =
          _translatePageTargetLanguage!.code;
      widget.userPreferencesStorage.save(widget.userPreferences!);
    }
  }

  Widget _buildDialogContentWrapper({required Widget child}) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      width: double.infinity,
      child: child,
    );
  }

  Widget _buildTapDialogPageContent() {
    if (widget.tappedOnWord == null) {
      return Text("No word found.");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                      child: _translatePageSourceLanguage != null
                          ? DropdownButton(
                              underline: Container(),
                              iconSize: 0.0,
                              isDense: true,
                              isExpanded: true,
                              value: _translatePageSourceLanguage,
                              items: widget.googleTranslationLanguages
                                  .map((GoogleCloudTranslationLanguage gtl) {
                                return DropdownMenuItem(
                                  value: gtl,
                                  child: Text(
                                    gtl.language.name,
                                    style: TextStyle(
                                        color:
                                            gtl == _translatePageSourceLanguage
                                                ? Color(0xFF00A3FF)
                                                : null),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  (GoogleCloudTranslationLanguage? newValue) {
                                _setTranslatePageSourceLanguage(newValue!);
                              },
                              selectedItemBuilder: (con) {
                                return widget.googleTranslationLanguages
                                    .map((gtl) {
                                  return Center(
                                      child: Text(
                                    gtl.language.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Color(0xFF00A3FF)),
                                  ));
                                }).toList();
                              })
                          : null),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.swap_horiz),
                  iconSize: 24.0,
                  onPressed: () async {
                    setState(() {
                      var oldTranslatePageSourceLanguage =
                          _translatePageSourceLanguage;

                      _translatePageSourceLanguage =
                          _translatePageTargetLanguage;
                      _translatePageTargetLanguage =
                          oldTranslatePageSourceLanguage;
                    });
                    _saveLanguagesInUserPreferences();
                  },
                ),
                Expanded(
                  child: Center(
                      child: _translatePageTargetLanguage != null
                          ? DropdownButton(
                              underline: Container(),
                              iconSize: 0.0,
                              isDense: true,
                              isExpanded: true,
                              value: _translatePageTargetLanguage,
                              items: widget.googleTranslationLanguages
                                  .map((GoogleCloudTranslationLanguage gtl) {
                                return DropdownMenuItem(
                                  value: gtl,
                                  child: Text(
                                    gtl.language.name,
                                    style: TextStyle(
                                        color:
                                            gtl == _translatePageTargetLanguage
                                                ? Color(0xFF00A3FF)
                                                : null),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  (GoogleCloudTranslationLanguage? newValue) {
                                _setTranslatePageTargetLanguage(newValue!);
                              },
                              selectedItemBuilder: (con) {
                                return widget.googleTranslationLanguages
                                    .map((gtl) {
                                  return Center(
                                      child: Text(
                                    gtl.language.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Color(0xFF00A3FF)),
                                  ));
                                }).toList();
                              })
                          : null),
                ),
              ],
            )),
        Container(
            padding: EdgeInsets.only(top: 32.0, bottom: 32.0),
            child: Column(children: [
              Container(
                  // margin: EdgeInsets.only(right: 24 + 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                  child: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.only(right: 4.0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.volume_up),
                        iconSize: 24.0,
                        onPressed: () async {
                          log("Pressed on icon");
                          final player = AudioPlayer();

                          // Cannot use BytesSource. It only works on Android...
                          await player.play(AssetSource("test.mp3"));
                        },
                      )),
                ),
                Container(
                    child: Text(
                  widget.tappedOnWord!,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                )),
                Expanded(child: Container())
              ])),
              const SizedBox(height: 16.0),
              Text(
                _translation ?? '',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              )
            ])),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(16.0),
            side: BorderSide.none,
            backgroundColor: const Color(0xFF00A3FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
          ),
          child: Container(
            width: double.infinity,
            child: Center(
                child: Text('Add to deck',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          onPressed: _translation != null
              ? () async {
                  Deck deck = await widget.deckStorage.get();

                  Flashcard addedCard = Flashcard(
                    id: const Uuid().v4(),
                    sourceLanguageCode: _translatePageSourceLanguage!.code,
                    sourceWord: widget.tappedOnWord!,
                    targetLanguageCode: _translatePageTargetLanguage!.code,
                    targetWord: _translation!,
                  );
                  deck.cards.add(addedCard);
                  widget.deckStorage.save(deck);

                  widget.onClose();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Added to deck'),
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () {
                          deck.cards.remove(addedCard);
                          widget.deckStorage.save(deck);
                        },
                      )));
                }
              : null,
        ),
      ],
    );
  }

  void _translate() async {
    log("@>translate()");
    if (!widget.translationEnabled) {
      setState(() {
        _translation = "<translation disabled>";
      });
      return;
    }
    if (_translatePageSourceLanguage == null ||
        _translatePageTargetLanguage == null) {
      return;
    }

    log("Translating...");
    String? translation = await googleTranslate(widget.tappedOnWord!,
        _translatePageSourceLanguage!.code, _translatePageTargetLanguage!.code);
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
        GoogleCloudTranslationResponse.fromJson(jsonDecode(response.body));

    return googleTranslationResponse.data.translations[0].translatedText;
  }
}
