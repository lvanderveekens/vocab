import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocab/language/language.dart';

import 'package:vocab/camera/camera_page.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/text_recognition/ml_kit_text_recognition_languages.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_languages.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';

import 'deck/deck_page.dart';
import 'deck/deck_storage.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  final deckStorage = DeckStorage();
  final userPreferencesStorage = UserPreferencesStorage();

  List<Language> _languages = [];
  List<GoogleCloudTranslationLanguage> _translationLanguages = [];
  List<GoogleCloudTextToSpeechLanguage> _textToSpeechLanguages = [];
  List<MLKitTextRecognitionLanguage> _textRecognitionLanguages = [];

  UserPreferences? _userPreferences;

  @override
  initState() {
    super.initState();

    log("Loading languages");
    Languages.getInstance().then((value) {
      _languages = value.languageList;
    });
    log("Loading Google Cloud Translation languages");
    GoogleCloudTranslationLanguages.load().then((value) {
      setState(() {
        _translationLanguages = value;
      });
    });
    log("Loading Google Cloud Text-to-speech languages");
    GoogleCloudTextToSpeechLanguages.load().then((value) {
      setState(() {
        _textToSpeechLanguages = value;
      });
    });
    log("Loading ML Kit Text Recognition languages");
    MLKitTextRecognitionLanguages.load().then((value) {
      setState(() {
        _textRecognitionLanguages = value;
      });
    });

    log("Loading user preferences...");
    userPreferencesStorage.get().then((value) {
      setState(() {
        _userPreferences = value;
      });
    });
  }

  List<Widget> _getPages() {
    return [
      CameraPage(
        deckStorage: deckStorage,
        userPreferencesStorage: userPreferencesStorage,
        translationLanguages: _translationLanguages,
        textToSpeechLanguages: _textToSpeechLanguages,
        textRecognitionLanguages: _textRecognitionLanguages,
        userPreferences: _userPreferences,
      ),
      DeckPage(
        deckStorage: deckStorage,
        languages: _languages,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
        theme: ThemeData(
            textTheme: ThemeData(
                    textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 16.0),
          bodyText2: TextStyle(fontSize: 16.0),
          button: TextStyle(fontSize: 16.0),
        )).textTheme.apply(
                  bodyColor: Colors.black,
                )),
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: AppBar(
                  bottom: PreferredSize(
                      child: Container(
                        color: Colors.black26,
                        height: 1.0,
                      ),
                      preferredSize: Size.fromHeight(1.0)),
                  elevation: 0,
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 4.0),
                            child: SvgPicture.asset('assets/icon.svg',
                                width: 24.0,
                                height: 24.0,
                                color: const Color(0xFF00A3FF),
                                semanticsLabel: 'The logo')),
                        const Text('Vocab',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Color(0xFF00A3FF),
                            )),
                      ]),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                )),
            body: _getPages().elementAt(_selectedIndex),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black26, width: 1.0))),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt_outlined),
                    activeIcon: Icon(Icons.camera_alt),
                    label: 'Camera',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.style_outlined),
                    activeIcon: Icon(Icons.style),
                    label: 'Deck',
                  ),
                ],
                selectedLabelStyle: TextStyle(fontSize: 16.0),
                unselectedLabelStyle: TextStyle(fontSize: 16.0),
                currentIndex: _selectedIndex,
                selectedItemColor: Color(0xFF00A3FF),
                unselectedItemColor: Colors.black,
                backgroundColor: Colors.white,
                elevation: 0,
                onTap: _onItemTapped,
              ),
            )));
  }
}
