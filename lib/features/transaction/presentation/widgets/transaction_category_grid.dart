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
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';
import 'transaction_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main widget — drop-in replacement for TransactionCategoryGrid
// ─────────────────────────────────────────────────────────────────────────────

class TransactionCategoryGrid extends StatefulWidget {
  final TransactionFormReady formState;

  const TransactionCategoryGrid({super.key, required this.formState});

  @override
  State<TransactionCategoryGrid> createState() =>
      _TransactionCategoryGridState();
}

class _TransactionCategoryGridState extends State<TransactionCategoryGrid> {
  late final TextEditingController _controller;

  CategoryEntity? get _selected => widget.formState.selectedCategory;
  Color get _typeColor => widget.formState.transactionType.color;

  String _displayText(CategoryEntity? c) => c?.name ?? '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayText(_selected));
  }

  @override
  void didUpdateWidget(TransactionCategoryGrid old) {
    super.didUpdateWidget(old);
    if (old.formState.selectedCategory?.id !=
        widget.formState.selectedCategory?.id) {
      _controller.text = _displayText(_selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = state.categories.where((c) {
          return widget.formState.transactionType == TransactionType.income
              ? c.isIncome
              : c.isExpense;
        }).toList();

        if (categories.isEmpty) return _EmptyCategoriesHint();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(text: 'transaction.add.category'.tr),
            const SizedBox(height: 8),
            AppTextField(
              controller: _controller,
              hint: 'transaction.category.select_hint'.tr,
              readOnly: true,
              prefixWidget: _selected != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _CategoryIconBubble(
                        category: _selected!,
                        color: _typeColor,
                        size: 28,
                        iconSize: 14,
                      ),
                    )
                  : null,
              prefixIcon: _selected == null ? Icons.category_outlined : null,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
              onTap: () => _showPicker(context, categories),
            ),
          ],
        );
      },
    );
  }

  void _showPicker(BuildContext context, List<CategoryEntity> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryPickerSheet(
        categories: categories,
        selectedId: _selected?.id,
        typeColor: _typeColor,
        onSelected: (category) {
          context.read<TransactionFormBloc>().add(SelectCategory(category));
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet with search
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPickerSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedId;
  final Color typeColor;
  final ValueChanged<CategoryEntity> onSelected;

  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedId,
    required this.typeColor,
    required this.onSelected,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryEntity> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories
          : widget.categories
                .where((c) => c.name.toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + count
            Row(
              children: [
                Text('transaction.add.category'.tr, style: AppTextStyles.h3),
                const Spacer(),
                Text(
                  '${_filtered.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search field
            AppTextField(
              controller: _searchController,
              hint: 'transaction.category.search_hint'.tr,
              prefixIcon: Icons.search_rounded,
              showClearButton: true,
              autofocus: false,
            ),
            const SizedBox(height: 14),

            // Grid or empty state
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: _filtered.isEmpty
                  ? _SearchEmptyState(query: _searchController.text)
                  : GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final category = _filtered[index];
                        final isSelected = category.id == widget.selectedId;
                        return _CategoryTile(
                          category: category,
                          isSelected: isSelected,
                          typeColor: widget.typeColor,
                          onTap: () => widget.onSelected(category),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category tile (used inside the sheet grid)
// ─────────────────────────────────────────────────────────────────────────────

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
        duration: const Duration(milliseconds: 160),
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
            _CategoryIconBubble(
              category: category,
              color: typeColor,
              filled: isSelected,
              size: 42,
              iconSize: 20,
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

// ─────────────────────────────────────────────────────────────────────────────
// Reusable icon bubble
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryIconBubble extends StatelessWidget {
  final CategoryEntity category;
  final Color color;
  final bool filled;
  final double size;
  final double iconSize;

  const _CategoryIconBubble({
    required this.category,
    required this.color,
    this.filled = false,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CategoryIconMapper.getIconForCategory(category.iconCodePoint),
        color: filled ? Colors.white : color,
        size: iconSize,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / hint states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCategoriesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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

class _SearchEmptyState extends StatelessWidget {
  final String query;

  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'transaction.category.no_results'.trWith({'query': query}),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
