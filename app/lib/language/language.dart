import 'dart:developer';

import 'package:vocab/language/languages.dart';

class Language {
  final String name;
  final String? iso639_1;
  final String? iso639_2b;
  final String? iso639_2t;
  final String? iso639_3;
  final String? bcp47;

  Language({
    required this.name,
    required this.iso639_1,
    required this.iso639_2b,
    required this.iso639_2t,
    required this.iso639_3,
    required this.bcp47,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      iso639_1: json['iso639_1'],
      iso639_2b: json['iso639_2b'],
      iso639_2t: json['iso639_2t'],
      iso639_3: json['iso639_3'],
      bcp47: json['bcp47'],
    );
  }

  bool hasCode(String code) {
    if (iso639_1 == code) {
      return true;
    }
    if (iso639_2b == code) {
      return true;
    }
    if (iso639_2t == code) {
      return true;
    }
    if (iso639_3 == code) {
      return true;
    }
    if (bcp47 == code) {
      return true;
    }
    return false;
  }

  // bool operator ==(o) =>
  //     o is Language && name == o.name && isoCode == o.isoCode;

  // int get hashCode => super.hashCode;
}
