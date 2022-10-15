import 'package:get_it/get_it.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';

void configureDependencies() {
  GetIt.I.registerSingletonAsync<Secrets>(() async {
    return await SecretsLoader().load();
  });

  GetIt.I.registerSingletonWithDependencies<GoogleCloudTranslationClient>(
    () => GoogleCloudTranslationClient(apiKey: (GetIt.I<Secrets>().apiKey)),
    dependsOn: [Secrets],
  );
}
