import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int _selectedDayIndex = 4; // Default to Thursday (index 4)
  final List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<int> _dates = [24, 25, 26, 27, 28, 29, 30]; // Example dates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personal tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekdaySelector(),
          const SizedBox(height: 16),
          _buildTasksHeader(),
          Expanded(
            child: _buildTaskTimeline(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          7,
          (index) => _buildDayItem(index),
        ),
      ),
    );
  }

  Widget _buildDayItem(int index) {
    final isSelected = index == _selectedDayIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdays[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dates[index].toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today, size: 16),
            label: const Text('Timeline'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTimeline() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTimelineItem(
          time: '9:00 am',
          title: 'Go for a walk with dog',
          timeRange: '9:00 - 10:00 am',
          color: Colors.red[100]!,
          dotColor: Colors.red,
        ),
        _buildTimelineSpacer('10:00 am'),
        _buildTimelineItem(
          time: '11:00 am',
          title: 'Shot on Dribbble',
          timeRange: '11:00 - 12:00 am',
          color: Colors.blue[100]!,
          dotColor: Colors.blue,
        ),
        _buildTimelineSpacer('12:00 am'),
        _buildTimelineSpacer('1:00 pm'),
        _buildTimelineItem(
          time: '2:00 pm',
          title: 'Call with client',
          timeRange: '2:00 - 3:00 pm',
          color: Colors.orange[100]!,
          dotColor: Colors.orange,
        ),
        _buildTimelineSpacer('3:00 pm'),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String timeRange,
    required Color color,
    required Color dotColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            time,
            style: TextStyle(
              color: dotColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 20,
          height: 80,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeRange,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSpacer(String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            time,
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 20,
          height: 40,
          alignment: Alignment.topCenter,
          child: Container(
            width: 2,
            height: 40,
            color: Colors.grey[300],
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}