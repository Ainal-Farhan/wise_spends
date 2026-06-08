import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/services/notification_service.dart';

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
          _buildMenuSection(
            context,
            title: 'Push Notifications',
            icon: Icons.notifications_active,
            color: Colors.orange,
            items: [
              _FcmTokenTile(),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
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
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const HiddenUtilityMenuScreen(),
    );
  }
}

// ── FCM token tile — shown only in the hidden developer menu ─────────────────

class _FcmTokenTile extends StatefulWidget {
  const _FcmTokenTile();

  @override
  State<_FcmTokenTile> createState() => _FcmTokenTileState();
}

class _FcmTokenTileState extends State<_FcmTokenTile> {
  String? _token;
  bool _loading = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    NotificationService().getToken().then((t) {
      if (mounted) setState(() { _token = t; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key_rounded, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'FCM Device Token',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (!_loading && _token != null)
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _token!));
                      setState(() => _copied = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _copied = false);
                    },
                    icon: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 14,
                    ),
                    label: Text(_copied ? 'Copied' : 'Copy'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          _copied ? Colors.green : Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const SizedBox(
                height: 20,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_token == null)
              const Text(
                'Token unavailable — check Firebase setup.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              )
            else
              SelectableText(
                _token!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
