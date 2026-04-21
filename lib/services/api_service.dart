import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gear_item.dart';
import '../models/division.dart';
import '../models/dashboard_stats.dart';

abstract class ApiServiceBase {
  Future<List<GearItem>> fetchGear({String? search});
  Future<GearItem> fetchGearById(int id);
  Future<List<Division>> fetchDivisions();
  Future<DashboardStats> fetchStats();
  Future<GearItem> createGear({
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  });
  Future<void> updateGear({
    required int id,
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  });
  Future<void> deleteGear(int id);
}

class ApiService implements ApiServiceBase {
  // Android emulator uses 10.0.2.2, web/desktop uses localhost
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  @override
  Future<List<GearItem>> fetchGear({String? search}) async {
    final uri = Uri.parse('$baseUrl/gear${search != null && search.isNotEmpty ? '?search=${Uri.encodeComponent(search)}' : ''}');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => GearItem.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch gear: ${response.statusCode}');
  }

  @override
  Future<GearItem> fetchGearById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/gear/$id'));
    if (response.statusCode == 200) {
      return GearItem.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to fetch gear item $id: ${response.statusCode}');
  }

  @override
  Future<List<Division>> fetchDivisions() async {
    final response = await http.get(Uri.parse('$baseUrl/divisions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Division.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch divisions: ${response.statusCode}');
  }

  @override
  Future<DashboardStats> fetchStats() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/stats'));
    if (response.statusCode == 200) {
      return DashboardStats.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to fetch stats: ${response.statusCode}');
  }

  @override
  Future<GearItem> createGear({
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/gear'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'divisionId': divisionId,
        'quantity': quantity,
        'notes': notes,
      }),
    );
    if (response.statusCode == 201) {
      return GearItem.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create gear: ${response.statusCode}');
  }

  @override
  Future<void> updateGear({
    required int id,
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/gear/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'divisionId': divisionId,
        'quantity': quantity,
        'notes': notes,
      }),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update gear: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteGear(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/gear/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete gear: ${response.statusCode}');
    }
  }
}
