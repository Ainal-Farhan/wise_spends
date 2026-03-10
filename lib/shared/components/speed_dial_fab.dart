import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// =============================================================================
// Data model for each dial action
// =============================================================================

class SpeedDialAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;

  const SpeedDialAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });
}

// =============================================================================
// Generic SpeedDialFab
// =============================================================================

class SpeedDialFab extends StatefulWidget {
  /// Actions shown when the dial is open, rendered bottom-to-top.
  final List<SpeedDialAction> actions;

  /// Icon shown when the dial is closed (default: add).
  final IconData closedIcon;

  /// Icon shown when the dial is open (default: close).
  final IconData openIcon;

  /// Main FAB background color.
  final Color? backgroundColor;

  /// Main FAB foreground color.
  final Color? foregroundColor;

  /// Hero tag for the main FAB.
  final String mainHeroTag;

  /// Whether tapping outside the dial closes it.
  final bool closeOnBarrierTap;

  const SpeedDialFab({
    super.key,
    required this.actions,
    this.closedIcon = Icons.add,
    this.openIcon = Icons.close,
    this.backgroundColor,
    this.foregroundColor,
    this.mainHeroTag = 'fab_main',
    this.closeOnBarrierTap = true,
  }) : assert(actions.length > 0, 'SpeedDialFab requires at least one action');

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expand;
  late final Animation<double> _iconSwap;

  bool get _isOpen =>
      _ctrl.isCompleted || _ctrl.status == AnimationStatus.forward;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _iconSwap = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _ctrl.reverse() : _ctrl.forward();
  void _close() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action items — rendered in reverse so index 0 is closest to main FAB
        ...widget.actions.reversed.map(
          (action) => _DialItem(
            action: action,
            animation: _expand,
            onPressed: () {
              _close();
              action.onPressed();
            },
          ),
        ),

        // Main FAB with animated icon crossfade
        FloatingActionButton(
          onPressed: _toggle,
          heroTag: widget.mainHeroTag,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          child: AnimatedIcon(
            icon: AnimatedIcons.add_event,
            progress: _iconSwap,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Single dial item
// =============================================================================

class _DialItem extends StatelessWidget {
  final SpeedDialAction action;
  final Animation<double> animation;
  final VoidCallback onPressed;

  const _DialItem({
    required this.action,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label pill
              _LabelPill(label: action.label),
              const SizedBox(width: AppSpacing.sm),
              // Mini FAB
              FloatingActionButton.small(
                onPressed: onPressed,
                heroTag: action.heroTag ?? 'fab_${action.label}',
                backgroundColor: action.backgroundColor,
                foregroundColor: action.foregroundColor,
                elevation: 2,
                child: Icon(action.icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Label pill
// =============================================================================

class _LabelPill extends StatelessWidget {
  final String label;

  const _LabelPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.black87,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
    );
  }
}
