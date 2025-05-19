import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/task_model.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

final personalTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, userId) {
  return ref.watch(taskServiceProvider).getPersonalTasks(userId);
});

final projectTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, projectId) {
  return ref.watch(taskServiceProvider).getProjectTasks(projectId);
});

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create a new task
  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = _firestore.collection('tasks').doc(task.id);
      await docRef.set(task.toMap());
      
      // If it's a project task, update the project document
      if (!task.isPersonal && task.projectId != null) {
        await _firestore.collection('projects').doc(task.projectId).update({
          'taskIds': FieldValue.arrayUnion([task.id]),
        });
      }
      
      return task.id;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get a single task by ID
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) return null;
      
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all personal tasks for a user
  Stream<List<TaskModel>> getPersonalTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('createdBy', isEqualTo: userId)
        .where('isPersonal', isEqualTo: true)
        .orderBy('position')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get all tasks for a project
  Stream<List<TaskModel>> getProjectTasks(String projectId) {
    return _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .where('isPersonal', isEqualTo: false)
        .orderBy('position')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete a task
  Future<void> deleteTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).delete();
      
      // If it's a project task, update the project document
      if (!task.isPersonal && task.projectId != null) {
        await _firestore.collection('projects').doc(task.projectId).update({
          'taskIds': FieldValue.arrayRemove([task.id]),
        });
      }
      
      // Delete all comments for this task
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('taskId', isEqualTo: task.id)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update task positions (for drag and drop reordering)
  Future<void> updateTaskPositions(List<TaskModel> tasks) async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i].copyWith(position: i);
        batch.update(
          _firestore.collection('tasks').doc(task.id),
          {'position': i},
        );
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  // Add attachment to task
  Future<void> addAttachment(String taskId, String attachmentUrl) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'attachments': FieldValue.arrayUnion([attachmentUrl]),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Remove attachment from task
  Future<void> removeAttachment(String taskId, String attachmentUrl) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'attachments': FieldValue.arrayRemove([attachmentUrl]),
      });
    } catch (e) {
      rethrow;
    }
  }
}