# vocab

A new Flutter project.

## Release

1. Update versions in pubspec.yaml and Xcode.

2. Release build: 

    $ flutter build ipa --obfuscate --split-debug-info=build/app/outputs/symbols

3. Use transporter to upload the resulting ipa to App Store Connect.

## Languages

### Formats

ISO-639-1 (alpha2)   : "nl"
ISO-639-2 (alpha3-b) : "dut"
ISO-639-2 (alpha3-t) : "nld"
ISO-639-3            : "cmn"
Language tag (BCP-47): "nl-NL" or "sr-Latn"

### List of language codes

Obtained file from: https://datahub.io/core/language-codes

### Supported languages

ML Kit text recognition: https://developers.google.com/ml-kit/vision/text-recognition/languages

Google Cloud Translation: https://translation.googleapis.com/language/translate/v2/languages

Google Cloud Text-to-Speech: https://cloud.google.com/text-to-speech/docs/voices

