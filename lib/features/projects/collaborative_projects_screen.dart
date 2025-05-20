import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/task_model.dart';
import '../tasks/create_task_dialog.dart';
import 'project_detail_screen.dart';
import 'create_project_dialog.dart';
import 'project_service.dart';

class CollaborativeProjectsScreen extends ConsumerWidget {
  // Helper to generate placeholder avatar images (replace with actual logic)
  List<String> _getPlaceholderAvatars(int count) {
    return List.generate(count, (index) => 'assets/avatar_${index + 1}.png');
  }

  const CollaborativeProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final projectsAsyncValue = ref.watch(userProjectsProvider(userId));
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Projects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: projectsAsyncValue.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_work_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new project to collaborate with your team',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateProjectDialog(context, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _buildProjectCard(context, project, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading projects: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context, userId),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, WidgetRef ref) {
    final progressValue = project.taskCount > 0
        ? (project.completedTaskCount / project.taskCount)
        : 0.0;
    final progressPercentage = (progressValue * 100).toInt();
    // Placeholder for due date and team images, adapt ProjectModel if these exist
    const String dueDate = "25 Dec"; // Example due date
    final List<String> teamMemberImages = _getPlaceholderAvatars(project.memberIds.length > 0 ? project.memberIds.length : 3);

    return Card(
      // Using theme's cardTheme for consistency, but can override here if needed
      // color: Theme.of(context).colorScheme.surface, // or a light tint of primary
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // from theme
      elevation: 0, // from theme
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailScreen(projectId: project.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Team member icons (placeholder)
                  if (teamMemberImages.isNotEmpty)
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: List.generate(teamMemberImages.take(3).length, (i) {
                          return Positioned(
                            left: (i * 16).toDouble(), // Overlapping effect
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[300],
                              // child: Text(teamMemberImages[i][0]), // Placeholder with initial
                              child: const Icon(Icons.person, size: 14, color: Colors.white), // Generic icon
                            ),
                          );
                        }),
                      ),
                    ),
                  if (teamMemberImages.length > 3)
                    Padding(
                      padding: EdgeInsets.only(left: (3 * 16) + 4.0),
                      child: Text('+${teamMemberImages.length - 3}', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  const Spacer(),
                  Text(
                    dueDate, // Placeholder due date
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar and Percentage
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Rounded corners for the progress bar itself
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), // Yellow accent
                        minHeight: 6, // Slightly thicker progress bar
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progressPercentage%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary, // Yellow accent
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProjectColor(String projectName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    
    // Simple hash function to get a consistent color for the same project name
    final hashCode = projectName.hashCode.abs();
    return colors[hashCode % colors.length];
  }

  void _showCreateProjectDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(userId: userId),
    );
  }
}