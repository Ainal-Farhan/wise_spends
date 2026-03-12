import 'package:flutter/material.dart';
import 'package:wise_spends/core/constants/app_routes.dart';

/// Hidden utility menu for accessing developer/debug tools
/// 
/// This screen provides access to:
/// - Log Viewer
/// - Log Settings
/// - Other developer utilities (future)
class HiddenUtilityMenuScreen extends StatelessWidget {
  const HiddenUtilityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Utilities'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            title: 'Logging',
            icon: Icons.bug_report,
            color: Colors.blue,
            items: [
              _buildMenuItem(
                icon: Icons.folder,
                title: 'View Logs',
                subtitle: 'Browse, view, and share log files',
                color: Colors.blue,
                onTap: () => _navigateToLogViewer(context),
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Log Settings',
                subtitle: 'Configure logging levels and preferences',
                color: Colors.green,
                onTap: () => _navigateToLogSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.build,
                color: Colors.deepPurple.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Developer Utilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Debugging and diagnostic tools',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Text(
                  'How to Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This menu is hidden by default. To access it:\n\n'
              'Double-tap and hold on any screen for 2 seconds.\n\n'
              'This gesture can be performed on any screen in the app.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade900,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogViewer(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.logViewer);
  }

  void _navigateToLogSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.logSettings);
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HiddenUtilityMenuScreen(),
    );
  }
}
