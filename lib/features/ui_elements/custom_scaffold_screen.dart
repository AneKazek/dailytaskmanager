import 'package:flutter/material.dart';

class CustomScaffoldScreen extends StatefulWidget {
  const CustomScaffoldScreen({super.key});

  @override
  State<CustomScaffoldScreen> createState() => _CustomScaffoldScreenState();
}

class _CustomScaffoldScreenState extends State<CustomScaffoldScreen> {
  int _selectedIndex = 0; // 0: Home, 1: Chat, 2: Add, 3: Notifications, 4: Profile

  void _onItemTapped(int index) {
    // Special handling for the central Add button if it's part of the tappable items
    // For this design, the FAB is separate, so this handles the four main icons.
    if (index == 2) { // Index 2 is the conceptual position of FAB, not a direct tap target here
      // Handle FAB tap action, e.g., show a dialog or navigate
      print('Add button tapped');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic or state update based on index
    // For example:
    // if (index == 0) print('Home tapped');
    // else if (index == 1) print('Chat tapped');
    // else if (index == 3) print('Notifications tapped');
    // else if (index == 4) print('Profile tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0, // Common to have no shadow if background is white
      ),
      body: Center(
        // Placeholder for the screen content based on _selectedIndex
        child: Text('Selected Page: ${_selectedIndexToPageName()}'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the central '+' button
          print('Central Add FAB tapped');
          // This could navigate to a new screen or show a modal, etc.
        },
        backgroundColor: const Color(0xFF4CAF50), // Green background to match the image
        foregroundColor: Colors.white, // White icon color
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF4CAF50), // Green background to match the image
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0, // Margin for the FAB notch
        elevation: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(iconData: Icons.home_outlined, selectedIconData: Icons.home, index: 0, label: 'Home'),
            _buildNavItem(iconData: Icons.description_outlined, selectedIconData: Icons.description, index: 1, label: 'Tasks'),
            const SizedBox(width: 48), // Placeholder for the FAB
            _buildNavItem(iconData: Icons.notifications_none_outlined, selectedIconData: Icons.notifications, index: 3, label: 'Notifications'),
            _buildNavItem(iconData: Icons.person_outline, selectedIconData: Icons.person, index: 4, label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData iconData,
    required IconData selectedIconData,
    required int index,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? selectedIconData : iconData,
        color: Colors.white, // Icon color for bottom nav items
        size: 28, // Adjust size as needed
      ),
      tooltip: label,
      onPressed: () => _onItemTapped(index),
    );
  }

  String _selectedIndexToPageName() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Tasks';
      // Index 2 is FAB, not a page
      case 3:
        return 'Notifications';
      case 4:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }
}