import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab/user/user_preferences.dart';

class UserPreferencesStorage {
  static const filename = "user-preferences";

  Future<UserPreferences> get() async {
    log("Retrieving user preferences...");
    final file = await _getFile();

    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());

      var userPreferences = UserPreferences.fromJson(json);
      log("Existing: ${jsonEncode(userPreferences.toJson())}");
      return userPreferences;
    }

    return UserPreferences(
      sourceLanguageCode: 'it',
      targetLanguageCode: 'en',
    );
  }

  Future<void> save(UserPreferences userPreferences) async {
    log("Saving user preferences: ${jsonEncode(userPreferences.toJson())}");
    final file = await _getFile();
    await file.writeAsString(jsonEncode(userPreferences.toJson()));
  }

  Future<File> _getFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return File('${appDocDir.path}/$filename.json');
  }
}
