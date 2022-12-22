import 'package:flutter/material.dart';

class StudyCardPage extends StatefulWidget {
  // final DeckStorage deckStorage;

  const StudyCardPage({
    Key? key,
    // required this.deckStorage,
  }) : super(key: key);

  @override
  State<StudyCardPage> createState() => StudyCardPageState();
}

class StudyCardPageState extends State<StudyCardPage> {
  // Deck? _deck;

  @override
  void initState() {
    super.initState();
    // widget.deckStorage.get().then((deck) {
    //   setState(() {
    //     _deck = deck;
    //   });
    //   log("Deck loaded");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Container());
  }
}
