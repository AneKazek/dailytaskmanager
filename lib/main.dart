import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/splash_screen.dart'; // Diubah dari LoginScreen ke SplashScreen
import 'features/auth/login_screen.dart';
import 'features/auth/auth_service.dart';
import 'features/tasks/task_service.dart';
import 'features/tasks/task_detail_screen.dart';
import 'features/tasks/create_task_dialog.dart';
import 'features/projects/collaborative_projects_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/profile/profile_screen.dart';

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
      // home: authState.when( // Logika lama untuk menentukan halaman awal
      //   data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
      //   loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      //   error: (_, __) => const Scaffold(body: Center(child: Text('Something went wrong'))),
      // ),
      home: const SplashScreen(), // Atur SplashScreen sebagai halaman awal
      title: 'Daily Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A3D40), // Dark Grey as seed
          primary: const Color(0xFF3A3D40),    // Dark Grey
          secondary: const Color(0xFFF9AA33),   // Yellow Accent
          background: Colors.white,           // White background
          surface: Colors.white,              // White for cards/surfaces
          onPrimary: Colors.white,            // Text on primary
          onSecondary: Colors.black,           // Text on secondary
          onBackground: Colors.black,         // Text on background
          onSurface: Colors.black,            // Text on surface
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
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
          titleTextStyle: GoogleFonts.poppins(
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
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF3A3D40), // Dark Grey FAB
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
          fillColor: Colors.grey[100], // Light grey fill for text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // No border by default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF3A3D40)), // Primary color border on focus
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF9AA33), // Yellow accent for main buttons
            foregroundColor: Colors.black, // Text color on yellow buttons
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF3A3D40), // Primary color for text buttons
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          )
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}

// Pastikan HomeScreen ada dan diimpor jika digunakan setelah SplashScreen
// import 'features/home/home_screen.dart'; // Contoh path, sesuaikan

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Personal Tasks Screen
          const PersonalTasksScreen(),
          // Collaborative Projects Screen
          const CollaborativeProjectsScreen(),
          // Analytics Screen
          const AnalyticsScreen(),
          // Profile Screen
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show task creation dialog
          showDialog(
            context: context,
            builder: (context) => CreateTaskDialog(
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
              isPersonal: true,
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PersonalTasksScreen extends ConsumerWidget {
  const PersonalTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    // final userDisplayName = user?.displayName ?? 'User';
    // For now, using the name from reference image
    const userDisplayName = 'Fazil Laghari'; 

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button if any
        title: Text(
          userDisplayName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              // Placeholder for profile picture, replace with actual image if available
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!) 
                  : null,
              child: user?.photoURL == null 
                  ? const Icon(Icons.person, size: 20) 
                  : null,
              radius: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list), // Icon from reference
            onPressed: () {
              // Handle filter/sort action
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Completed Tasks'),
          const SizedBox(height: 16),
          // Placeholder for Horizontal Completed Tasks List
          Container(
            height: 150, // Adjust height as needed
            child: Center(
              child: Text(
                'Horizontal list of completed tasks here',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Ongoing Projects'),
          const SizedBox(height: 16),
          // Placeholder for Vertical Ongoing Projects List
          // Example of one project item, this would be a list
          _buildOngoingProjectItem(context, 
            projectName: 'Real Estate App Design',
            teamImages: ['placeholder1.png', 'placeholder2.png', 'placeholder3.png'], // Replace with actual image URLs or assets
            progress: 0.65, // 65%
            dueDate: '23 March',
          ),
          const SizedBox(height: 12),
          _buildOngoingProjectItem(context, 
            projectName: 'Smart Home App Design',
            teamImages: ['placeholder_a.png', 'placeholder_b.png'],
            progress: 0.40, // 40%
            dueDate: '10 April',
          ),
          // Add more project items or a ListView.builder here
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildOngoingProjectItem(BuildContext context, {
    required String projectName,
    required List<String> teamImages, // Placeholder for image paths/URLs
    required double progress,
    required String dueDate,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05), // Light primary color background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Team member icons (placeholder)
                Row(
                  children: teamImages.take(3).map((img) => Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      // child: Text(img.substring(0,1).toUpperCase()), // Simple placeholder
                      child: const Icon(Icons.person, size: 14, color: Colors.white), // Generic icon
                    ), 
                  )).toList(),
                ),
                if (teamImages.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text('+${teamImages.length - 3}', style: Theme.of(context).textTheme.bodySmall),
                  ),
                const Spacer(),
                Text(
                  dueDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), // Yellow accent for progress
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary, // Yellow accent
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // _buildCategoryCard and _buildAddCategoryCard are no longer needed for this design
  // and can be removed if they are not used elsewhere.
  // For now, they are kept in case they are part of other screens not yet reviewed.

  // Original _buildCategoryCard (commented out or remove if sure it's not needed)
  /*
  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required int tasksLeft,
    required int tasksDone,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskDetailScreen(),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$tasksLeft left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$tasksDone done',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
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
  */

  // Original _buildAddCategoryCard (commented out or remove if sure it's not needed)
  /*
  Widget _buildAddCategoryCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Add',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */
}
