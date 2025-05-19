import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CommentModel {
  final String id;
  final String taskId;
  final String text;
  final DateTime createdAt;
  final String createdBy;
  final String? createdByName;
  final String? createdByPhotoUrl;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.text,
    required this.createdAt,
    required this.createdBy,
    this.createdByName,
    this.createdByPhotoUrl,
  });

  factory CommentModel.create({
    required String taskId,
    required String text,
    required String createdBy,
    String? createdByName,
    String? createdByPhotoUrl,
  }) {
    return CommentModel(
      id: const Uuid().v4(),
      taskId: taskId,
      text: text,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      createdByName: createdByName,
      createdByPhotoUrl: createdByPhotoUrl,
    );
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'],
      createdByPhotoUrl: data['createdByPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByPhotoUrl': createdByPhotoUrl,
    };
  }

  CommentModel copyWith({
    String? id,
    String? taskId,
    String? text,
    DateTime? createdAt,
    String? createdBy,
    String? createdByName,
    String? createdByPhotoUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByPhotoUrl: createdByPhotoUrl ?? this.createdByPhotoUrl,
    );
  }
}