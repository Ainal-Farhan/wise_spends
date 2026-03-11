import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/services/widget_background_service.dart';
import 'package:wise_spends/presentation/services/widget_service.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Widget Info Screen
/// Shows widget status, installed widgets, and provides controls
class WidgetInfoScreen extends StatefulWidget {
  const WidgetInfoScreen({super.key});

  @override
  State<WidgetInfoScreen> createState() => _WidgetInfoScreenState();
}

class _WidgetInfoScreenState extends State<WidgetInfoScreen> {
  int _installedWidgetsCount = 0;
  bool _isBackgroundUpdatesEnabled = true;
  final String _lastUpdateTime = 'Never';
  bool _isPinSupported = false;

  @override
  void initState() {
    super.initState();
    _loadWidgetInfo();
  }

  Future<void> _loadWidgetInfo() async {
    // Get installed widgets count
    final count = await WidgetService.getInstalledWidgetsCount();

    // Check if pin is supported
    final pinSupported = await WidgetService.isPinWidgetSupported();

    setState(() {
      _installedWidgetsCount = count;
      _isPinSupported = pinSupported;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Settings'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Widget Status
            _buildWidgetStatusCard(),
            const SizedBox(height: 16),

            // Background Updates
            _buildBackgroundUpdatesCard(),
            const SizedBox(height: 16),

            // Installed Widgets
            _buildInstalledWidgetsCard(),
            const SizedBox(height: 16),

            // Add Widget Button
            if (_installedWidgetsCount == 0) ...[
              _buildAddWidgetButton(),
              const SizedBox(height: 16),
            ],

            // Pin Widget (Android)
            if (_isPinSupported && Platform.isAndroid) ...[
              _buildPinWidgetButton(),
              const SizedBox(height: 16),
            ],

            // Instructions
            _buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.widgets, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home Screen Widget',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quick access from home screen',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Widget Status', style: AppTextStyles.bodySemiBold),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Installed Widgets', '$_installedWidgetsCount'),
          const SizedBox(height: 8),
          _buildStatusRow('Last Update', _lastUpdateTime),
          const SizedBox(height: 8),
          _buildStatusRow('Platform', Platform.isAndroid ? 'Android' : 'iOS'),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundUpdatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.refresh, color: AppColors.info, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Background Updates', style: AppTextStyles.bodySemiBold),
                Text(
                  'Update widget every 15 minutes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isBackgroundUpdatesEnabled,
            onChanged: (value) {
              setState(() {
                _isBackgroundUpdatesEnabled = value;
              });
              if (value) {
                WidgetBackgroundService.startPeriodicUpdates();
              } else {
                WidgetBackgroundService.stopPeriodicUpdates();
              }
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInstalledWidgetsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _installedWidgetsCount > 0
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _installedWidgetsCount > 0
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _installedWidgetsCount > 0
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: _installedWidgetsCount > 0
                ? AppColors.success
                : AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _installedWidgetsCount > 0
                      ? 'Widget Installed'
                      : 'No Widget Installed',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: _installedWidgetsCount > 0
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                Text(
                  _installedWidgetsCount > 0
                      ? 'You have $_installedWidgetsCount widget(s) on your home screen'
                      : 'Add a widget to quickly add transactions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWidgetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          WidgetService.showWidgetInfoDialog(context);
        },
        icon: const Icon(Icons.add_home),
        label: const Text('Add Widget to Home Screen'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPinWidgetButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await WidgetService.requestPinWidget();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Widget pin request sent'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to pin widget'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.push_pin),
        label: const Text('Pin Widget (Android)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('How to Add Widget', style: AppTextStyles.bodySemiBold),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Long press on home screen'),
          const SizedBox(height: 8),
          _buildInstructionStep('2', 'Tap "Widgets"'),
          const SizedBox(height: 8),
          _buildInstructionStep('3', 'Find "WiseSpends"'),
          const SizedBox(height: 8),
          _buildInstructionStep('4', 'Drag "Quick Transaction" widget'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String step, String instruction) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
