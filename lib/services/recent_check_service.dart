import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecentCheck {
  final String docType;
  final bool hasRisk;
  final DateTime date;

  RecentCheck({required this.docType, required this.hasRisk, required this.date});

  Map<String, dynamic> toJson() => {
    'docType': docType,
    'hasRisk': hasRisk,
    'date': date.toIso8601String(),
  };

  factory RecentCheck.fromJson(Map<String, dynamic> json) => RecentCheck(
    docType: json['docType'],
    hasRisk: json['hasRisk'],
    date: DateTime.parse(json['date']),
  );
}

class RecentCheckService {
  static const String _key = 'recent_checks';

  static Future<void> saveCheck(RecentCheck check) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    data.insert(0, jsonEncode(check.toJson())); // вставляем первым
    if (data.length > 10) data.removeLast(); // храним только последние 10

    await prefs.setStringList(_key, data);
  }

  static Future<List<RecentCheck>> getChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => RecentCheck.fromJson(jsonDecode(e))).toList();
  }
}
