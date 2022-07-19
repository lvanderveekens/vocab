import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:megaphone/google_translation_response.dart';
import 'package:megaphone/secrets.dart';
import 'package:megaphone/storage/word_repository.dart';
import 'package:megaphone/text_decorator_painter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ListPage extends StatefulWidget {
  final WordStorage wordStorage;

  const ListPage({Key? key, required this.wordStorage}) : super(key: key);

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  List<String> wordList = [];

  @override
  void initState() {
    super.initState();
    widget.wordStorage.findAll().then((value) {
      setState(() {
        wordList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: wordList.map((value) => Text(value)).toList(),
      ),
    );
  }
}
