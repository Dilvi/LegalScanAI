import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/check_result.dart';

class ResultCache {
  static const String key = 'recentChecks';

  static Future<List<CheckResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CheckResult.fromMap(e)).toList();
  }

  static Future<void> save(List<CheckResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(results.map((e) => e.toMap()).toList());
    await prefs.setString(key, jsonString);
  }

  static Future<void> add(CheckResult result) async {
    final list = await load();
    list.insert(0, result);
    if (list.length > 10) list.removeLast(); // ограничим до 10 элементов
    await save(list);
  }
}
