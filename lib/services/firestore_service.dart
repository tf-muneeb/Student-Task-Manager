import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'api_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'tasks';

  static Future<String> _getUserId() async {
    final id = await ApiService.getUserId();
    return id ?? 'unknown';
  }

  static Future<void> addTask({
    required String taskTitle,
    required String taskDescription,
    required String priority,
    bool isCompleted = false,
  }) async {
    final userId = await _getUserId();
    await _db.collection(_collection).add({
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
    });
  }

  static Stream<List<TaskModel>> getTasksStream() async* {
    final userId = await _getUserId();
    yield* _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  static Future<void> updateTask({
    required String taskId,
    required String taskTitle,
    required String taskDescription,
    required String priority,
  }) async {
    await _db.collection(_collection).doc(taskId).update({
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'priority': priority,
    });
  }

  static Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _db.collection(_collection).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  static Future<void> deleteTask(String taskId) async {
    await _db.collection(_collection).doc(taskId).delete();
  }

  static Stream<Map<String, int>> getTaskStatsStream() async* {
    final userId = await _getUserId();
    yield* _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final total = snapshot.docs.length;
      final completed =
          snapshot.docs.where((d) => d['isCompleted'] == true).length;
      return {
        'total': total,
        'completed': completed,
        'pending': total - completed,
      };
    });
  }
}