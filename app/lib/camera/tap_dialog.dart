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
  final String originalText;
  final bool translationEnabled;
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;
  final List<GoogleCloudTranslationLanguage> translationLanguages;
  final List<GoogleCloudTextToSpeechLanguage> textToSpeechLanguages;
  final UserPreferences userPreferences;
  final GoogleCloudTranslationClient googleCloudTranslationClient;
  final GoogleCloudTextToSpeechClient googleCloudTextToSpeechClient;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.originalText,
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

  GoogleCloudTextToSpeechLanguage? _textToSpeechLanguage;

  String? _originalText;
  String? _translation;

  @override
  void initState() {
    super.initState();

    log("setting source and target languages");
    setState(() {
      _translationSourceLanguage = getGoogleTranslationLanguageByCode(
          widget.userPreferences.sourceLanguageCode);
      _translationTargetLanguage = getGoogleTranslationLanguageByCode(
          widget.userPreferences.targetLanguageCode);
    });
    _setTextToSpeechLanguage();

    _originalText = widget.originalText;
    _translate();
  }

  @override
  Widget build(BuildContext context) {
    log("@>TapDialogState#build (widget.userPreferences=${widget.userPreferences})");

    if (_originalText != widget.originalText) {
      _translate();
    }

    return Material(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _buildTapDialogPageContent(),
            ])));
  }

  void _setTranslateSourceLanguage(
      GoogleCloudTranslationLanguage newSourceLanguage) {
    log("@>_setTranslateSourceLanguage");

    var oldSourceLanguage = _translationSourceLanguage;

    setState(() {
      _translationSourceLanguage = newSourceLanguage;
      if (_translationTargetLanguage == newSourceLanguage) {
        _translationTargetLanguage = oldSourceLanguage;
      }
    });

    _setTextToSpeechLanguage();
    _saveLanguagesInUserPreferences();
    _translate();
  }

  void _setTextToSpeechLanguage() {
    setState(() {
      _textToSpeechLanguage = widget.textToSpeechLanguages.firstWhereOrNull(
          (ttsl) =>
              ttsl.language.name == _translationSourceLanguage!.language.name);
    });
  }

  void _setTranslateTargetLanguage(
      GoogleCloudTranslationLanguage newTargetLanguage) {
    log("@>_setTranslateTargetLanguage");

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
      widget.userPreferences.sourceLanguageCode =
          _translationSourceLanguage!.code;
      widget.userPreferences.targetLanguageCode =
          _translationTargetLanguage!.code;
      widget.userPreferencesStorage.save(widget.userPreferences);
    }
  }

  Widget _buildTapDialogPageContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.only(
              top: 4.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                      child: _translationSourceLanguage != null
                          ? DropdownButton(
                              underline: Container(),
                              iconSize: 0.0,
                              isDense: false,
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
                                          ? const Color(0xFF00A3FF)
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  (GoogleCloudTranslationLanguage? newValue) {
                                _setTranslateSourceLanguage(newValue!);
                              },
                              selectedItemBuilder: (con) {
                                return widget.translationLanguages.map((gtl) {
                                  return Center(
                                      child: Text(
                                    gtl.language.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF00A3FF),
                                    ),
                                  ));
                                }).toList();
                              },
                            )
                          : null),
                ),
                IconButton(
                  padding: EdgeInsets.only(left: 4.0, right: 4.0),
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
                    _setTextToSpeechLanguage();
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
                              isDense: false,
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
                                            : Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  (GoogleCloudTranslationLanguage? newValue) {
                                _setTranslateTargetLanguage(newValue!);
                              },
                              selectedItemBuilder: (con) {
                                return widget.translationLanguages.map((gtl) {
                                  return Center(
                                      child: Text(
                                    gtl.language.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF00A3FF),
                                    ),
                                  ));
                                }).toList();
                              })
                          : null),
                ),
              ],
            )),
        Container(
            height: 116.0,
            child: Scrollbar(
                child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 32.0, left: 16.0, right: 16.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textToSpeechLanguage != null
                              ? Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 2.5, right: 4.0),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.volume_up),
                                    iconSize: 24.0,
                                    onPressed: () async {
                                      log("Pressed on speaker icon");
                                      widget.googleCloudTextToSpeechClient
                                          .synthesize(
                                        widget.originalText,
                                        _textToSpeechLanguage!.code,
                                      )
                                          .then((base64String) {
                                        // log("base64 encoded" + base64String);

                                        getTemporaryDirectory().then((dir) {
                                          var filePath =
                                              '${dir.path}/${widget.originalText}_${_textToSpeechLanguage!.code}.mp3';
                                          var file = File(filePath);

                                          var decoded =
                                              base64.decode(base64String);
                                          // log("Decoded: " + decoded.toString());

                                          file
                                              .writeAsBytes(decoded)
                                              .then((value) {
                                            log("written to file: $filePath");
                                            final player = AudioPlayer();
                                            // player.setAudioContext(audioContext);

                                            // Cannot use BytesSource. It only works on Android...
                                            player
                                                .play(
                                                    DeviceFileSource(filePath))
                                                .whenComplete(() {
                                              log("Deleting temp file again");
                                              file.deleteSync();
                                            });
                                          });
                                        });
                                      });
                                    },
                                  ))
                              : Container(),
                          Flexible(
                            child: Text(
                              widget.originalText,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                          ),
                          SizedBox(width: 24.0 + 4.0)
                        ]),
                    SizedBox(height: 16.0),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 24.0 + 4.0, right: 24.0 + 4.0),
                        child: Text(_translation ?? ''),
                      ),
                    ),
                  ]),
            ))),
        const Divider(
          color: Color(0xFFD2D2D2),
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                side: BorderSide.none,
              ),
              child: Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF00A3FF),
                      fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: _translation != null
                  ? () {
                      widget.onClose();
                    }
                  : null,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                side: BorderSide.none,
              ),
              child: Center(
                child: Text(
                  'Add to deck',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF00A3FF),
                      fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: _translation != null
                  ? () async {
                      Deck deck = await widget.deckStorage.get();

                      Flashcard addedCard = Flashcard(
                        id: const Uuid().v4(),
                        sourceLanguageCode: _translationSourceLanguage!.code,
                        sourceWord: widget.originalText,
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
            )
          ],
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
    log("Translating...");

    String? translation = await widget.googleCloudTranslationClient.translate(
      widget.originalText,
      _translationSourceLanguage!.code,
      _translationTargetLanguage!.code,
    );
    log("Translation: $translation");
    setState(() {
      _originalText = widget.originalText;
      _translation = translation;
    });
  }
}
