import 'package:get_it/get_it.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/text_recognition/ml_kit_text_recognition_languages.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_client.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_languages.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';

void configureDependencies() {
  GetIt.I.registerSingletonAsync<Secrets>(() async {
    return await SecretsLoader().load();
  });

  GetIt.I.registerSingletonAsync<Languages>(() async {
    return await LanguagesLoader().load();
  });

  GetIt.I.registerSingletonAsync<MLKitTextRecognitionLanguages>(
    () async {
      return await MLKitTextRecognitionLanguagesLoader(
        languages: GetIt.I<Languages>(),
      ).load();
    },
    dependsOn: [Languages],
  );

  GetIt.I.registerSingletonAsync<GoogleCloudTranslationLanguages>(
    () async {
      return await GoogleCloudTranslationLanguagesLoader(
        languages: GetIt.I<Languages>(),
      ).load();
    },
    dependsOn: [Languages],
  );

  GetIt.I.registerSingletonAsync<GoogleCloudTextToSpeechLanguages>(
    () async {
      return await GoogleCloudTextToSpeechLanguagesLoader(
        languages: GetIt.I<Languages>(),
      ).load();
    },
    dependsOn: [Languages],
  );

  GetIt.I.registerSingletonWithDependencies<GoogleCloudTranslationClient>(
    () => GoogleCloudTranslationClient(
        apiKey: GetIt.I<Secrets>().googleCloudApiKey),
    dependsOn: [Secrets],
  );

  GetIt.I.registerSingletonWithDependencies<GoogleCloudTextToSpeechClient>(
    () => GoogleCloudTextToSpeechClient(
        apiKey: GetIt.I<Secrets>().googleCloudApiKey),
    dependsOn: [Secrets],
  );
}
