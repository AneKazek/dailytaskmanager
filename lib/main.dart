import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Will be used for Roboto
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons if needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_service.dart';
import 'features/tasks/task_service.dart';
// import 'features/tasks/task_detail_screen.dart'; // May not be needed directly in main
// import 'features/tasks/create_task_dialog.dart'; // Will be replaced by a dedicated screen or updated dialog
// import 'features/projects/collaborative_projects_screen.dart'; // To be replaced by new Projects/Dashboard screen
import 'features/analytics/analytics_screen.dart';
// import 'features/profile/profile_screen.dart'; // Profile screen might be accessed differently or integrated into new design

import 'features/home/home_dashboard_screen.dart'; // Screen A
import 'features/tasks/calendar_task_list_screen.dart'; // Screen B
import 'features/tasks/create_task_screen.dart'; // Screen C

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DailyTaskManager();
  }
}

class DailyTaskManager extends ConsumerWidget {
  const DailyTaskManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider); // Uncomment untuk menangani navigasi berdasarkan status auth
    
    return MaterialApp(
      // Removed duplicate home parameter
      title: 'Daily Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2), // Purple from gradient
          primary: const Color(0xFF8A2BE2),    // Purple
          secondary: const Color(0xFF4B0082),   // Blue from gradient (or a contrasting accent)
          // Define gradient colors for reuse
          // gradientStart: const Color(0xFF8A2BE2), // Purple
          // gradientEnd: const Color(0xFF4B0082),   // Dark Blue
          error: Colors.redAccent,
          background: Colors.white,           // White background
          surface: Colors.white,              // White for cards/surfaces
          onPrimary: Colors.white,            // Text on primary
          onSecondary: Colors.black,           // Text on secondary
          onBackground: Colors.black,         // Text on background
          onSurface: Colors.black,            // Text on surface
          brightness: Brightness.light,
        ),
        // Primary Font: Roboto
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme.copyWith(
                displayLarge: const TextStyle(color: Colors.black),
                displayMedium: const TextStyle(color: Colors.black),
                displaySmall: const TextStyle(color: Colors.black),
                headlineLarge: const TextStyle(color: Colors.black),
                headlineMedium: const TextStyle(color: Colors.black),
                headlineSmall: const TextStyle(color: Colors.black),
                titleLarge: const TextStyle(color: Colors.black),
                titleMedium: const TextStyle(color: Colors.black),
                titleSmall: const TextStyle(color: Colors.black),
                bodyLarge: const TextStyle(color: Colors.black87),
                bodyMedium: const TextStyle(color: Colors.black87),
                bodySmall: const TextStyle(color: Colors.black54),
                labelLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                labelMedium: const TextStyle(color: Colors.black54),
                labelSmall: const TextStyle(color: Colors.black54),
              )
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true, // Titles are often centered in the reference
          iconTheme: const IconThemeData(color: Colors.black), // Ensure icons are visible
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18, // Adjusted for a cleaner look
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFF3A3D40), // Dark Grey for selected items
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.roboto(),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF8A2BE2), // Purple FAB
          foregroundColor: Colors.white, // White icon on FAB
        ),
        cardTheme: CardTheme(
          elevation: 0, // Cards in reference often have no elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Consistent rounded corners
          ),
          color: Colors.white, // Default card color
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200], // Light grey fill for text fields, consistent with design
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // No border by default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF8A2BE2)), // Primary color border on focus
          ),
          hintStyle: GoogleFonts.roboto(color: Colors.grey[500]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A2BE2), // Purple for main buttons (or gradient)
            foregroundColor: Colors.white, // Text color on purple buttons
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Adjusted padding
            textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold), // Roboto bold
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8A2BE2), // Primary color for text buttons
            textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          )
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const MainAppScreen() : const LoginScreen(), // Changed to MainAppScreen
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}

// Placeholder for the new main application screen with bottom navigation
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0; // Tracks the current page for PageView and BottomNavBar
  // int _selectedIndex = 0; // Replaced by _currentPageIndex

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeDashboardScreen(),    // Screen A: Projects (Home/Dashboard) - Page 0
    const CalendarTaskListScreen(), // Screen B: Analytics (Calendar + Task List) - Page 1
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int navBarIndex) {
    if (navBarIndex == 1) { // Middle item is FAB
      _showAddTaskScreen();
      return;
    }
    // Determine the target page index for PageView
    int targetPageIndex = navBarIndex > 1 ? navBarIndex - 1 : navBarIndex;
    _pageController.animateToPage(
      targetPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // No need to call setState here for _currentPageIndex, as onPageChanged will handle it.
  }

  void _showAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()), // Navigate to Screen C
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _widgetOptions,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskScreen,
        shape: const CircleBorder(),
        elevation: 2.0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Margin for the FAB notch
        color: Colors.white,
        elevation: 8.0, // Standard elevation for BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home, label: 'Projects', index: 0),
            // Central FAB takes up space, so we add a SizedBox or similar for spacing
            const SizedBox(width: 48), // Placeholder for FAB space
            _buildNavItem(icon: Icons.bar_chart, label: 'Analytics', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int navBarIndex}) {
    // Determine the page index this nav item corresponds to
    int targetPageIndex = navBarIndex > 1 ? navBarIndex - 1 : navBarIndex;
    final bool isSelected = (_currentPageIndex == targetPageIndex);
    
    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[500]),
      tooltip: label,
      onPressed: () => _onItemTapped(navBarIndex),
    );
  }
}
    );
  }
}

// The old PersonalTasksScreen and its helper methods are removed as they will be replaced by the new design.
// Ensure that any dependencies on these (like _buildSectionTitle, _buildOngoingProjectItem) are also removed or refactored
// if they were used by other parts of the app that are being kept.
