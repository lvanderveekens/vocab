import 'package:vocab/sm2/sm2_result.dart';

// source: https://en.wikipedia.org/wiki/SuperMemo

class SM2Algorithm {
  SM2Output apply(
    int grade,
    int repetitionNumber,
    double easinessFactor,
    int intervalDays,
  ) {
    if (grade >= 3 /* correct response */) {
      if (repetitionNumber == 0) {
        intervalDays = 1;
      } else if (repetitionNumber == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easinessFactor).round();
      }
      repetitionNumber++;
    } else {
      repetitionNumber = 0;
      intervalDays = 1;
    }

    easinessFactor =
        easinessFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    if (easinessFactor < 1.3) {
      easinessFactor = 1.3;
    }

    return SM2Output(
        repetitionNumber: repetitionNumber,
        easinessFactor: easinessFactor,
        intervalDays: intervalDays);
  }
}
