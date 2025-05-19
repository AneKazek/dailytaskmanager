import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final List<String> members;
  final List<String> taskIds;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.members,
    required this.taskIds,
  });

  factory ProjectModel.create({
    required String name,
    required String description,
    required String createdBy,
  }) {
    return ProjectModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      members: [createdBy],
      taskIds: [],
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      taskIds: List<String>.from(data['taskIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'members': members,
      'taskIds': taskIds,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    List<String>? members,
    List<String>? taskIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      taskIds: taskIds ?? this.taskIds,
    );
  }

  bool isMember(String userId) {
    return members.contains(userId);
  }

  ProjectModel addMember(String userId) {
    if (members.contains(userId)) return this;
    return copyWith(members: [...members, userId]);
  }

  ProjectModel removeMember(String userId) {
    if (userId == createdBy) return this; // Can't remove creator
    return copyWith(members: members.where((id) => id != userId).toList());
  }

  ProjectModel addTask(String taskId) {
    return copyWith(taskIds: [...taskIds, taskId]);
  }

  ProjectModel removeTask(String taskId) {
    return copyWith(taskIds: taskIds.where((id) => id != taskId).toList());
  }
}