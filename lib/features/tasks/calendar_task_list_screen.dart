import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_task_screen.dart'; // Make sure this import is correct

class CalendarTaskListScreen extends StatefulWidget { // Screen B - Updated
  const CalendarTaskListScreen({super.key});

  @override
  State<CalendarTaskListScreen> createState() => _CalendarTaskListScreenState();
}

class _CalendarTaskListScreenState extends State<CalendarTaskListScreen> {
  DateTime _selectedDate = DateTime(2020, 10, 4); // Mockup: Oct 4, 2020 (Tuesday)
  late DateTime _firstDayOfWeek;

  @override
  void initState() {
    super.initState();
    // Calculate the first day of the week (Monday) for the selectedDate
    _firstDayOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
  }

  // Helper to format month and year
  String _formatMonthYear(DateTime date) {
    // Using intl package for more robust date formatting would be better in a real app.
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background
      appBar: AppBar(
        backgroundColor: colorScheme.background, // Match scaffold background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87), // Back arrow on left
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            // else if main.dart handles this screen via bottom nav, this might not be needed
            // or should pop to the root of this tab's navigator if nested navigation is used.
          },
          tooltip: 'Back',
        ),
        title: Text(
          _formatMonthYear(_selectedDate), // Large header "Oct, 2020"
          style: GoogleFonts.roboto(
            fontSize: 24, // Roboto, 24 sp, bold
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineMedium?.color ?? Colors.black87,
          ),
        ),
        centerTitle: false, // Title aligned to start as per mockup (after back arrow)
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87), // Search icon on right
            onPressed: () {
              // TODO: Handle search action
            },
            tooltip: 'Search Tasks',
          ),
          const SizedBox(width: 8), // Spacing for the right icon
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The month/year header is now part of the AppBar title
          // const SizedBox(height: 8), // Remove if header is in AppBar

          // Weekday selector and Add Task button row
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0), // Top padding for this row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Weekday selector will take available space, or we can wrap it if it's too wide
                // For now, let's assume it fits. If not, the Add Task button might need to be positioned differently.
                // The mockup shows the "Oct, 2020" above the weekday selector, and "+ Add Task" to its right.
                // Since "Oct, 2020" is now in AppBar, we adjust.
                // Let's put the Add Task button to the right of the screen, and calendar below the AppBar.
                const Spacer(), // Pushes Add Task button to the right if no other element is on the left
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Create Task Screen (Screen C)
                    // This should use the method from main.dart if possible, or a direct push.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateTaskScreen()), // Assuming CreateTaskScreen is imported
                    );
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: Text('Add Task', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Purple
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Pill button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Pill shape
                    ),
                    elevation: 1,
                  ),
                ),
              ],
            ),
          ),
          _buildWeekDaySelector(context, theme, colorScheme),
          const SizedBox(height: 24), // Space after calendar before tasks list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Tasks', // Section title for tasks
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color ?? Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: 4, // Example number of tasks
              itemBuilder: (context, index) {
                return _buildTaskListItem(
                  context, theme, colorScheme,
                  title: 'Design Changes',
                  daysAgo: '2 Days ago',
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final List<String> weekDayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
        children: List.generate(7, (index) {
          final currentDate = _firstDayOfWeek.add(Duration(days: index));
          final isSelected = currentDate.year == _selectedDate.year &&
                             currentDate.month == _selectedDate.month &&
                             currentDate.day == _selectedDate.day;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    _selectedDate = currentDate;
                    // If the week should change when a day in a different week is tapped:
                    // _firstDayOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekDayLabels[index],
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: isSelected ? colorScheme.primary : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32, // Slightly larger for better tapability and visual balance
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent, // Purple fill for selected
                      shape: BoxShape.circle, // Circle highlight
                      border: isSelected ? null : Border.all(color: Colors.grey[300]!, width: 1), // Subtle border for unselected days
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${currentDate.day}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: isSelected ? Colors.white : (theme.textTheme.bodyMedium?.color ?? Colors.black87), // White text on purple
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskListItem(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required String title, required String daysAgo}) {
    return Card(
      elevation: 2, // Subtle elevation as per mockup
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 12 dp radius
      ),
      color: Colors.white, // White cards
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 8dp internal padding
        leading: Container(
          width: 40, 
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary, // Purple square icon background
            borderRadius: BorderRadius.circular(8), // Rounded square as per mockup (purple square icon)
          ),
          child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20), // Mockup shows a calendar-like icon
        ),
        title: Text(
          title, // "Design Changes"
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black87,
          ),
        ),
        subtitle: Text(
          daysAgo, // "2 Days ago"
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[500]), // Right-aligned overflow menu icon
          onPressed: () {
            // TODO: Handle overflow menu action (e.g., show a PopupMenuButton)
          },
          tooltip: 'More options',
        ),
      ),
    );
  }
}

// Ensure CreateTaskScreen is imported if not already
// import 'create_task_screen.dart'; // Or the correct path