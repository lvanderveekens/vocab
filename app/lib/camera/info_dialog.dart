import 'package:flutter/material.dart';
import 'package:vocab/text_recognition/text_recognition_languages.dart';
import 'package:vocab/widgets/bullet_text.dart';

class InfoDialog extends StatefulWidget {
  final VoidCallback onClose;
  final List<TextRecognitionLanguage> textRecognitionLanguages;

  const InfoDialog({
    Key? key,
    required this.onClose,
    required this.textRecognitionLanguages,
  }) : super(key: key);

  @override
  State<InfoDialog> createState() => InfoDialogState();
}

class InfoDialogState extends State<InfoDialog> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [..._buildTapDialogPage()])));
  }

  List<Widget> _buildTapDialogPage() {
    return [
      _buildDialogHeader(title: "Info"),
      _buildDialogContentWrapper(child: _buildDialogPageContent())
    ];
  }

  Widget _buildDialogContentWrapper({required Widget child}) {
    return Flexible(
        child: Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: child,
    ));
  }

  Widget _buildDialogPageContent() {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Supported languages:"),
        ...widget.textRecognitionLanguages
            .map((trl) => BulletText(trl.language.name))
      ],
    ));
  }

  Widget _buildDialogHeader({required String title}) {
    return Row(children: [
      Expanded(
          child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Container(),
              ))),
      Text(title,
          style:
              TextStyle(color: Color(0xFF00A3FF), fontWeight: FontWeight.bold)),
      Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        if (widget.onClose != null) {
                          widget.onClose();
                        }
                      }))))
    ]);
  }
}
