import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  StreamSubscription? _taskSubscription;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;

  List<TaskModel> get filteredTasks {
    if (_searchQuery.isEmpty) return _tasks;
    return _tasks
        .where((task) =>
    task.taskTitle
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()) ||
        task.taskDescription
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void listenToTasks() {
    if (_taskSubscription != null) return;
    resetAndListen();
  }

  void resetAndListen() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
    _tasks = [];
    _searchQuery = '';
    _isLoading = true;
    notifyListeners();
    _taskSubscription =
        FirestoreService.getTasksStream().listen((tasks) {
          _tasks = tasks;
          _isLoading = false;
          notifyListeners();
        });
  }

  void cancelStream() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
    _tasks = [];
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTask({
    required String taskTitle,
    required String taskDescription,
    required String priority,
    bool isCompleted = false,
  }) async {
    await FirestoreService.addTask(
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      priority: priority,
      isCompleted: isCompleted,
    );
  }

  Future<void> updateTask({
    required String taskId,
    required String taskTitle,
    required String taskDescription,
    required String priority,
  }) async {
    await FirestoreService.updateTask(
      taskId: taskId,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      priority: priority,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await FirestoreService.deleteTask(taskId);
  }

  Future<void> toggleCompletion(String taskId, bool current) async {
    await FirestoreService.updateTaskCompletion(
      taskId: taskId,
      isCompleted: !current,
    );
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}