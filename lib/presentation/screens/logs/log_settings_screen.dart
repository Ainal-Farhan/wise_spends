import 'package:flutter/material.dart';
import 'package:wise_spends/core/logger/log_level.dart';
import 'package:wise_spends/core/logger/logger_preferences_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

/// Screen for configuring logger settings
class LogSettingsScreen extends StatefulWidget {
  const LogSettingsScreen({super.key});

  @override
  State<LogSettingsScreen> createState() => _LogSettingsScreenState();
}

class _LogSettingsScreenState extends State<LogSettingsScreen>
    with SingleTickerProviderStateMixin {
  late bool _loggingEnabled;
  late LogLevel _minLogLevel;
  final _prefsService = LoggerPreferencesService();

  late final AnimationController _toggleController;
  late final Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _loggingEnabled = _prefsService.isLoggingEnabled();
    _minLogLevel = _prefsService.getMinLogLevel();

    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: _loggingEnabled ? 1.0 : 0.0,
    );
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  Future<void> _toggleLogging(bool value) async {
    setState(() => _loggingEnabled = value);
    await _prefsService.setLoggingEnabled(value);
    WiseLogger().setEnabled(value);

    if (value) {
      _toggleController.forward();
    } else {
      _toggleController.reverse();
    }

    if (mounted) {
      showSnackBarMessage(
        context,
        value ? 'Logging enabled' : 'Logging disabled',
        type: SnackBarMessageType.info,
      );
    }
  }

  Future<void> _changeLogLevel(LogLevel level) async {
    setState(() => _minLogLevel = level);
    await _prefsService.setMinLogLevel(level);
    WiseLogger().setMinLogLevel(level);

    if (mounted) {
      showSnackBarMessage(
        context,
        'Log level set to ${level.name.toUpperCase()}',
        type: SnackBarMessageType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Log Settings'),
        centerTitle: false,
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildEnableLoggingCard(colorScheme),
          const SizedBox(height: 16),
          _buildLogLevelCard(colorScheme),
          const SizedBox(height: 16),
          _buildInfoCard(colorScheme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Enable Logging Card ──────────────────────────────────────────────────

  Widget _buildEnableLoggingCard(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _toggleAnimation,
      builder: (context, _) {
        final activeColor = colorScheme.primary;
        final inactiveColor = colorScheme.outline;
        final currentColor = Color.lerp(
          inactiveColor,
          activeColor,
          _toggleAnimation.value,
        )!;

        return _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _loggingEnabled
                          ? Icons.receipt_long_rounded
                          : Icons.receipt_long_outlined,
                      color: currentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enable Logging',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _loggingEnabled ? 'Active' : 'Inactive',
                            key: ValueKey(_loggingEnabled),
                            style: TextStyle(
                              fontSize: 12,
                              color: currentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _loggingEnabled,
                    onChanged: _toggleLogging,
                    activeThumbColor: colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _loggingEnabled
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _StatusBanner(
                  color: Colors.green,
                  icon: Icons.check_circle_outline_rounded,
                  message:
                      'All app activities are being recorded to local storage.',
                ),
                secondChild: _StatusBanner(
                  color: colorScheme.outline,
                  icon: Icons.pause_circle_outline_rounded,
                  message:
                      'Logging is paused. Enable to start recording app activities.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Log Level Card ───────────────────────────────────────────────────────

  Widget _buildLogLevelCard(ColorScheme colorScheme) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: _loggingEnabled
                      ? colorScheme.secondary
                      : colorScheme.outline,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minimum Log Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select the minimum severity to record',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Verbosity scale indicator
          _VerbosityScale(
            levels: LogLevel.values,
            selectedLevel: _minLogLevel,
            enabled: _loggingEnabled,
          ),
          const SizedBox(height: 8),
          const Divider(height: 24),
          // RadioGroup wraps ALL radio tiles so keyboard navigation
          // (arrow keys, space, tab) and ARIA semantics work correctly.
          RadioGroup<LogLevel>(
            groupValue: _minLogLevel,
            onChanged: _loggingEnabled
                ? (value) => _changeLogLevel(value!)
                : (_) {},
            child: Column(
              children: LogLevel.values
                  .map((level) => _buildLogLevelTile(level, colorScheme))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogLevelTile(LogLevel level, ColorScheme colorScheme) {
    final isSelected = _minLogLevel == level;
    final isEnabled = _loggingEnabled;
    final levelColor = Color(level.colorValue);
    final effectiveColor = isEnabled ? levelColor : colorScheme.outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? levelColor.withValues(alpha: isEnabled ? 0.1 : 0.04)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? levelColor.withValues(alpha: isEnabled ? 0.4 : 0.15)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getLevelIcon(level), color: effectiveColor, size: 18),
        ),
        title: Text(
          level.name.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isEnabled
                ? (isSelected ? levelColor : colorScheme.onSurface)
                : colorScheme.outline,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          _getLevelDescription(level),
          style: TextStyle(
            fontSize: 11,
            color: isEnabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.outline.withValues(alpha: 0.7),
          ),
        ),
        trailing: Radio<LogLevel>(
          value: level,
          activeColor: levelColor,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (!isEnabled) return colorScheme.outline.withValues(alpha: 0.4);
            if (states.contains(WidgetState.selected)) return levelColor;
            return colorScheme.outline;
          }),
        ),
        onTap: isEnabled ? () => _changeLogLevel(level) : null,
      ),
    );
  }

  // ─── Info Card ────────────────────────────────────────────────────────────

  Widget _buildInfoCard(ColorScheme colorScheme) {
    final items = [
      (Icons.storage_rounded, 'Logs are stored locally on your device'),
      (Icons.data_usage_rounded, 'Each log file has a maximum size of 10 MB'),
      (
        Icons.file_copy_outlined,
        'New files are created when the size limit is reached',
      ),
      (Icons.calendar_today_rounded, 'Logs are organized by date'),
      (
        Icons.manage_search_rounded,
        'View, delete, or share logs from the Log Viewer',
      ),
    ];

    return _SectionCard(
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'About Logging',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 15, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  IconData _getLevelIcon(LogLevel level) {
    return switch (level) {
      LogLevel.trace => Icons.adjust_rounded,
      LogLevel.debug => Icons.code_rounded,
      LogLevel.info => Icons.info_outline_rounded,
      LogLevel.warning => Icons.warning_amber_rounded,
      LogLevel.error => Icons.error_outline_rounded,
      LogLevel.fatal => Icons.dangerous_outlined,
    };
  }

  String _getLevelDescription(LogLevel level) {
    return switch (level) {
      LogLevel.trace => 'Detailed tracing information (most verbose)',
      LogLevel.debug => 'Debugging information for developers',
      LogLevel.info => 'General informational messages',
      LogLevel.warning => 'Warning messages (potential issues)',
      LogLevel.error => 'Error messages (actual errors)',
      LogLevel.fatal => 'Critical errors only (least verbose)',
    };
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────

/// Reusable card container with consistent styling
class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _SectionCard({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// Colored banner used to show logging status
class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual scale showing verbosity from most verbose (left) to least (right)
class _VerbosityScale extends StatelessWidget {
  final List<LogLevel> levels;
  final LogLevel selectedLevel;
  final bool enabled;

  const _VerbosityScale({
    required this.levels,
    required this.selectedLevel,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = levels.indexOf(selectedLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(levels.length, (i) {
            final level = levels[i];
            final isActive = i >= selectedIndex;
            final color = enabled
                ? Color(level.colorValue)
                : colorScheme.outline.withValues(alpha: 0.3);

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < levels.length - 1 ? 3 : 0),
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? color : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Most verbose',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Least verbose',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
