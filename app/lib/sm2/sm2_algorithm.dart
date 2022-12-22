import 'package:vocab/sm2/sm2_result.dart';

// sources:
// - https://en.wikipedia.org/wiki/SuperMemo
// - https://www.super-memory.com/english/ol/sm2.htm

class SM2Algorithm {
  SM2Output apply(
    int grade,
    int repetitionNumber,
    double easinessFactor, // the initial value is 2.5
    int intervalDays,
  ) {
    if (grade >= 3) {
      // correct response
      if (repetitionNumber == 0) {
        intervalDays = 1;
      } else if (repetitionNumber == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easinessFactor).round();
      }
      repetitionNumber++;
    } else {
      // incorrect response
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
      intervalDays: intervalDays,
    );
  }

  // After all scheduled reviews are complete, SuperMemo asks the user to re-review any cards they marked with a grade less than 4 repeatedly until they give a grade ≥ 4.
}
