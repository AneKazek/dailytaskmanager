import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/task_model.dart';
import '../tasks/create_task_dialog.dart';
import '../tasks/task_service.dart';
import 'project_service.dart';

class ProjectDetailScreen extends ConsumerWidget {
  // Helper to generate placeholder avatar images (replace with actual logic)
  List<String> _getPlaceholderAvatars(int count) {
    return List.generate(count, (index) => 'assets/avatar_${index + 1}.png');
  }

  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsyncValue = ref.watch(projectProvider(projectId));
    final tasksAsyncValue = ref.watch(projectTasksProvider(projectId));
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20), // Updated icon
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task Details', // Title from reference
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24), // Updated icon from reference
            onPressed: () {
              // Handle more options
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: projectAsyncValue.when(
        data: (project) {
          if (project == null) {
            return const Center(child: Text('Project not found'));
          }
          // Using placeholder data for UI matching reference image
          const String projectTitle = "Real Estate App Design";
          const String projectDueDate = "30 June";
          final List<String> teamMemberAvatars = _getPlaceholderAvatars(3);
          const double projectProgress = 0.7; // 70%

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                project.name, // Or projectTitle for matching reference
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildMetaInfo(context, icon: Icons.calendar_today_outlined, text: projectDueDate, iconColor: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 8),
              _buildTeamMembersRow(context, teamMemberAvatars),
              const SizedBox(height: 24),
              Text(
                'Project Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                project.description, // Actual project description
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              _buildProgressSection(context, projectProgress),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () { 
                       showDialog(
                        context: context,
                        builder: (context) => CreateTaskDialog(
                          userId: userId,
                          projectId: projectId,
                          isPersonal: false,
                        ),
                      );
                    },
                    icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
                    label: Text('Add New', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              tasksAsyncValue.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks yet. Add one!'));
                  }
                  return Column(
                    children: tasks.map((task) => _buildTaskListItem(context, task, ref)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading project: $error'),
        ),
      ),
      // FAB can be removed if 'Add New' text button is preferred as per reference
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateTaskDialog(
              userId: userId,
              projectId: projectId,
              isPersonal: false,
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),*/
    );
  }

  Widget _buildMetaInfo(BuildContext context, {required IconData icon, required String text, Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildTeamMembersRow(BuildContext context, List<String> avatars) {
    return Row(
      children: [
        Text('Team: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
        const SizedBox(width: 8),
        SizedBox(
          height: 30,
          child: Stack(
            children: List.generate(avatars.take(3).length, (i) {
              return Positioned(
                left: (i * 20).toDouble(), // Overlapping effect
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey[300],
                  // In a real app, load NetworkImage(avatars[i]) or AssetImage
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
              );
            }),
          ),
        ),
        if (avatars.length > 3)
          Padding(
            padding: EdgeInsets.only(left: (3 * 20) + 4.0),
            child: Text('+${avatars.length - 3}', style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), // Yellow accent
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary, // Yellow accent
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskListItem(BuildContext context, TaskModel task, WidgetRef ref) {
    // Placeholder for team members assigned to this task
    final List<String> taskTeamAvatars = _getPlaceholderAvatars(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Theme( // Custom theme for checkbox to match yellow accent
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.grey[400], // Border color when unchecked
            ),
            child: Checkbox(
              value: task.status == TaskStatus.completed,
              onChanged: (value) {
                final newStatus = value == true ? TaskStatus.completed : TaskStatus.todo;
                final updatedTask = task.copyWith(status: newStatus);
                ref.read(taskServiceProvider).updateTask(updatedTask);
              },
              activeColor: Theme.of(context).colorScheme.secondary, // Yellow accent for checkmark
              checkColor: Colors.black, // Checkmark color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: task.status == TaskStatus.completed ? Theme.of(context).colorScheme.secondary : Colors.grey[400]!, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.status == TaskStatus.completed
                        ? Colors.grey[600]
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          // Placeholder for task-specific team avatars
          if (taskTeamAvatars.isNotEmpty)
            SizedBox(
              height: 24,
              child: Stack(
                children: List.generate(taskTeamAvatars.take(2).length, (i) { // Show max 2 for task item
                  return Positioned(
                    left: (i * 16).toDouble(),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[400],
                      child: const Icon(Icons.person, size: 14, color: Colors.white),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // _buildProjectInfoCard, _buildStatCard, _buildFilterButton, _buildTasksSection, _buildTaskItem are replaced or refactored.
  // The old _buildTaskItem is significantly different from the new _buildTaskListItem.
  // Keeping the old ones commented out for reference during refactoring if needed, then remove.

  /*
  Widget _buildProjectInfoCard(BuildContext context, ProjectModel project) {
    final completedPercentage = project.taskCount > 0
        ? (project.completedTaskCount / project.taskCount * 100).toInt()
        : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: project.taskCount > 0
                          ? project.completedTaskCount / project.taskCount
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$completedPercentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                context,
                'Total',
                project.taskCount.toString(),
                Icons.task_outlined,
              ),
              _buildStatCard(
                context,
                'Completed',
                project.completedTaskCount.toString(),
                Icons.check_circle_outline,
              ),
              _buildStatCard(
                context,
                'Members',
                project.memberIds.length.toString(),
                Icons.people_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list, size: 16),
      label: const Text('Filter'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, String title, List<TaskModel> tasks, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${tasks.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) => _buildTaskItem(context, task, ref)).toList(),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, WidgetRef ref) {
    final Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status checkbox
            Checkbox(
              value: task.status == TaskStatus.completed,
              onChanged: (value) {
                final newStatus = value == true ? TaskStatus.completed : TaskStatus.todo;
                final updatedTask = task.copyWith(status: newStatus);
                ref.read(taskServiceProvider).updateTask(updatedTask);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.status == TaskStatus.completed
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[                    
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Priority indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.priority.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Due date if available
                      if (task.dueDate != null) ...[                        
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Menu button
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {
                // Show task options
              },
            ),
          ],
        ),
      ),
    );
  }
  */
}

  Widget _buildProjectInfoCard(BuildContext context, ProjectModel project) {
    final completedPercentage = project.taskCount > 0
        ? (project.completedTaskCount / project.taskCount * 100).toInt()
        : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: project.taskCount > 0
                          ? project.completedTaskCount / project.taskCount
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$completedPercentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                context,
                'Total',
                project.taskCount.toString(),
                Icons.task_outlined,
              ),
              _buildStatCard(
                context,
                'Completed',
                project.completedTaskCount.toString(),
                Icons.check_circle_outline,
              ),
              _buildStatCard(
                context,
                'Members',
                project.memberIds.length.toString(),
                Icons.people_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list, size: 16),
      label: const Text('Filter'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, String title, List<TaskModel> tasks, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${tasks.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) => _buildTaskItem(context, task, ref)).toList(),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, WidgetRef ref) {
    final Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status checkbox
            Checkbox(
              value: task.status == TaskStatus.completed,
              onChanged: (value) {
                final newStatus = value == true ? TaskStatus.completed : TaskStatus.todo;
                final updatedTask = task.copyWith(status: newStatus);
                ref.read(taskServiceProvider).updateTask(updatedTask);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.status == TaskStatus.completed
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[                    
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Priority indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.priority.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Due date if available
                      if (task.dueDate != null) ...[                        
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Menu button
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {
                // Show task options
              },
            ),
          ],
        ),
      ),
    );
  }
