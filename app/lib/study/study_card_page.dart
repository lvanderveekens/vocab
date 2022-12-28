import 'package:flutter/material.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/flashcard/flashcard.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/study/study_service.dart';

class StudyCardPage extends StatefulWidget {
  final StudyService studyService;
  final Deck deck;
  final Function(Deck) saveDeck;
  final Languages languages;

  const StudyCardPage({
    Key? key,
    required this.studyService,
    required this.deck,
    required this.saveDeck,
    required this.languages,
  }) : super(key: key);

  @override
  State<StudyCardPage> createState() => StudyCardPageState();
}

class StudyCardPageState extends State<StudyCardPage> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    var cards = widget.deck.getCardsForReviewSession();
    // if (cards.isEmpty) {
    //   // Navigator.pop(context);
    //   return Scaffold(
    //     appBar: buildAppBar(),
    //     body: Container(),
    //   );
    // }
    var card = cards[0];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            appBar: buildAppBar(),
            body: Column(
              children: [
                Expanded(child: buildCard(card)),
                SizedBox(
                    height: 118.0,
                    child: Column(
                      children: [
                        if (showAnswer) ...[
                          Container(
                            margin: EdgeInsets.only(
                              left: 24.0 /* + 8.0 from text button*/,
                              right: 24.0 /* + 8.0 from text button */,
                            ),
                            child: Column(children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      bottom:
                                          8.0 /* plus 8px padding from text button */),
                                  child: Text("How well did you remember?")),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        child: Text("😭",
                                            style: TextStyle(fontSize: 34.0)),
                                        onPressed: () =>
                                            reviewCard(context, card, 0)),
                                    TextButton(
                                        child: Text("👎",
                                            style: TextStyle(fontSize: 34.0)),
                                        onPressed: () =>
                                            reviewCard(context, card, 1)),
                                    TextButton(
                                        child: Text("👍",
                                            style: TextStyle(fontSize: 34.0)),
                                        onPressed: () =>
                                            reviewCard(context, card, 2)),
                                    TextButton(
                                        child: Text("😃",
                                            style: TextStyle(fontSize: 34.0)),
                                        onPressed: () =>
                                            reviewCard(context, card, 3)),
                                  ]),
                            ]),
                          )
                        ] else ...[
                          buildStatusText(card),
                          buildShowAnswerButton()
                        ]
                      ],
                    ))
              ],
            ),
          )),
    );
  }

  void reviewCard(BuildContext context, Flashcard card, int grade) {
    widget.studyService.reviewCard(card, grade);
    widget.saveDeck(widget.deck);

    final cards = widget.deck.getCardsForReviewSession();
    if (cards.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      // force rerender using updated widget.deck
      showAnswer = false;
    });
  }

  Widget buildShowAnswerButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 32.0),
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
        onPressed: () => {
          setState(() => {showAnswer = true}),
        },
      ),
    );
  }

  Widget buildCard(Flashcard card) {
    return Container(
        margin: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.languages
                            .getByCode(card.sourceLanguageCode)
                            .name),
                        Text(card.sourceWord, style: TextStyle(fontSize: 34.0)),
                      ]))),
          Container(
              margin: EdgeInsets.only(left: 32.0, right: 32.0),
              child:
                  Divider(color: Colors.black26, height: 1.0, thickness: 1.0)),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.languages
                            .getByCode(card.targetLanguageCode)
                            .name),
                        if (showAnswer)
                          Text(card.targetWord,
                              style: TextStyle(fontSize: 34.0))
                      ]))),
        ]));
  }

  Widget buildStatusText(Flashcard card) {
    return Container(
        margin: EdgeInsets.only(bottom: 16.0),
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
