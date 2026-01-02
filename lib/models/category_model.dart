import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/constants/constants.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String color;
  final String userId;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.categoryName: name,
      FirestoreConstants.categoryColor: color,
      FirestoreConstants.userId: userId,
    };
  }

  factory CategoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Category document is null");
    }

    return CategoryModel(
      id: doc.id,
      name: data[FirestoreConstants.categoryName] ?? '',
      color: data[FirestoreConstants.categoryColor] ?? '#FFFFFF',
      userId: data[FirestoreConstants.userId] ?? '',
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? color,
    String? userId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, name, color, userId];
}
