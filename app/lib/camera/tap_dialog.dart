import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_client.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_languages.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';
import 'package:vocab/translation/google_cloud_translation_dtos.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback onClose;
  final String? tappedOnWord;
  final bool translationEnabled;
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;
  final List<GoogleCloudTranslationLanguage> translationLanguages;
  final List<GoogleCloudTextToSpeechLanguage> textToSpeechLanguages;
  final UserPreferences? userPreferences;
  final GoogleCloudTranslationClient googleCloudTranslationClient;
  final GoogleCloudTextToSpeechClient googleCloudTextToSpeechClient;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.tappedOnWord,
    required this.translationEnabled,
    required this.deckStorage,
    required this.userPreferencesStorage,
    required this.translationLanguages,
    required this.textToSpeechLanguages,
    required this.userPreferences,
    required this.googleCloudTranslationClient,
    required this.googleCloudTextToSpeechClient,
  }) : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  GoogleCloudTranslationLanguage? _translationSourceLanguage;
  GoogleCloudTranslationLanguage? _translationTargetLanguage;

  String? _translation;

  @override
  Widget build(BuildContext context) {
    log("@>TapDialogState#build (widget.userPreferences=${widget.userPreferences})");

    if (widget.userPreferences != null &&
        _translationSourceLanguage == null &&
        _translationTargetLanguage == null) {
      log("setting source and target languages");
      setState(() {
        _translationSourceLanguage = getGoogleTranslationLanguageByCode(
            widget.userPreferences!.sourceLanguageCode);
        _translationTargetLanguage = getGoogleTranslationLanguageByCode(
            widget.userPreferences!.targetLanguageCode);
      });

      // TODO: this translate will set _translation and trigger a new build() resulting in a cycle.
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

    var oldSourceLanguage = _translationSourceLanguage;

    setState(() {
      _translationSourceLanguage = newSourceLanguage;
      if (_translationTargetLanguage == newSourceLanguage) {
        _translationTargetLanguage = oldSourceLanguage;
      }
    });
    _saveLanguagesInUserPreferences();
    _translate();
  }

  void _setTranslatePageTargetLanguage(
      GoogleCloudTranslationLanguage newTargetLanguage) {
    log("@>_setTranslatePageTargetLanguage");

    var oldTargetLanguage = _translationTargetLanguage;

    setState(() {
      _translationTargetLanguage = newTargetLanguage;
      if (_translationSourceLanguage == newTargetLanguage) {
        _translationSourceLanguage = oldTargetLanguage;
      }
    });

    _saveLanguagesInUserPreferences();
    _translate();
  }

  GoogleCloudTranslationLanguage getGoogleTranslationLanguageByCode(
      String code) {
    return widget.translationLanguages.firstWhere((gtl) {
      return gtl.language.hasCode(code);
    });
  }

  void _saveLanguagesInUserPreferences() {
    if (widget.userPreferences != null) {
      widget.userPreferences!.sourceLanguageCode =
          _translationSourceLanguage!.code;
      widget.userPreferences!.targetLanguageCode =
          _translationTargetLanguage!.code;
      widget.userPreferencesStorage.save(widget.userPreferences!);
    }
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
                      child: _translationSourceLanguage != null
                          ? DropdownButton(
                              underline: Container(),
                              iconSize: 0.0,
                              isDense: true,
                              isExpanded: true,
                              value: _translationSourceLanguage,
                              items: widget.translationLanguages
                                  .map((GoogleCloudTranslationLanguage gtl) {
                                return DropdownMenuItem(
                                  value: gtl,
                                  child: Text(
                                    gtl.language.name,
                                    style: TextStyle(
                                        color: gtl == _translationSourceLanguage
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
                                return widget.translationLanguages.map((gtl) {
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
                          _translationSourceLanguage;

                      _translationSourceLanguage = _translationTargetLanguage;
                      _translationTargetLanguage =
                          oldTranslatePageSourceLanguage;
                    });
                    _saveLanguagesInUserPreferences();
                    _translate();
                  },
                ),
                Expanded(
                  child: Center(
                      child: _translationTargetLanguage != null
                          ? DropdownButton(
                              underline: Container(),
                              iconSize: 0.0,
                              isDense: true,
                              isExpanded: true,
                              value: _translationTargetLanguage,
                              items: widget.translationLanguages
                                  .map((GoogleCloudTranslationLanguage gtl) {
                                return DropdownMenuItem(
                                  value: gtl,
                                  child: Text(
                                    gtl.language.name,
                                    style: TextStyle(
                                        color: gtl == _translationTargetLanguage
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
                                return widget.translationLanguages.map((gtl) {
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
                          log("Pressed on speaker icon");

                          GoogleCloudTextToSpeechLanguage?
                              textToSpeechLanguage = widget
                                  .textToSpeechLanguages
                                  .firstWhereOrNull((ttsl) =>
                                      ttsl.language.name ==
                                      _translationSourceLanguage!
                                          .language.name);

                          if (textToSpeechLanguage != null) {
                            widget.googleCloudTextToSpeechClient
                                .synthesize(
                              widget.tappedOnWord!,
                              textToSpeechLanguage.code,
                            )
                                .then((base64String) {
                              log("base64 encoded" + base64String);

                              // TODO: clean up after playing

                              getTemporaryDirectory().then((dir) {
                                var filePath =
                                    '${dir.path}/${widget.tappedOnWord}_${textToSpeechLanguage.code}.mp3';
                                var file = File(filePath);

                                var decoded = base64.decode(base64String);
                                log("Decoded: " + decoded.toString());

                                file.writeAsBytes(decoded).then((value) {
                                  log("written to file: $filePath");
                                  final player = AudioPlayer();

                                  // Cannot use BytesSource. It only works on Android...
                                  player
                                      .play(DeviceFileSource(filePath))
                                      .whenComplete(() {
                                    log("Deleting temp file again");
                                    file.deleteSync();
                                  });
                                });
                              });
                            });
                          }
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
                    sourceLanguageCode: _translationSourceLanguage!.code,
                    sourceWord: widget.tappedOnWord!,
                    targetLanguageCode: _translationTargetLanguage!.code,
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
    if (_translationSourceLanguage == null ||
        _translationTargetLanguage == null) {
      return;
    }

    log("Translating...");

    String? translation = await widget.googleCloudTranslationClient.translate(
      widget.tappedOnWord!,
      _translationSourceLanguage!.code,
      _translationTargetLanguage!.code,
    );
    log("Translation: $translation");
    setState(() {
      _translation = translation;
    });
  }
}
