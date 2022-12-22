class Review {
  final DateTime timestamp;
  final int repetitionNumber;
  final double easinessFactor;
  final int intervalDays;
  final bool learning;

  Review({
    required this.timestamp,
    required this.repetitionNumber,
    required this.easinessFactor,
    required this.intervalDays,
    required this.learning,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      timestamp: json['timestamp'],
      repetitionNumber: json['repetitionNumber'],
      easinessFactor: json['easinessFactor'],
      intervalDays: json['intervalDays'],
      learning: json['learning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'repetitionNumber': repetitionNumber,
      'easinessFactor': easinessFactor,
      'intervalDays': intervalDays,
      'learning': learning,
    };
  }
}
