import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/data/constants/category_enum.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/category/presentation/screens/icon_picker_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Enhanced Edit Category Screen
/// Features:
/// - Dedicated screen for editing (not a dialog)
/// - Full icon picker integration
/// - Real-time preview
/// - Delete option with confirmation
/// - Clean, modern UI matching add screen
class EditCategoryScreen extends StatefulWidget {
  final dynamic category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  late CategoryType _categoryType;
  late int _selectedIconCodePoint;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name ?? '');
    _nameController.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    });

    final isIncome = widget.category.isIncome == true;
    final isExpense = widget.category.isExpense == true;
    _categoryType = isIncome && isExpense
        ? CategoryType.both
        : isIncome
        ? CategoryType.income
        : CategoryType.expense;

    _selectedIconCodePoint = widget.category.iconCodePoint != null
        ? int.tryParse(widget.category.iconCodePoint.toString()) ??
              Icons.category.codePoint
        : Icons.category.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CategoryBloc(context.read<ICategoryRepository>()),
      child: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryUpdated) {
            _showSuccessSnackBar('categories.updated'.tr, theme);
            Navigator.pop(context);
          } else if (state is CategoryDeleted) {
            _showSuccessSnackBar('categories.deleted'.tr, theme);
            Navigator.pop(context);
          } else if (state is CategoryError) {
            _showErrorSnackBar(state.message, theme);
          }
        },
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('categories.edit'.tr),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'general.cancel'.tr,
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Selection Card
                  _buildIconSelectionCard(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Category Name Input
                  _buildNameInputCard(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Category Type Selection
                  _buildTypeSelectionCard(theme),

                  const SizedBox(height: AppSpacing.xl + AppSpacing.md),

                  // Save/Update Button
                  _buildSaveButton(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Icon Selection Card
  // ---------------------------------------------------------------------------

  Widget _buildIconSelectionCard(ThemeData theme) {
    return AppCard(
      child: InkWell(
        onTap: () => _openIconPicker(),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Icon Preview
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(theme).withValues(alpha: 0.8),
                      _getCategoryColor(theme).withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(theme).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  IconData(_selectedIconCodePoint, fontFamily: 'MaterialIcons'),
                  color: theme.colorScheme.onPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Label and Hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'categories.select_icon'.tr,
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'categories.tap_to_change_icon'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Name Input Card
  // ---------------------------------------------------------------------------

  Widget _buildNameInputCard(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.label_outline,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('general.name'.tr, style: AppTextStyles.bodySemiBold),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _nameController,
              label: 'categories.category_name'.tr,
              hint: 'categories.name_hint'.tr,
              prefixIcon: Icons.category_outlined,
              onChanged: (value) {
                if (!_hasChanges) setState(() => _hasChanges = true);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'categories.enter_name'.tr;
                }
                if (value.trim().length < 2) {
                  return 'categories.name_too_short'.tr;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Type Selection Card
  // ---------------------------------------------------------------------------

  Widget _buildTypeSelectionCard(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('categories.type'.tr, style: AppTextStyles.bodySemiBold),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Column(
              children: [
                _buildTypeOption(
                  context,
                  type: CategoryType.income,
                  icon: Icons.arrow_downward_rounded,
                  title: 'categories.income'.tr,
                  subtitle: 'categories.for_money_received'.tr,
                  isSelected: _categoryType == CategoryType.income,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildTypeOption(
                  context,
                  type: CategoryType.expense,
                  icon: Icons.arrow_upward_rounded,
                  title: 'categories.expense'.tr,
                  subtitle: 'categories.for_money_spent'.tr,
                  isSelected: _categoryType == CategoryType.expense,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildTypeOption(
                  context,
                  type: CategoryType.both,
                  icon: Icons.swap_horiz_rounded,
                  title: 'categories.both'.tr,
                  subtitle: 'categories.for_both'.tr,
                  isSelected: _categoryType == CategoryType.both,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required CategoryType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _categoryType = type;
          _hasChanges = true;
        });
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : theme.colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
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

  // ---------------------------------------------------------------------------
  // Save/Update Button
  // ---------------------------------------------------------------------------

  Widget _buildSaveButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AppButton.primary(
        label: _hasChanges ? 'general.save'.tr : 'categories.updated'.tr,
        icon: _hasChanges ? Icons.save : Icons.check_circle,
        onPressed: _hasChanges ? () => _saveChanges(context) : null,
        size: AppButtonSize.large,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  Color _getCategoryColor(ThemeData theme) {
    if (_categoryType == CategoryType.both) return theme.colorScheme.tertiary;
    if (_categoryType == CategoryType.income) return theme.colorScheme.primary;
    return theme.colorScheme.secondary;
  }

  void _openIconPicker() {
    Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => IconPickerScreen(
          selectedIconCodePoint: _selectedIconCodePoint,
          onIconSelected: (codePoint) {
            setState(() {
              _selectedIconCodePoint = codePoint;
              _hasChanges = true;
            });
          },
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    // Validate name field
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar('categories.enter_name'.tr, Theme.of(context));
      return;
    }

    if (_nameController.text.trim().length < 2) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar('categories.name_too_short'.tr, Theme.of(context));
      return;
    }

    HapticFeedback.mediumImpact();

    final isIncome =
        _categoryType == CategoryType.income ||
        _categoryType == CategoryType.both;
    final isExpense =
        _categoryType == CategoryType.expense ||
        _categoryType == CategoryType.both;

    context.read<CategoryBloc>().add(
      UpdateCategoryEvent(
        widget.category.copyWith(
          name: _nameController.text.trim(),
          isIncome: isIncome,
          isExpense: isExpense,
          iconCodePoint: _selectedIconCodePoint.toString(),
          iconFontFamily: 'MaterialIcons',
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message, ThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(message),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _showErrorSnackBar(String message, ThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
