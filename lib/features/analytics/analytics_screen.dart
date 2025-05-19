import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../tasks/task_service.dart';
import '../../core/models/task_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final tasksAsyncValue = ref.watch(personalTasksProvider(userId));
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
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
      body: tasksAsyncValue.when(
        data: (tasks) {
          // Calculate statistics
          final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
          final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
          final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).length;
          final totalTasks = tasks.length;
          
          // Calculate completion rate
          final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;
          
          // Group tasks by priority
          final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.high).length;
          final mediumPriorityTasks = tasks.where((t) => t.priority == TaskPriority.medium).length;
          final lowPriorityTasks = tasks.where((t) => t.priority == TaskPriority.low).length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                _buildSummaryCard(context, completedTasks, inProgressTasks, todoTasks, completionRate),
                const SizedBox(height: 24),
                
                // Task completion chart
                Text(
                  'Task Completion',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildCompletionChart(context, completedTasks, inProgressTasks, todoTasks),
                const SizedBox(height: 24),
                
                // Priority distribution
                Text(
                  'Priority Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPriorityDistribution(
                  context, 
                  highPriorityTasks, 
                  mediumPriorityTasks, 
                  lowPriorityTasks,
                ),
                const SizedBox(height: 24),
                
                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivity(context, tasks),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading analytics: $error'),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int completedTasks,
    int inProgressTasks,
    int todoTasks,
    int completionRate,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  'Completed',
                  completedTasks.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'In Progress',
                  inProgressTasks.toString(),
                  Icons.pending_outlined,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'To Do',
                  todoTasks.toString(),
                  Icons.assignment_outlined,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion Rate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: completionRate / 100,
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
                  '$completionRate%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(
    BuildContext context,
    int completedTasks,
    int inProgressTasks,
    int todoTasks,
  ) {
    final total = completedTasks + inProgressTasks + todoTasks;
    final completedWidth = total > 0 ? completedTasks / total : 0.0;
    final inProgressWidth = total > 0 ? inProgressTasks / total : 0.0;
    final todoWidth = total > 0 ? todoTasks / total : 0.0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart
            Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (completedWidth * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(12),
                          right: Radius.circular(
                            inProgressWidth == 0 && todoWidth == 0 ? 12 : 0,
                          ),
                        ),
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (inProgressWidth * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(completedWidth == 0 ? 12 : 0),
                          right: Radius.circular(todoWidth == 0 ? 12 : 0),
                        ),
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (todoWidth * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(
                            completedWidth == 0 && inProgressWidth == 0 ? 12 : 0,
                          ),
                          right: const Radius.circular(12),
                        ),
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(context, 'Completed', Colors.green),
                _buildLegendItem(context, 'In Progress', Colors.orange),
                _buildLegendItem(context, 'To Do', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPriorityDistribution(
    BuildContext context,
    int highPriority,
    int mediumPriority,
    int lowPriority,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriorityBar(
              context,
              'High',
              highPriority,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildPriorityBar(
              context,
              'Medium',
              mediumPriority,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPriorityBar(
              context,
              'Low',
              lowPriority,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBar(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Container(
                  width: count > 0 ? 100.0 : 0, // Fixed width for visualization
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<TaskModel> tasks) {
    // Sort tasks by creation date, most recent first
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Take only the 5 most recent tasks
    final recentTasks = sortedTasks.take(5).toList();
    
    if (recentTasks.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No recent activity'),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentTasks.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final task = recentTasks[index];
          return ListTile(
            leading: _getActivityIcon(task),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(task.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: _getPriorityBadge(context, task.priority),
          );
        },
      ),
    );
  }

  Widget _getActivityIcon(TaskModel task) {
    IconData icon;
    Color color;
    
    switch (task.status) {
      case TaskStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TaskStatus.inProgress:
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case TaskStatus.todo:
        icon = Icons.assignment;
        color = Colors.blue;
        break;
    }
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _getPriorityBadge(BuildContext context, TaskPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        label = 'HIGH';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'MED';
        break;
      case TaskPriority.low:
        color = Colors.green;
        label = 'LOW';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}