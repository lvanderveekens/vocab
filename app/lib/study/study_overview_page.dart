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
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Deck",
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("New", style: TextStyle(fontSize: 24.0)),
                                  Text("Learning",
                                      style: TextStyle(fontSize: 24.0)),
                                  Text("To review",
                                      style: TextStyle(fontSize: 24.0)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${deck.getNewCards().length}",
                                    style: TextStyle(fontSize: 24.0)),
                                Text("${deck.getCardsInLearning().length}",
                                    style: TextStyle(fontSize: 24.0)),
                                Text("${deck.getCardsToReview().length}",
                                    style: TextStyle(fontSize: 24.0)),
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
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => StudyCardPage(
                                studyService: StudyService(),
                                deck: deck,
                                languages: GetIt.I<Languages>(),
                              ),
                            ))
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
