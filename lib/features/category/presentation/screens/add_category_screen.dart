import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/data/constants/category_enum.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/add_category_form_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/add_category_form_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/add_category_form_state.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/category/presentation/screens/icon_picker_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Enhanced Add Category Screen with improved UX
/// Features:
/// - Clean, modern UI with visual hierarchy
/// - Integrated icon picker with preview
/// - Real-time validation and feedback
/// - Smooth animations and transitions
class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CategoryBloc(context.read<ICategoryRepository>()),
        ),
        BlocProvider(create: (_) => AddCategoryFormBloc()),
      ],
      child: const _AddCategoryScreenContent(),
    );
  }
}

class _AddCategoryScreenContent extends StatefulWidget {
  const _AddCategoryScreenContent();

  @override
  State<_AddCategoryScreenContent> createState() =>
      _AddCategoryScreenContentState();
}

class _AddCategoryScreenContentState extends State<_AddCategoryScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _showTypeSelection = false;

  @override
  void initState() {
    super.initState();
    // Auto-show type selection on load
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showTypeSelection = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryCreated) {
          _showSuccessSnackBar(theme);
          Navigator.pop(context);
        } else if (state is CategoryError) {
          _showErrorSnackBar(state.message, theme);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('categories.add'.tr),
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
          child: Form(
            key: _formKey,
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

                // Create Button
                _buildCreateButton(theme),
              ],
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
    return BlocBuilder<AddCategoryFormBloc, AddCategoryFormState>(
      builder: (context, formState) {
        final selectedCodePoint = formState is AddCategoryFormReady
            ? formState.iconCodePoint
            : Icons.category.codePoint;

        final selectedIcon = IconData(
          selectedCodePoint,
          fontFamily: 'MaterialIcons',
        );

        return AppCard(
          child: InkWell(
            onTap: () => _openIconPicker(selectedCodePoint),
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
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      selectedIcon,
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
      },
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
                Text(
                  'general.name'.tr,
                  style: AppTextStyles.bodySemiBold,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _nameController,
              label: 'categories.category_name'.tr,
              hint: 'categories.name_hint'.tr,
              prefixIcon: Icons.category_outlined,
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showTypeSelection ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showTypeSelection ? Offset.zero : const Offset(0, 0.2),
        child: AppCard(
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
                    Text(
                      'categories.type'.tr,
                      style: AppTextStyles.bodySemiBold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<AddCategoryFormBloc, AddCategoryFormState>(
                  builder: (context, formState) {
                    final selectedType = formState is AddCategoryFormReady
                        ? formState.type
                        : CategoryType.expense;

                    return Column(
                      children: [
                        _buildTypeOption(
                          context,
                          type: CategoryType.income,
                          icon: Icons.arrow_downward_rounded,
                          title: 'categories.income'.tr,
                          subtitle: 'categories.for_money_received'.tr,
                          isSelected: selectedType == CategoryType.income,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildTypeOption(
                          context,
                          type: CategoryType.expense,
                          icon: Icons.arrow_upward_rounded,
                          title: 'categories.expense'.tr,
                          subtitle: 'categories.for_money_spent'.tr,
                          isSelected: selectedType == CategoryType.expense,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildTypeOption(
                          context,
                          type: CategoryType.both,
                          icon: Icons.swap_horiz_rounded,
                          title: 'categories.both'.tr,
                          subtitle: 'categories.for_both'.tr,
                          isSelected: selectedType == CategoryType.both,
                          color: theme.colorScheme.tertiary,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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
        context.read<AddCategoryFormBloc>().add(AddCategoryChangeType(type));
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
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? color
                          : theme.colorScheme.onSurface,
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
  // Create Button
  // ---------------------------------------------------------------------------

  Widget _buildCreateButton(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final isLoading = state is CategoryLoading;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: AppButton.primary(
            label: isLoading ? 'categories.creating'.tr : 'categories.create'.tr,
            icon: isLoading ? Icons.hourglass_empty : Icons.add_circle_outline,
            onPressed: isLoading ? null : () => _submitForm(context),
            size: AppButtonSize.large,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  void _openIconPicker(int selectedCodePoint) {
    Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => IconPickerScreen(
          selectedIconCodePoint: selectedCodePoint,
          onIconSelected: (codePoint) {
            context.read<AddCategoryFormBloc>().add(
              AddCategorySelectIcon(codePoint),
            );
          },
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    final formState = context.read<AddCategoryFormBloc>().state;
    final categoryType = formState is AddCategoryFormReady
        ? formState.type
        : CategoryType.expense;
    final iconCodePoint = formState is AddCategoryFormReady
        ? formState.iconCodePoint
        : Icons.category.codePoint;

    final isIncome =
        categoryType == CategoryType.income ||
        categoryType == CategoryType.both;
    final isExpense =
        categoryType == CategoryType.expense ||
        categoryType == CategoryType.both;

    context.read<CategoryBloc>().add(
      CreateCategoryEvent(
        name: _nameController.text.trim(),
        isIncome: isIncome,
        isExpense: isExpense,
        iconCodePoint: iconCodePoint.toString(),
        iconFontFamily: 'MaterialIcons',
      ),
    );
  }

  void _showSuccessSnackBar(ThemeData theme) {
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
              child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('categories.added'.tr),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
