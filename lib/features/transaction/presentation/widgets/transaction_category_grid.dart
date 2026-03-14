// transaction_category_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';
import 'transaction_form_widgets.dart';

/// Category grid for add mode
class TransactionCategoryGrid extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionCategoryGrid({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final typeColor = formState.transactionType.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'transaction.add.category'.tr),
        const SizedBox(height: 12),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is! CategoryLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = state.categories.where((c) {
              return formState.transactionType == TransactionType.income
                  ? c.isIncome
                  : c.isExpense;
            }).toList();

            if (categories.isEmpty) {
              return _EmptyCategoriesHint();
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    formState.selectedCategory?.id == category.id;

                return _CategoryTile(
                  category: category,
                  isSelected: isSelected,
                  typeColor: typeColor,
                  onTap: () => context.read<TransactionFormBloc>().add(
                    SelectCategory(category),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final Color typeColor;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.typeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? typeColor.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? typeColor : AppColors.divider,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? typeColor
                    : typeColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryIconMapper.getIconForCategory(category.iconCodePoint),
                color: isSelected ? Colors.white : typeColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? typeColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 10,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoriesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'transaction.category.empty_hint'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
