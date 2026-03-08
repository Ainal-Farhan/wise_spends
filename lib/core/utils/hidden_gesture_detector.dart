import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A hidden gesture detector that triggers an action when a specific
/// gesture pattern is performed.
///
/// Default gesture: Double-tap and hold for 2 seconds.
/// Optionally shows a subtle progress ring and supports haptic feedback.
///
/// Usage:
/// ```dart
/// HiddenGestureDetector(
///   onTriggered: () => _openDevMenu(),
///   child: YourAppContent(),
/// )
///
/// // With all options:
/// HiddenGestureDetector(
///   onTriggered: () => _openDevMenu(),
///   holdDuration: const Duration(seconds: 3),
///   requiredTaps: 3,
///   enableHaptics: true,
///   showProgressIndicator: true,
///   progressIndicatorColor: Colors.blue,
///   onProgress: (progress) => print('Progress: $progress'),
///   child: YourAppContent(),
/// )
/// ```
class HiddenGestureDetector extends StatefulWidget {
  final Widget child;

  /// Callback fired when the full gesture is completed.
  final VoidCallback onTriggered;

  /// How long the user must hold after reaching [requiredTaps].
  final Duration holdDuration;

  /// Number of taps required before the hold phase begins.
  final int requiredTaps;

  /// Whether to fire light haptic feedback on tap and success.
  final bool enableHaptics;

  /// Show a subtle circular progress ring during the hold phase.
  final bool showProgressIndicator;

  /// Color of the progress ring. Defaults to the theme's primary color.
  final Color? progressIndicatorColor;

  /// Alignment of the progress ring overlay within the detector area.
  final Alignment progressIndicatorAlignment;

  /// Called continuously during the hold phase with a value from 0.0 → 1.0.
  final ValueChanged<double>? onProgress;

  /// Called when the hold starts (after required taps).
  final VoidCallback? onHoldStart;

  /// Called when the hold is cancelled before completing.
  final VoidCallback? onHoldCancelled;

  /// Maximum ms between taps to count as a sequence.
  final int tapIntervalMs;

  const HiddenGestureDetector({
    super.key,
    required this.child,
    required this.onTriggered,
    this.holdDuration = const Duration(seconds: 2),
    this.requiredTaps = 2,
    this.enableHaptics = true,
    this.showProgressIndicator = true,
    this.progressIndicatorColor,
    this.progressIndicatorAlignment = Alignment.center,
    this.onProgress,
    this.onHoldStart,
    this.onHoldCancelled,
    this.tapIntervalMs = 500,
  }) : assert(requiredTaps >= 1, 'requiredTaps must be at least 1');

  @override
  State<HiddenGestureDetector> createState() => _HiddenGestureDetectorState();
}

class _HiddenGestureDetectorState extends State<HiddenGestureDetector>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  Timer? _resetTimer;
  Timer? _holdTimer;
  Timer? _progressTimer;
  bool _isHolding = false;
  double _holdProgress = 0.0;

  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: widget.holdDuration)
          ..addListener(() {
            setState(() => _holdProgress = _progressController.value);
            widget.onProgress?.call(_progressController.value);
          });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _holdTimer?.cancel();
    _progressTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  // ─── Gesture Handlers ────────────────────────────────────────────────────

  void _handleTapDown(TapDownDetails _) {
    final now = DateTime.now();
    final isNewSequence =
        _lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds > widget.tapIntervalMs;

    _tapCount = isNewSequence ? 1 : _tapCount + 1;
    _lastTapTime = now;

    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }

    if (_tapCount >= widget.requiredTaps) {
      _startHold();
    } else {
      // Schedule a reset if no further taps arrive
      _scheduleReset();
    }
  }

  void _handleTapUp(TapUpDetails _) => _cancelHold();

  void _handleTapCancel() => _cancelHold();

  // ─── Hold Logic ──────────────────────────────────────────────────────────

  void _startHold() {
    if (_isHolding) return;
    _isHolding = true;

    // Stop any pending sequence reset
    _resetTimer?.cancel();

    widget.onHoldStart?.call();

    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    // Animate the progress ring
    _progressController.forward(from: 0.0);

    // Fire onTriggered at the end of the hold
    _holdTimer?.cancel();
    _holdTimer = Timer(widget.holdDuration, _onHoldComplete);
  }

  void _cancelHold() {
    if (!_isHolding) return;

    _isHolding = false;
    _holdTimer?.cancel();
    _progressController.stop();
    _progressController.reset();

    widget.onHoldCancelled?.call();

    // Let the tap sequence expire naturally
    _scheduleReset();
  }

  void _onHoldComplete() {
    if (!_isHolding || !mounted) return;

    _isHolding = false;
    _progressController.stop();
    _progressController.reset();

    if (widget.enableHaptics) {
      HapticFeedback.heavyImpact();
    }

    widget.onTriggered();
    _resetState();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _scheduleReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(
      Duration(milliseconds: widget.tapIntervalMs * 2),
      _resetState,
    );
  }

  void _resetState() {
    _tapCount = 0;
    _lastTapTime = null;
    _isHolding = false;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.translucent,
      child: widget.showProgressIndicator
          ? Directionality(
              // Stack resolves its default alignment (AlignmentDirectional.topStart)
              // before inspecting children, so Directionality must wrap the Stack,
              // not sit inside it. Inherit ambient direction; fall back to LTR.
              textDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              child: Stack(
                children: [
                  widget.child,
                  if (_isHolding || _holdProgress > 0)
                    Positioned.fill(
                      child: Align(
                        alignment: widget.progressIndicatorAlignment,
                        child: _HoldProgressRing(
                          progress: _holdProgress,
                          color:
                              widget.progressIndicatorColor ??
                              Theme.of(context).colorScheme.primary,
                          tapCount: _tapCount,
                          requiredTaps: widget.requiredTaps,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : widget.child,
    );
  }
}

// ─── Progress Ring ─────────────────────────────────────────────────────────

class _HoldProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final int tapCount;
  final int requiredTaps;

  const _HoldProgressRing({
    required this.progress,
    required this.color,
    required this.tapCount,
    required this.requiredTaps,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: progress > 0 ? 1.0 : 0.0,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(
          painter: _RingPainter(progress: progress, color: color),
          child: Center(
            child: Text(
              '$tapCount/$requiredTaps',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // start at top
      2 * 3.14159 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── HiddenMenuButton ──────────────────────────────────────────────────────

/// A small icon button for placing a visible-but-subtle dev menu trigger.
class HiddenMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final String tooltip;

  const HiddenMenuButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.bug_report,
    this.size = 24,
    this.color,
    this.tooltip = 'Developer Menu',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color ?? Colors.grey.shade400,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
