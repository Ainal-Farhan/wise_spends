import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/features/widget/presentation/bloc/widget_settings_cubit.dart';
import 'package:wise_spends/features/widget/presentation/services/widget_service.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Widget Settings Screen
/// Allows users to configure and learn how to add the home screen widget
class WidgetSettingsScreen extends StatelessWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WidgetSettingsCubit(),
      child: const _WidgetSettingsView(),
    );
  }
}

class _WidgetSettingsView extends StatelessWidget {
  const _WidgetSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen Widget'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Widget Preview
            _buildWidgetPreview(),
            const SizedBox(height: 24),

            // Benefits
            _buildBenefitsSection(),
            const SizedBox(height: 24),

            // Installation Instructions
            _buildInstallationInstructions(),
            const SizedBox(height: 24),

            // Add Widget Button
            _buildAddWidgetButton(context),
            const SizedBox(height: 24),

            // Internal Widget Toggle
            _buildInternalWidgetToggle(context),

            const SizedBox(height: 12),
            _buildHideDetailsToggle(context),
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
            child: const Icon(
              Icons.add_home_work,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Transaction Widget',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add transactions from your home screen',
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

  Widget _buildWidgetPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Widget Preview', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM 5,280.50',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.expense, AppColors.secondaryDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Expense',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.income, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Income',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Last transaction
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: AppColors.expense,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Transaction',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Lunch at Restaurant',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '- RM 45.00',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why Use the Widget?', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _buildBenefitItem(
          icon: Icons.flash_on,
          title: 'Lightning Fast',
          description: 'Add transactions in seconds without opening the app',
          color: AppColors.warning,
        ),
        _buildBenefitItem(
          icon: Icons.touch_app,
          title: 'One-Tap Access',
          description: 'Direct access from your home screen',
          color: AppColors.primary,
        ),
        _buildBenefitItem(
          icon: Icons.visibility,
          title: 'Stay Updated',
          description: 'See your balance and recent transactions at a glance',
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemiBold),
                Text(
                  description,
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

  Widget _buildInstallationInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How to Add Widget', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildInstructionStep(
                step: 1,
                title: 'Long press on home screen',
                description:
                    'Find an empty space on your home screen and long press',
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(
                step: 2,
                title: 'Tap "Widgets"',
                description: 'Select Widgets from the menu that appears',
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(
                step: 3,
                title: 'Find WiseSpends',
                description: 'Scroll to find WiseSpends in the widgets list',
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(
                step: 4,
                title: 'Drag to home screen',
                description:
                    'Drag "Quick Transaction" widget to your desired location',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required int step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTextStyles.bodySemiBold.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySemiBold),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddWidgetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Show widget info dialog
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

  Widget _buildInternalWidgetToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.widgets,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Access Button', style: AppTextStyles.bodySemiBold),
                Text(
                  'Show quick transaction button in app bar',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<WidgetSettingsCubit, WidgetSettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.isQuickAccessEnabled,
                onChanged: (value) {
                  context.read<WidgetSettingsCubit>().toggleQuickAccess(
                    value: value,
                  );
                },
                activeThumbColor: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHideDetailsToggle(BuildContext context) {
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
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hide Transaction Details',
                  style: AppTextStyles.bodySemiBold,
                ),
                Text(
                  'Blur amounts on the home screen widget',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<WidgetSettingsCubit, WidgetSettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.isHideDetailsEnabled,
                onChanged: (value) {
                  context.read<WidgetSettingsCubit>().toggleHideDetails(
                    value: value,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
