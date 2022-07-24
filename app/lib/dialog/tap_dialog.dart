import 'package:flutter/material.dart';

class TapDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final String? tappedOnWord;

  const TapDialog({
    Key? key,
    required this.onClose,
    required this.tappedOnWord,
  }) : super(key: key);

  @override
  State<TapDialog> createState() => TapDialogState();
}

class TapDialogState extends State<TapDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.tappedOnWord == null) {
      return const Text('No word found...');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tapped on word: ${widget.tappedOnWord}'),
        // TextButton(
        //     onPressed: () {
        //       widget.wordStorage.save("$tappedText->$translation");
        //     },
        //     child: const Text("Add to list"))
      ],
    );
  }

  // // TODO: move translation
  // String? translation;
  // final recognizedLanguages = block.recognizedLanguages;

  // if (_translateEnabled && recognizedLanguages.isNotEmpty) {
  //   final recognizedLanguage = recognizedLanguages[0];
  //   if (recognizedLanguage != "en") {
  //     log("Translating...");
  //     translation =
  //         await translate(tappedOnText, recognizedLanguage, "en");

  //     log("Translation: $translation");
  //   }
  // }
}
