import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/machine.dart';

class ApiService {
  // Desktop app + local server = localhost works directly.
  static const String baseUrl = "http://localhost:5000/api";

  Future<List<Machine>> getMachines() async {
    final response = await http.get(Uri.parse("$baseUrl/machines"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load machines");
    }
    final List data = jsonDecode(response.body);
    return data.map((m) => Machine.fromJson(m)).toList();
  }

  Future<Machine> startMachine(String id) async {
    final response = await http.post(Uri.parse("$baseUrl/machines/$id/start"));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? "Failed to start machine");
    }
    return Machine.fromJson(jsonDecode(response.body));
  }

  Future<Machine> completeMachine(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/machines/$id/complete"),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to complete machine");
    }
    return Machine.fromJson(jsonDecode(response.body));
  }
}
