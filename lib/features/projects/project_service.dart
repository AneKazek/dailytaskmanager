import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

final userProjectsProvider = StreamProvider.family<List<ProjectModel>, String>((ref, userId) {
  return ref.watch(projectServiceProvider).getUserProjects(userId);
});

final projectProvider = StreamProvider.family<ProjectModel?, String>((ref, projectId) {
  return ref.watch(projectServiceProvider).getProjectStream(projectId);
});

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create a new project
  Future<String> createProject(ProjectModel project) async {
    try {
      final docRef = _firestore.collection('projects').doc(project.id);
      await docRef.set(project.toMap());
      return project.id;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get a single project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (!doc.exists) return null;
      
      return ProjectModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get a stream of a single project
  Stream<ProjectModel?> getProjectStream(String projectId) {
    return _firestore.collection('projects').doc(projectId).snapshots().map(
          (doc) => doc.exists ? ProjectModel.fromFirestore(doc) : null,
        );
  }
  
  // Get all projects for a user
  Stream<List<ProjectModel>> getUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }
  
  // Update a project
  Future<void> updateProject(ProjectModel project) async {
    try {
      await _firestore.collection('projects').doc(project.id).update(project.toMap());
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      // Delete the project document
      await _firestore.collection('projects').doc(projectId).delete();
      
      // Delete all tasks associated with this project
      final taskSnapshot = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in taskSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  // Add a member to a project
  Future<void> addMemberToProject(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Remove a member from a project
  Future<void> removeMemberFromProject(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Update project task counts
  Future<void> updateProjectTaskCounts(String projectId) async {
    try {
      final taskSnapshot = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      final totalTasks = taskSnapshot.docs.length;
      final completedTasks = taskSnapshot.docs
          .where((doc) => (doc.data()['status'] as String) == 'completed')
          .length;
      
      await _firestore.collection('projects').doc(projectId).update({
        'taskCount': totalTasks,
        'completedTaskCount': completedTasks,
      });
    } catch (e) {
      rethrow;
    }
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final List<String> memberIds;
  final int taskCount;
  final int completedTaskCount;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.memberIds,
    this.taskCount = 0,
    this.completedTaskCount = 0,
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
      memberIds: [createdBy], // Creator is automatically a member
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
      memberIds: List<String>.from(data['memberIds'] ?? []),
      taskCount: data['taskCount'] ?? 0,
      completedTaskCount: data['completedTaskCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'memberIds': memberIds,
      'taskCount': taskCount,
      'completedTaskCount': completedTaskCount,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    List<String>? memberIds,
    int? taskCount,
    int? completedTaskCount,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      memberIds: memberIds ?? this.memberIds,
      taskCount: taskCount ?? this.taskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
    );
  }
}