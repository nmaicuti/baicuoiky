import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks(String token) async {
    try {
      _tasks = await _apiService.getTasks(token);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTask(Task task, String token) async {
    try {
      await _apiService.updateTask(task.id, {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
        'category': task.category,
        'completed': task.completed,
      }, token);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> createTask(Task task, String token) async {
    try {
      final response = await _apiService.createTask(
        {
          'title': task.title,
          'description': task.description,
          'status': task.status,
          'priority': task.priority,
          'dueDate': task.dueDate?.toIso8601String(),
          'category': task.category,
          'completed': task.completed,
        },
        token,
      );
      final newTask = Task.fromJson(response['task']);
      _tasks.add(newTask);
      notifyListeners();
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteTask(String taskId, String token) async {
    try {
      await _apiService.deleteTask(taskId, token);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> uploadAttachments(String? taskId, List<String> filePaths, String token) async {
    if (taskId == null) {
      throw Exception('Task ID is required for uploading attachments');
    }
    try {
      for (String filePath in filePaths) {
        await _apiService.uploadAttachment(taskId, filePath, token);
      }
      await fetchTasks(token);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to upload attachments: $error');
    }
  }
}