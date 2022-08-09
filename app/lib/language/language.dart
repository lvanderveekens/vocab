import 'dart:developer';

import 'package:vocab/language/languages.dart';

class Language {
  final String name;
  final String? alpha2;
  final String? alpha3b;
  final String? alpha3t;
  final String? bcp47;
  final String? iso639_3;

  Language({
    required this.name,
    required this.alpha2,
    required this.alpha3b,
    required this.alpha3t,
    required this.bcp47,
    required this.iso639_3,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      alpha2: json['alpha2'],
      alpha3b: json['alpha3-b'],
      alpha3t: json['alpha3-t'],
      bcp47: json['bcp47'],
      iso639_3: json['iso639_3'],
    );
  }

  // bool operator ==(o) =>
  //     o is Language && name == o.name && isoCode == o.isoCode;

  // int get hashCode => super.hashCode;
}
