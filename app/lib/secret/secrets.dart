import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Secrets {
  final String apiKey;
  Secrets(this.apiKey);

  factory Secrets.fromJson(Map<String, dynamic> jsonMap) {
    return Secrets(jsonMap["apiKey"]);
  }
}

class SecretsLoader {
  final String pathToFile = "assets/secrets.json";

  SecretsLoader();

  Future<Secrets> load() {
    return rootBundle.loadStructuredData<Secrets>(pathToFile, (jsonStr) async {
      return Secrets.fromJson(json.decode(jsonStr));
    });
  }
}
