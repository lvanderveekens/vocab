import 'package:flutter/material.dart';

import 'package:vocab/pages/camera_page.dart';
import 'package:vocab/pages/list_page.dart';
import 'package:vocab/storage/word_storage.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;

  List<Widget> _getPages() {
    final wordStorage = WordStorage();
    return [
      CameraPage(wordStorage: wordStorage),
      ListPage(wordStorage: wordStorage),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          textTheme: ThemeData(
                  textTheme: TextTheme(
            bodyText1: TextStyle(fontSize: 16.0),
            bodyText2: TextStyle(fontSize: 16.0),
            button: TextStyle(fontSize: 16.0),
          )).textTheme.apply(
                bodyColor: Colors.black,
              ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              primary: Colors.black,
            ),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Vocab',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                )),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          body: _getPages().elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'List',
              ),
            ],
            selectedLabelStyle: TextStyle(fontSize: 16.0),
            unselectedLabelStyle: TextStyle(fontSize: 16.0),
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),
        ));
  }
}
