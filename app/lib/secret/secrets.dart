import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class Secrets {
  final String googleCloudApiKey;

  const Secrets(this.googleCloudApiKey);

  factory Secrets.fromJson(Map<String, dynamic> jsonMap) {
    return Secrets(
      jsonMap["googleCloudApiKey"],
    );
  }
}

class SecretsLoader {
  final String pathToFile = "assets/secrets.json";

  SecretsLoader();

  Future<Secrets> load() {
    return rootBundle.loadStructuredData<Secrets>(pathToFile, (jsonStr) async {
      var env = kDebugMode ? 'dev' : 'prd';
      log("Loading secrets for environment: $env");
      return Secrets.fromJson(json.decode(jsonStr)[env]);
    });
  }
}
