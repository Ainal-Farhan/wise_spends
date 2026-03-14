// FIXED: Extracted from budget_plans_forms.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Responsive step indicator wizard bar
class WizardStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const WizardStepBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final enoughWidth = constraints.maxWidth >= totalSteps * 72;
        return enoughWidth
            ? FullStepBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                accentColor: accentColor,
                stepLabels: stepLabels,
              )
            : CompactStepBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                accentColor: accentColor,
                stepLabels: stepLabels,
              );
      },
    );
  }
}

/// Full-width step bar with labels and animated progress line
class FullStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const FullStepBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AnimatedConnector(
                  filled: (i ~/ 2) < currentStep,
                  accentColor: accentColor,
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final done = stepIndex < currentStep;
          final active = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StepCircle(
                index: stepIndex,
                done: done,
                active: active,
                accentColor: accentColor,
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: 70,
                child: Text(
                  stepLabels[stepIndex].tr,
                  style: AppTextStyles.caption.copyWith(
                    color: (active || done)
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outline,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Step circle widget
class StepCircle extends StatelessWidget {
  final int index;
  final bool done;
  final bool active;
  final Color accentColor;

  const StepCircle({
    super.key,
    required this.index,
    required this.done,
    required this.active,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Widget child;

    if (done) {
      bg = accentColor;
      child = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (active) {
      bg = accentColor;
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    } else {
      bg = Theme.of(context).colorScheme.outline;
      child = Text(
        '${index + 1}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: active ? 34 : 28,
      height: active ? 34 : 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}

/// Animated connector line between steps
class AnimatedConnector extends StatelessWidget {
  final bool filled;
  final Color accentColor;

  const AnimatedConnector({
    super.key,
    required this.filled,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: filled ? accentColor : Theme.of(context).colorScheme.outline,
    );
  }
}

/// Compact pill-dot bar for narrow screens
class CompactStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const CompactStepBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (i) {
              final active = i == currentStep;
              final done = i < currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 5),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (active || done) ? accentColor : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              stepLabels[currentStep].tr,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
