import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import '../constants/firestore_constants.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;
  final auth.FirebaseAuth firebaseAuth;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryProvider({
    required this.firebaseFirestore,
    required this.firebaseAuth,
  });

  Future<void> fetchCategories() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(user.uid)
          .collection(FirestoreConstants.pathCategoriesCollection)
          .get();

      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromDocument(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(String name, String color) async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final newCategory = CategoryModel(
        id: '',
        name: name,
        color: color,
        userId: user.uid,
      );

      await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(user.uid)
          .collection(FirestoreConstants.pathCategoriesCollection)
          .add(newCategory.toJson());

      await fetchCategories();
    } catch (e) {
      debugPrint("Error adding category: $e");
      rethrow;
    }
  }

  Future<void> updateCategory(
    String categoryId, {
    String? name,
    String? color,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates[FirestoreConstants.categoryName] = name;
      if (color != null) updates[FirestoreConstants.categoryColor] = color;

      if (updates.isNotEmpty) {
        await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebaseAuth.currentUser!.uid)
            .collection(FirestoreConstants.pathCategoriesCollection)
            .doc(categoryId)
            .update(updates);
        await fetchCategories();
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      debugPrint(
        "Attempting to delete category: $categoryId for user: ${firebaseAuth.currentUser!.uid}",
      );

      final tasksSnapshot = await firebaseFirestore
          .collection(FirestoreConstants.pathTasksCollection)
          .where(FirestoreConstants.categoryId, isEqualTo: categoryId)
          .where(
            FirestoreConstants.userId,
            isEqualTo: firebaseAuth.currentUser!.uid,
          )
          .get();

      debugPrint(
        "Found ${tasksSnapshot.docs.length} tasks with categoryId: $categoryId",
      );

      if (tasksSnapshot.docs.isNotEmpty) {
        for (var task in tasksSnapshot.docs) {
          debugPrint("Updating task ${task.id} to remove categoryId");
          await firebaseFirestore
              .collection(FirestoreConstants.pathTasksCollection)
              .doc(task.id)
              .update({FirestoreConstants.categoryId: null});
        }
      }

      debugPrint("Deleting category $categoryId from Firestore");
      await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(firebaseAuth.currentUser!.uid)
          .collection(FirestoreConstants.pathCategoriesCollection)
          .doc(categoryId)
          .delete();

      await fetchCategories();
      debugPrint("Category $categoryId deleted successfully");
    } catch (e) {
      debugPrint("Error deleting category: $e");
      rethrow;
    }
  }
}
