import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks_json_list_v1';

  Future<List<Task>> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return <Task>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((dynamic e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Task>[];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      tasks.map((Task t) => t.toJson()).toList(),
    );
    await prefs.setString(_tasksKey, encoded);
  }

  Future<void> addTask(Task task) async {
    final List<Task> tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task updated) async {
    final List<Task> tasks = await loadTasks();
    final int index = tasks.indexWhere((Task t) => t.id == updated.id);
    if (index != -1) {
      tasks[index] = updated;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final List<Task> tasks = await loadTasks();
    tasks.removeWhere((Task t) => t.id == id);
    await saveTasks(tasks);
  }
}
