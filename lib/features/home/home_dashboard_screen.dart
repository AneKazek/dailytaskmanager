import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDashboardScreen extends StatefulWidget { // Screen A - Updated
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  // int _selectedTabIndex = 0; // Already defined
  // late PageController _pageController; // Already defined
  // late TabController _tabController; // Already defined
  late TabController _tabController;
  int _selectedTabIndex = 0; // 0 for "My Tasks", 1 for "In-progress", 2 for "Completed"
  final PageController _pageController = PageController(viewportFraction: 0.85); // For project cards
  int _currentProjectPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex);
    _tabController.addListener(() {
      if (mounted) { // Check if the widget is still in the tree
        if (_tabController.indexIsChanging) {
          setState(() {
            _selectedTabIndex = _tabController.index;
          });
        } else {
          if (_selectedTabIndex != _tabController.index) {
            setState(() {
              _selectedTabIndex = _tabController.index;
            });
          }
        }
      }
    });
    _pageController.addListener(() {
      if (mounted) {
        int nextPage = _pageController.page!.round();
        if (_currentProjectPage != nextPage) {
          setState(() {
            _currentProjectPage = nextPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Gradient for project cards
    const projectCardGradient = LinearGradient(
      colors: [Color(0xFF8A2BE2), Color(0xFF4B0082)], // Purple to Blue
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: colorScheme.background, // Light background as per general feel
      appBar: AppBar(
        backgroundColor: colorScheme.background, // Match scaffold background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87), // Hamburger menu icon
          onPressed: () {
            // TODO: Handle drawer opening or menu action
          },
          tooltip: 'Menu',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87, size: 28), // User/avatar icon
            onPressed: () {
              // TODO: Navigate to profile or show user options
            },
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8), // Spacing for the right icon
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Global 16dp padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8), // Adjust top spacing if needed
            // Title: "Hello Rohan!"
            Text(
              'Hello Rohan!',
              style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color ?? Colors.black87),
            ),
            // Subtitle: "Have a nice day."
            Text(
              'Have a nice day.',
              style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // Tab selector: "My Tasks", "In-progress", "Completed"
            _buildTabSelector(context, theme, colorScheme),
            const SizedBox(height: 24),

            // Horizontal page view of project cards
            SizedBox(
              height: 170, // Adjusted height as needed for project cards
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if(mounted) {
                    setState(() {
                      _currentProjectPage = index;
                    });
                  }
                },
                children: <Widget>[
                  _buildProjectCard(context, theme, colorScheme, projectNumber: 'Project 1', title: 'Front-End Development', date: 'October 4, 2020', iconData: Icons.memory, gradientColors: [const Color(0xFF8A2BE2), const Color(0xFF4B0082)] ),
                  _buildProjectCard(context, theme, colorScheme, projectNumber: 'Project 2', title: 'Back-End Development', date: 'October 4, 2020', iconData: Icons.dns, gradientColors: [const Color(0xFF8A2BE2), const Color(0xFF4B0082)]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Page indicator for project cards
            _buildPageIndicator(context, theme, colorScheme),
            const SizedBox(height: 32),

            // "Progress" section title
            Text(
              'Progress',
              style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.headlineSmall?.color ?? Colors.black87),
            ),
            const SizedBox(height: 16),

            // Vertical list of progress items
            _buildProgressListItem(context, theme, colorScheme, title: 'Design Changes', daysAgo: '2 Days ago'),
            const SizedBox(height: 12),
            _buildProgressListItem(context, theme, colorScheme, title: 'Design Changes', daysAgo: '2 Days ago'),
            const SizedBox(height: 24), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(child: _buildTabPill(context, theme, colorScheme, text: 'My Tasks', index: 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabPill(context, theme, colorScheme, text: 'In-progress', index: 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabPill(context, theme, colorScheme, text: 'Completed', index: 2)),
        ],
      ),
    );
  }

  Widget _buildTabPill(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required String text, required int index}) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          height: 40, // Ensure consistent height for tabs
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent, // Active tab filled white
            borderRadius: BorderRadius.circular(20), // Pill shape for selected tab
            border: isActive ? null : Border.all(color: Colors.grey[300]!, width: 1.5), // Outline for inactive
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal, // Mockup: active is bold
              fontSize: 13,
              color: isActive ? colorScheme.primary : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectPageView(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      height: 170, // Adjusted height to better fit content
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
            if(mounted) {
                setState(() {
                    _currentProjectPage = index;
                });
            }
        },
        children: [
          _buildProjectCard(
            context, theme, colorScheme,
            title: 'Front-End Development',
            date: 'October 4, 2020',
            projectNumber: 'Project 1',
            iconData: Icons.memory, // Brain-like icon (Material Icons 'memory' or 'psychology')
            gradientColors: [const Color(0xFF8A2BE2), const Color(0xFF4B0082)],
          ),
          _buildProjectCard(
            context, theme, colorScheme,
            title: 'Back-End Development',
            date: 'October 4, 2020',
            projectNumber: 'Project 2',
            iconData: Icons.dns, // Another distinct icon for backend
            gradientColors: [const Color(0xFF8A2BE2), const Color(0xFF4B0082)],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) { // Assuming 2 project cards
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentProjectPage == index ? 20.0 : 8.0, // Active dot is wider (mockup has one long, one short)
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0), // Adjusted margin
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentProjectPage == index
                ? colorScheme.primary // Active dot color (purple)
                : Colors.grey[300],    // Inactive dot color (lighter grey)
          ),
        );
      }),
    );
  }

  Widget _buildProjectCard(
    BuildContext context, ThemeData theme, ColorScheme colorScheme,
    {
    required String title,
    required String date,
    required String projectNumber,
    required IconData iconData, // Icon for the project
    required List<Color> gradientColors,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0), // Spacing between cards
      padding: const EdgeInsets.all(16.0), // Padding inside the card, 16dp
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // 16 dp corner radius
        gradient: LinearGradient(
          colors: gradientColors, // purple->blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectNumber,
                style: GoogleFonts.roboto(
                  fontSize: 14, // Mockup seems smaller for "Project 1"
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), // Icon placeholder top-left
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: Colors.white, size: 24), // Icon placeholder
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 18, // Roboto, 18 sp, white
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                date,
                style: GoogleFonts.roboto(
                  fontSize: 12, // 12 sp, semi-opaque white
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressListItem(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required String title, required String daysAgo}) {
    return Card(
      elevation: 2, // Subtle drop shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 12 dp radius
      ),
      color: Colors.white, // White cards
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 8dp internal padding for ListTile
        leading: Container(
          width: 40, // Fixed size for icon container
          height: 40,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.15), // Light purple background for icon
            borderRadius: BorderRadius.circular(8), // Rounded square for icon background
          ),
          child: Icon(Icons.design_services_outlined, color: colorScheme.primary, size: 20), // Small purple icon (design related)
        ),
        title: Text(
          title, // "Design Changes"
          style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color ?? Colors.black87),
        ),
        subtitle: Text(
          daysAgo, // "2 Days ago"
          style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[600]),
        ),
        // No trailing icon in the mockup for these progress items
      ),
    );
  }
}