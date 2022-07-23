import 'package:flutter/material.dart';

import 'package:megaphone/pages/camera_page.dart';
import 'package:megaphone/pages/list_page.dart';
import 'package:megaphone/storage/word_storage.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading aid',
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
