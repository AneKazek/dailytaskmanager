import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, completed }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String createdBy;
  final List<String> attachments;
  final int position;
  final bool isPersonal;
  final String? projectId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.createdBy,
    required this.attachments,
    required this.position,
    required this.isPersonal,
    this.projectId,
  });

  factory TaskModel.create({
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskPriority priority,
    required String createdBy,
    required bool isPersonal,
    String? projectId,
    int position = 0,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
      createdBy: createdBy,
      attachments: [],
      position: position,
      isPersonal: isPersonal,
      projectId: projectId,
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${data['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${data['status']}',
        orElse: () => TaskStatus.todo,
      ),
      createdBy: data['createdBy'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      position: data['position'] ?? 0,
      isPersonal: data['isPersonal'] ?? true,
      projectId: data['projectId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdBy': createdBy,
      'attachments': attachments,
      'position': position,
      'isPersonal': isPersonal,
      'projectId': projectId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? createdBy,
    List<String>? attachments,
    int? position,
    bool? isPersonal,
    String? projectId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      attachments: attachments ?? this.attachments,
      position: position ?? this.position,
      isPersonal: isPersonal ?? this.isPersonal,
      projectId: projectId ?? this.projectId,
    );
  }
}