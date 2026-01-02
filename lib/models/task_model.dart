import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/constants/constants.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String userId;
  final DateTime createdAt;
  final String? categoryId;
  final DateTime? reminderTime;
  final bool? isReminderActive;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.userId,
    required this.createdAt,
    this.categoryId,
    this.reminderTime,
    this.isReminderActive,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.title: title,
      FirestoreConstants.description: description,
      FirestoreConstants.completed: completed,
      FirestoreConstants.userId: userId,
      FirestoreConstants.createdAt: Timestamp.fromDate(createdAt),
      if (categoryId != null) FirestoreConstants.categoryId: categoryId,
      if (reminderTime != null)
        FirestoreConstants.reminderTime: Timestamp.fromDate(reminderTime!),
      if (isReminderActive != null)
        FirestoreConstants.isReminderActive: isReminderActive,
    };
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Task document is null");
    }

    return TaskModel(
      id: doc.id,
      title: data[FirestoreConstants.title] ?? '',
      description: data[FirestoreConstants.description] ?? '',
      completed: data[FirestoreConstants.completed] ?? false,
      userId: data[FirestoreConstants.userId] ?? '',
      createdAt:
          (data[FirestoreConstants.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      categoryId: data[FirestoreConstants.categoryId]?.toString(),
      reminderTime: (data[FirestoreConstants.reminderTime] as Timestamp?)
          ?.toDate(),
      isReminderActive: data[FirestoreConstants.isReminderActive] as bool?,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? userId,
    DateTime? createdAt,
    String? categoryId,
    DateTime? reminderTime,
    bool? isReminderActive,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      reminderTime: reminderTime ?? this.reminderTime,
      isReminderActive: isReminderActive ?? this.isReminderActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    completed,
    userId,
    createdAt,
    categoryId,
    reminderTime,
    isReminderActive,
  ];
}
