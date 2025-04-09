class CheckResult {
  final String documentType;
  final DateTime date;
  final bool hasRisk;

  CheckResult({
    required this.documentType,
    required this.date,
    required this.hasRisk,
  });

  Map<String, dynamic> toMap() => {
    'documentType': documentType,
    'date': date.toIso8601String(),
    'hasRisk': hasRisk,
  };

  factory CheckResult.fromMap(Map<String, dynamic> map) => CheckResult(
    documentType: map['documentType'],
    date: DateTime.parse(map['date']),
    hasRisk: map['hasRisk'],
  );
}
