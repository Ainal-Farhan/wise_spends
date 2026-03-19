// form_category_selector.dart
// Reusable category selector dropdown with icon display
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Category selector dropdown widget
/// Shows selected category with icon, opens bottom sheet with grid picker on tap
class FormCategorySelector extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final String? label;
  final String? hint;
  final bool enabled;
  final ValueChanged<CategoryEntity?> onCategorySelected;

  const FormCategorySelector({
    super.key,
    this.selectedCategory,
    required this.categories,
    this.label,
    this.hint,
    this.enabled = true,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: enabled ? () => _showSelector(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? colorScheme.outline
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                if (selectedCategory != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryIconMapper.getIconForCategory(
                        selectedCategory!.iconCodePoint,
                      ),
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedCategory!.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.category_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hint ?? 'savings.select_default_category'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySelectorSheet(
        categories: categories,
        selectedId: selectedCategory?.id,
        onSelected: (category) {
          onCategorySelected(category);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet with search and grid
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySelectorSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<CategoryEntity> onSelected;

  const _CategorySelectorSheet({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<_CategorySelectorSheet> {
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
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
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + count
            Row(
              children: [
                Text(
                  'savings.select_default_category'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_filtered.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'transaction.category.search_hint'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
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
// Category tile
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = CategoryIconMapper.getIconForCategory(category.iconCodePoint);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
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
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _SearchEmptyState extends StatelessWidget {
  final String query;

  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 36,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'transaction.category.no_results'.trWith({'query': query}),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
