import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:vocab/camera/camera_page.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/study/study_overview_page.dart';
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

  UserPreferences? _userPreferences;

  @override
  initState() {
    super.initState();

    // NOTE: fix for audio only playing through earpiece on iOS.
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        defaultToSpeaker: true,
        category: AVAudioSessionCategory.playAndRecord,
        options: [
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.mixWithOthers,
        ],
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    AudioPlayer.global.setGlobalAudioContext(audioContext);

    log("Loading user preferences...");
    userPreferencesStorage.get().then((value) {
      setState(() {
        _userPreferences = value;
      });
    });

    deckStorage.migrate();
  }

  List<Widget> _getPages() {
    log("@>getPages()");
    return [
      CameraPage(
        deckStorage: deckStorage,
        userPreferencesStorage: userPreferencesStorage,
        userPreferences: _userPreferences,
      ),
      DeckPage(
        deckStorage: deckStorage,
        languages: GetIt.I<Languages>(),
      ),
      StudyOverviewPage(deckStorage: deckStorage),
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
            body: FutureBuilder(
              future: GetIt.I.allReady(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _getPages().elementAt(_selectedIndex);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school_outlined),
                    activeIcon: Icon(Icons.school),
                    label: 'Study',
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
