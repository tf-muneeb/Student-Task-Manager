import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String taskTitle;
  final String taskDescription;
  final DateTime createdAt;
  final bool isCompleted;
  final String priority;
  final String userId;

  TaskModel({
    required this.id,
    required this.taskTitle,
    required this.taskDescription,
    required this.createdAt,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.userId = '',
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      taskTitle: data['taskTitle'] ?? '',
      taskDescription: data['taskDescription'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 'Medium',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? taskTitle,
    String? taskDescription,
    DateTime? createdAt,
    bool? isCompleted,
    String? priority,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDescription: taskDescription ?? this.taskDescription,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
    );
  }
}