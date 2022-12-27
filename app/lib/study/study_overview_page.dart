import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/study/study_card_page.dart';
import 'package:vocab/study/study_service.dart';

class StudyOverviewPage extends StatefulWidget {
  final DeckStorage deckStorage;

  const StudyOverviewPage({
    Key? key,
    required this.deckStorage,
  }) : super(key: key);

  @override
  State<StudyOverviewPage> createState() => StudyOverviewPageState();
}

class StudyOverviewPageState extends State<StudyOverviewPage> {
  @override
  Widget build(context) {
    return FutureBuilder<Deck>(
        future: widget.deckStorage.get(),
        builder: (context, AsyncSnapshot<Deck> snapshot) {
          if (snapshot.hasData) {
            final deck = snapshot.data!;
            return Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.all(32.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (deck.cards.isEmpty)
                              buildEmptyDeckMessage()
                            else if (deck.getCardsForReviewSession().isEmpty)
                              buildDoneStudyingMessage()
                            else
                              buildDeckStatus(context, deck)
                          ]),
                    ),
                  )
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Column buildDoneStudyingMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Good job! You’re done studying for now.",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.0),
        Text("Come back later to review more cards.",
            style: TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Column buildEmptyDeckMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your deck is empty.",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.0),
        Text(
            "Add cards to your deck using the camera and then come back to review them here.",
            style: TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Widget buildDeckStatus(BuildContext context, Deck deck) {
    return Column(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Deck",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New", style: TextStyle(fontSize: 16.0)),
                      Text("Learning", style: TextStyle(fontSize: 16.0)),
                      Text("To review", style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${deck.getNewCards().length}",
                        style: TextStyle(fontSize: 16.0)),
                    Text("${deck.getCardsInLearning().length}",
                        style: TextStyle(fontSize: 16.0)),
                    Text("${deck.getCardsToReview().length}",
                        style: TextStyle(fontSize: 16.0)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      Align(
        alignment: Alignment.center,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(16.0),
              backgroundColor: Color(0xFF00A3FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
          child: Text(
            'Study now',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => StudyCardPage(
                    studyService: StudyService(),
                    deck: deck,
                    saveDeck: (d) {
                      widget.deckStorage.save(d);
                      setState(() {
                        // refreshes future builder
                      });
                    },
                    languages: GetIt.I<Languages>(),
                  ),
                )),
          },
        ),
      ),
    ]);
  }
}
