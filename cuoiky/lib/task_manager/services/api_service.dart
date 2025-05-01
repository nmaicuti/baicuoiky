import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, dynamic>> register(String username, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role, // Thêm role
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<List<Task>> getTasks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(taskData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(taskData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  Future<void> deleteTask(String taskId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  Future<void> uploadAttachment(String taskId, String filePath, String token) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/tasks/upload/$taskId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload attachment: ${response.statusCode}');
    }
  }
}