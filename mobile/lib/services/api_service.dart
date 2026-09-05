import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/machine.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000/api";

  // Persisted once per install — survives app restarts, unlike a random in-memory value.
  static late String deviceId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString("device_id");
    if (saved == null) {
      saved =
          "device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}";
      await prefs.setString("device_id", saved);
    }
    deviceId = saved;
  }

  Future<List<Machine>> getMachines() async {
    final response = await http.get(Uri.parse("$baseUrl/machines"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load machines");
    }
    final List data = jsonDecode(response.body);
    return data.map((m) => Machine.fromJson(m)).toList();
  }

  Future<Machine> startMachine(String id, int durationSeconds) async {
    final response = await http.post(
      Uri.parse("$baseUrl/machines/$id/start"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "durationSeconds": durationSeconds,
        "deviceId": deviceId,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? "Failed to start machine");
    }
    return Machine.fromJson(jsonDecode(response.body));
  }

  Future<Machine> stopMachine(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/machines/$id/complete"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"deviceId": deviceId}),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? "Failed to stop machine");
    }
    return Machine.fromJson(jsonDecode(response.body));
  }

  Future<Machine> adminCompleteMachine(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/machines/$id/admin-complete"),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to complete machine");
    }
    return Machine.fromJson(jsonDecode(response.body));
  }
}
