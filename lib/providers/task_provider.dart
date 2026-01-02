import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/firestore_constants.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth firebaseAuth;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;
  String _sortBy = 'createdAt';
  String get sortBy => _sortBy;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  TaskProvider({required this.firebaseFirestore, required this.firebaseAuth});

  void setSortBy(String value) {
    _sortBy = value;
    notifyListeners();
    fetchTasks();
  }

  Future<void> fetchTasks({String? categoryId, bool? completedFilter}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      _errorMessage = 'User not logged in';
      _tasks = [];
      notifyListeners();
      return;
    }

    try {
      debugPrint(
        "Fetching tasks for user: ${user.uid}, categoryId: $categoryId, completedFilter: $completedFilter, sortBy: $_sortBy",
      );
      Query query = firebaseFirestore
          .collection(FirestoreConstants.pathTasksCollection)
          .where(FirestoreConstants.userId, isEqualTo: user.uid);

      if (categoryId != null) {
        debugPrint("Applying category filter: $categoryId");
        query = query.where(
          FirestoreConstants.categoryId,
          isEqualTo: categoryId,
        );
      }
      if (completedFilter != null) {
        debugPrint("Applying completed filter: $completedFilter");
        query = query.where(
          FirestoreConstants.completed,
          isEqualTo: completedFilter,
        );
      }
      query = query.orderBy(
        _sortBy == 'reminderTime'
            ? FirestoreConstants.reminderTime
            : FirestoreConstants.createdAt,
        descending: true,
      );

      final snapshot = await query.get();
      _tasks = snapshot.docs.map((doc) {
        debugPrint("Task fetched: ${doc.id}, data: ${doc.data()}");
        return TaskModel.fromDocument(doc);
      }).toList();
      debugPrint("Fetched ${_tasks.length} tasks successfully");
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      _errorMessage = 'Failed to fetch tasks: $e';
      _tasks = [];
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    String? categoryId,
    DateTime? reminderTime,
    bool? isReminderActive,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final newTask = TaskModel(
        id: '',
        title: title,
        description: description,
        completed: false,
        userId: user.uid,
        createdAt: DateTime.now(),
        categoryId: categoryId,
        reminderTime: reminderTime,
        isReminderActive: isReminderActive,
      );

      debugPrint("Adding task: ${newTask.toJson()}");
      await firebaseFirestore
          .collection(FirestoreConstants.pathTasksCollection)
          .add(newTask.toJson());
      debugPrint("Task added successfully");

      await fetchTasks();
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }

  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    bool? completed,
    String? categoryId,
    DateTime? reminderTime,
    bool? isReminderActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) {
        updates[FirestoreConstants.title] = title;
      }
      if (description != null) {
        updates[FirestoreConstants.description] = description;
      }
      if (completed != null) {
        updates[FirestoreConstants.completed] = completed;
      }
      if (categoryId != null) {
        updates[FirestoreConstants.categoryId] = categoryId;
      }
      if (reminderTime != null) {
        updates[FirestoreConstants.reminderTime] = Timestamp.fromDate(
          reminderTime,
        );
      }
      if (isReminderActive != null) {
        updates[FirestoreConstants.isReminderActive] = isReminderActive;
      }

      if (updates.isNotEmpty) {
        debugPrint("Updating task: $taskId, updates: $updates");
        await firebaseFirestore
            .collection(FirestoreConstants.pathTasksCollection)
            .doc(taskId)
            .update(updates);
        debugPrint("Task updated successfully");
        await fetchTasks();
      }
    } catch (e) {
      debugPrint("Error updating task: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      debugPrint("Deleting task: $taskId");
      await firebaseFirestore
          .collection(FirestoreConstants.pathTasksCollection)
          .doc(taskId)
          .delete();
      debugPrint("Task deleted successfully");
      await fetchTasks();
    } catch (e) {
      debugPrint("Error deleting task: $e");
      rethrow;
    }
  }
}
