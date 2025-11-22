import 'package:flutter/material.dart';
import '../recipes/recipes_list_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/edit_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            Icons.person,
            'Profile',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          _buildMenuItem(context, Icons.flag, 'Goals & Targets', () {}),
          _buildMenuItem(
            context,
            Icons.restaurant,
            'Recipes',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipesListScreen()),
              );
            },
          ),
          _buildMenuItem(context, Icons.add_circle, 'Custom Foods', () {}),
          _buildMenuItem(
            context,
            Icons.settings,
            'Settings',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _buildMenuItem(context, Icons.help, 'Help & Support', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF14B8A6)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
