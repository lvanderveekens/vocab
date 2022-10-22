import 'package:get_it/get_it.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_client.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';

void configureDependencies() {
  GetIt.I.registerSingletonAsync<Secrets>(() async {
    return await SecretsLoader().load();
  });

  GetIt.I.registerSingletonWithDependencies<GoogleCloudTranslationClient>(
    () => GoogleCloudTranslationClient(
        apiKey: (GetIt.I<Secrets>().googleCloudApiKey)),
    dependsOn: [Secrets],
  );

  GetIt.I.registerSingletonWithDependencies<GoogleCloudTextToSpeechClient>(
    () => GoogleCloudTextToSpeechClient(
        apiKey: (GetIt.I<Secrets>().googleCloudApiKey)),
    dependsOn: [Secrets],
  );
}
