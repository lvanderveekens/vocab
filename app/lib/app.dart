import 'package:flutter/material.dart';

import 'package:megaphone/pages/home_page.dart';
import 'package:megaphone/pages/list_page.dart';
import 'package:megaphone/storage/word_repository.dart';

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
      HomePage(wordStorage: wordStorage),
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
        title: const Text('Reading companion'),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      body: _getPages().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
