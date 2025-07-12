import 'dart:convert';
import 'api_service.dart';

class TodoService {
  // Get all todos for a user
  static Future<List<Map<String, dynamic>>> fetchTodos(String userId) async {
    final res = await ApiService.get('/todo/$userId');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Get a single todo by id
  static Future<Map<String, dynamic>> fetchTodoById(String id) async {
    final res = await ApiService.get('/todo/item/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load todo');
    }
  }

  // Create a new todo
  static Future<Map<String, dynamic>> addTodo(Map<String, dynamic> todo) async {
    final res = await ApiService.post('/todo/', body: todo);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to add todo');
    }
  }

  // Update a todo by id
  static Future<Map<String, dynamic>> updateTodo(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final res = await ApiService.put('/todo/$id', body: updates);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Delete a todo by id
  static Future<void> deleteTodo(String id) async {
    final res = await ApiService.delete('/todo/$id');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
