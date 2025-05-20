import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/task_model.dart';
import '../auth/auth_service.dart';
import '../tasks/task_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDarkMode = false; // State for the dark mode toggle

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // final userId = user?.uid ?? '';
    // final tasksAsyncValue = ref.watch(personalTasksProvider(userId)); // Not used in new design

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildUserProfileHeader(context, user),
            const SizedBox(height: 32),
            _buildSettingsList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context, User? user) {
    // Using name from reference image for now
    const displayName = 'Fazil Laghari';
    const displayEmail = 'fazil.laghari@example.com'; // Placeholder email

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null, // Placeholder for actual image
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Color(0xFF3A3D40))
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, // Yellow accent
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? displayName, // Use actual name if available
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? displayEmail, // Use actual email if available
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingsItem(context, title: 'My Tasks', icon: Icons.list_alt_outlined, onTap: () {}),
        _buildSettingsItem(context, title: 'Privacy', icon: Icons.lock_outline, onTap: () {}),
        _buildSettingsItem(context, title: 'Settings', icon: Icons.settings_outlined, onTap: () {}),
        _buildSettingsItem(
          context,
          title: 'Dark mode',
          icon: Icons.dark_mode_outlined,
          trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                // Add logic to change theme here if needed
              });
            },
            activeColor: Theme.of(context).colorScheme.secondary, // Yellow accent for active toggle
          ),
          onTap: () { // Allow tapping the row to toggle as well
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          }
        ),
        const SizedBox(height: 20), // Spacer before logout
        _buildSettingsItem(
          context,
          title: 'Logout',
          icon: Icons.logout,
          iconColor: Colors.red[700],
          textColor: Colors.red[700],
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            
            if (confirmed == true) {
              await ref.read(authServiceProvider).signOut();
              // Potentially navigate to login screen after sign out
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05), // Very light grey/primary tint
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 24),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // _buildProfileCard, _buildTaskStatistics, _buildStatItem, _buildSettingsCard are removed as they are replaced by the new design.
}