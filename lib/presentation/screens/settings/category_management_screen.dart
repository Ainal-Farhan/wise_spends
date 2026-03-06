import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/category_enum.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
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
          title: const Text('Manage Categories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAddCategory(context),
              tooltip: 'Add Category',
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
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Income'),
              Tab(text: 'Expense'),
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
                  title: 'No categories',
                  subtitle: 'Add your first category to get started',
                  actionLabel: 'Add Category',
                  onAction: () => _navigateToAddCategory(context),
                  iconColor: AppColors.primary,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CategoryBloc>().add(LoadCategoriesEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(context, categories[index]);
                  },
                ),
              );
            } else if (state is CategoryError) {
              return ErrorStateWidget(
                message: state.message,
                onAction: () {
                  context.read<CategoryBloc>().add(LoadCategoriesEvent());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    ).then((_) {
      context.read<CategoryBloc>().add(LoadCategoriesEvent());
    });
  }

  Widget _buildCategoryCard(BuildContext context, dynamic category) {
    final iconData = category.iconCodePoint != null
        ? CategoryIconMapper.getIconForCategory(category.iconCodePoint)
        : Icons.category;

    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    final color = _getCategoryColor(category);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
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
          const SizedBox(width: 16),
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
                _buildTypeBadge(
                  label: isIncome && isExpense
                      ? 'Both'
                      : isIncome
                      ? 'Income'
                      : 'Expense',
                  color: isIncome && isExpense
                      ? AppColors.tertiary
                      : isIncome
                      ? AppColors.income
                      : AppColors.expense,
                ),
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
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Category Name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  Text('Category Type', style: AppTextStyles.bodySemiBold),
                  const SizedBox(height: 8),
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
                          title: const Text('Income'),
                          value: CategoryType.income,
                        ),
                        RadioListTile<CategoryType>(
                          title: const Text('Expense'),
                          value: CategoryType.expense,
                        ),
                        RadioListTile<CategoryType>(
                          title: const Text('Both'),
                          value: CategoryType.both,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a category name'),
                        backgroundColor: AppColors.error,
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
                    const SnackBar(
                      content: Text('Category updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, dynamic category) {
    final categoryBloc = context.read<CategoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              categoryBloc.add(DeleteCategoryEvent(category.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
