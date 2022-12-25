import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/flashcard/flashcard.dart';
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/study/study_service.dart';

class StudyCardPage extends StatefulWidget {
  final StudyService studyService;
  final Deck deck;
  final Languages languages;

  const StudyCardPage({
    Key? key,
    required this.studyService,
    required this.deck,
    required this.languages,
  }) : super(key: key);

  @override
  State<StudyCardPage> createState() => StudyCardPageState();
}

class StudyCardPageState extends State<StudyCardPage> {
  @override
  Widget build(BuildContext context) {
    var cards = widget.studyService.findCardsForReviewSession(widget.deck);
    var card = cards[0];

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildCard(card),
          buildStatusText(card),
          buildShowAnswerButton(),
        ],
      ),
    );
  }

  Widget buildShowAnswerButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(16.0),
            backgroundColor: Color(0xFF00A3FF),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
        child: Text(
          'Show answer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => {log("PRESSED")},
      ),
    );
  }

  Widget buildCard(Flashcard card) {
    return Expanded(
      child: Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10.0)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.languages
                              .getByCode(card.sourceLanguageCode)
                              .name),
                          Text(card.sourceWord,
                              style: TextStyle(fontSize: 34.0)),
                        ]))),
            const Divider(color: Colors.black26, height: 1.0, thickness: 1.0),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.languages
                              .getByCode(card.targetLanguageCode)
                              .name),
                          // Text(card.targetWord,
                          //     style: TextStyle(fontSize: 24.0)),
                        ]))),
          ])),
    );
  }

  Widget buildStatusText(Flashcard card) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.0),
        child: Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'New: ',
              ),
              TextSpan(
                text: '${widget.deck.getNewCards().length}',
                style: TextStyle(
                  decoration: card.isNew() ? TextDecoration.underline : null,
                ),
              ),
              TextSpan(text: ', Learning: '),
              TextSpan(
                text: '${widget.deck.getCardsInLearning().length}',
                style: TextStyle(
                  decoration:
                      card.isInLearning() ? TextDecoration.underline : null,
                ),
              ),
              TextSpan(text: ', To review: '),
              TextSpan(
                text: '${widget.deck.getCardsToReview().length}',
                style: TextStyle(
                  decoration:
                      card.isReviewable() ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ));
  }

  PreferredSize buildAppBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          bottom: PreferredSize(
              child: Container(
                color: Colors.black26,
                height: 1.0,
              ),
              preferredSize: Size.fromHeight(1.0)),
          elevation: 0,
          title: const Text('Study',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Color(0xFF00A3FF),
              )),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ));
  }
}
