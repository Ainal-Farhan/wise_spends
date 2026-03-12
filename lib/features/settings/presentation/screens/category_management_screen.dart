import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/data/constants/category_enum.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';
import 'add_category_screen.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoryBloc(context.read<ICategoryRepository>())
            ..add(LoadCategoriesEvent()),
      child: const _CategoryManagementScreenContent(),
    );
  }
}

class _CategoryManagementScreenContent extends StatelessWidget {
  const _CategoryManagementScreenContent();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('categories.manage'.tr),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAddCategory(context),
              tooltip: 'categories.add'.tr,
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              context.read<CategoryBloc>().add(
                ChangeCategoryFilterEvent(
                  index == 0
                      ? 'all'
                      : index == 1
                      ? 'income'
                      : 'expense',
                ),
              );
            },
            tabs: [
              Tab(text: 'general.all'.tr),
              Tab(text: 'categories.income'.tr),
              Tab(text: 'categories.expense'.tr),
            ],
          ),
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              final filterType = state.filterType ?? 'all';
              final categories = filterType == 'income'
                  ? state.categories.where((c) => c.isIncome).toList()
                  : filterType == 'expense'
                  ? state.categories.where((c) => c.isExpense).toList()
                  : state.categories;

              if (categories.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.category_outlined,
                  title: 'categories.no_categories'.tr,
                  subtitle: 'categories.no_categories_desc'.tr,
                  actionLabel: 'categories.add'.tr,
                  onAction: () => _navigateToAddCategory(context),
                  iconColor: AppColors.primary,
                );
              }

              // Count by type for header stats
              final incomeCount = state.categories
                  .where((c) => c.isIncome)
                  .length;
              final expenseCount = state.categories
                  .where((c) => c.isExpense)
                  .length;

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<CategoryBloc>().add(LoadCategoriesEvent()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  // index 0 = header card, rest = category cards
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeaderCard(
                        totalCount: state.categories.length,
                        incomeCount: incomeCount,
                        expenseCount: expenseCount,
                      );
                    }
                    return _buildCategoryCard(context, categories[index - 1]);
                  },
                ),
              );
            } else if (state is CategoryError) {
              return ErrorStateWidget(
                message: state.message,
                onAction: () =>
                    context.read<CategoryBloc>().add(LoadCategoriesEvent()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header card
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard({
    required int totalCount,
    required int incomeCount,
    required int expenseCount,
  }) {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      icon: Icons.category_outlined,
      label: 'categories.manage'.tr,
      title: '$totalCount ${'categories.manage_title'.tr}',
      subtitle:
          '$incomeCount ${'categories.income'.tr.toLowerCase()}  ·  '
          '$expenseCount ${'categories.expense'.tr.toLowerCase()}',
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'categories.what_are'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SectionHeaderBullet('categories.tip_income'.tr),
          SectionHeaderBullet('categories.tip_expense'.tr),
          SectionHeaderBullet('categories.tip_both'.tr),
          SectionHeaderBullet('categories.tip_icon'.tr),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category card
  // ---------------------------------------------------------------------------

  Widget _buildCategoryCard(BuildContext context, dynamic category) {
    final iconData = category.iconCodePoint != null
        ? CategoryIconMapper.getIconForCategory(category.iconCodePoint)
        : Icons.category;

    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    final color = _getCategoryColor(category);

    final typeLabel = isIncome && isExpense
        ? 'categories.both'.tr
        : isIncome
        ? 'categories.income'.tr
        : 'categories.expense'.tr;

    final typeColor = isIncome && isExpense
        ? AppColors.tertiary
        : isIncome
        ? AppColors.income
        : AppColors.expense;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? 'Unnamed',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildTypeBadge(label: typeLabel, color: typeColor),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditCategoryDialog(context, category);
                } else if (value == 'delete') {
                  _confirmDeleteCategory(context, category);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('categories.edit'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'general.delete'.tr,
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(dynamic category) {
    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    if (isIncome && isExpense) return AppColors.tertiary;
    if (isIncome) return AppColors.income;
    return AppColors.expense;
  }

  Widget _buildTypeBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    ).then((_) => context.read<CategoryBloc>().add(LoadCategoriesEvent()));
  }

  // ---------------------------------------------------------------------------
  // Edit dialog
  // ---------------------------------------------------------------------------

  void _showEditCategoryDialog(BuildContext context, dynamic category) {
    final nameController = TextEditingController(text: category.name);
    final categoryBloc = context.read<CategoryBloc>();

    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    final CategoryType initialType = isIncome && isExpense
        ? CategoryType.both
        : isIncome
        ? CategoryType.income
        : CategoryType.expense;

    showDialog(
      context: context,
      builder: (dialogContext) {
        CategoryType categoryType = initialType;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => CustomDialog(
            config: CustomDialogConfig(
              title: 'categories.edit'.tr,
              icon: Icons.edit_note,
              iconColor: AppColors.tertiary,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'general.name'.tr,
                    controller: nameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('categories.type'.tr, style: AppTextStyles.bodySemiBold),
                  const SizedBox(height: AppSpacing.sm),
                  RadioGroup<CategoryType>(
                    groupValue: categoryType,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => categoryType = value);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<CategoryType>(
                          title: Text('categories.income'.tr),
                          value: CategoryType.income,
                        ),
                        RadioListTile<CategoryType>(
                          title: Text('categories.expense'.tr),
                          value: CategoryType.expense,
                        ),
                        RadioListTile<CategoryType>(
                          title: Text('categories.both'.tr),
                          value: CategoryType.both,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              buttons: [
                CustomDialogButton(
                  text: 'general.cancel'.tr,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                CustomDialogButton(
                  text: 'general.update'.tr,
                  isDefault: true,
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('categories.enter_name'.tr),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      );
                      return;
                    }
                    categoryBloc.add(
                      UpdateCategoryEvent(
                        category.copyWith(
                          name: nameController.text,
                          isIncome:
                              categoryType == CategoryType.income ||
                              categoryType == CategoryType.both,
                          isExpense:
                              categoryType == CategoryType.expense ||
                              categoryType == CategoryType.both,
                        ),
                      ),
                    );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('categories.updated'.tr),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Delete dialog
  // ---------------------------------------------------------------------------

  void _confirmDeleteCategory(BuildContext context, dynamic category) {
    final categoryBloc = context.read<CategoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'general.delete'.tr,
          message: 'categories.delete_confirm'.trWith({
            'name': category.name ?? '',
          }),
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.delete'.tr,
              isDestructive: true,
              onPressed: () {
                categoryBloc.add(DeleteCategoryEvent(category.id));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('categories.deleted'.tr),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
