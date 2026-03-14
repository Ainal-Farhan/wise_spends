// form_category_picker.dart
// Reusable category picker with search and grid display
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _logger = WiseLogger();

/// Category item for the picker
class FormCategoryItem {
  final String id;
  final String name;
  final IconData? icon;
  final int? iconCodePoint;
  final bool isEnabled;

  const FormCategoryItem({
    required this.id,
    required this.name,
    this.icon,
    this.iconCodePoint,
    this.isEnabled = true,
  });

  IconData get iconData {
    if (icon != null) return icon!;
    if (iconCodePoint != null) {
      return IconData(iconCodePoint!, fontFamily: 'MaterialIcons');
    }
    return Icons.category_outlined;
  }
}

class FormCategoryPicker extends StatefulWidget {
  final FormCategoryItem? selectedCategory;
  final List<FormCategoryItem> categories;
  final Color typeColor;
  final String? label;
  final String? hint;
  final bool enabled;
  final ValueChanged<FormCategoryItem?> onCategorySelected;

  const FormCategoryPicker({
    super.key,
    this.selectedCategory,
    required this.categories,
    required this.typeColor,
    this.label,
    this.hint,
    this.enabled = true,
    required this.onCategorySelected,
  });

  @override
  State<FormCategoryPicker> createState() => _FormCategoryPickerState();
}

class _FormCategoryPickerState extends State<FormCategoryPicker> {
  late final TextEditingController _controller;

  String _displayText(FormCategoryItem? c) => c?.name ?? '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _displayText(widget.selectedCategory),
    );
  }

  @override
  void didUpdateWidget(FormCategoryPicker old) {
    super.didUpdateWidget(old);
    if (old.selectedCategory?.id != widget.selectedCategory?.id) {
      _controller.text = _displayText(widget.selectedCategory);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _SectionLabel(text: widget.label!),
        if (widget.label != null) const SizedBox(height: 8),
        AppTextField(
          controller: _controller,
          hint: widget.hint ?? 'transaction.category.select_hint'.tr,
          readOnly: true,
          enabled: widget.enabled,
          prefixWidget: widget.selectedCategory != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _CategoryIconBubble(
                    category: widget.selectedCategory!,
                    color: widget.typeColor,
                    size: 28,
                    iconSize: 14,
                  ),
                )
              : null,
          prefixIcon: widget.selectedCategory == null
              ? Icons.category_outlined
              : null,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: widget.enabled ? () => _showPicker(context) : null,
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    _logger.debug(
      'Opening category picker, ${widget.categories.length} categories available',
      tag: 'FormCategoryPicker',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryPickerSheet(
        categories: widget.categories,
        selectedId: widget.selectedCategory?.id,
        typeColor: widget.typeColor,
        onSelected: (category) {
          _logger.debug(
            'Category selected: ${category.name} (${category.id})',
            tag: 'FormCategoryPicker',
          );
          widget.onCategorySelected(category);
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
  final List<FormCategoryItem> categories;
  final String? selectedId;
  final Color typeColor;
  final ValueChanged<FormCategoryItem> onSelected;

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
  List<FormCategoryItem> _filtered = [];

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
// Category tile
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final FormCategoryItem category;
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
// Category icon bubble
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryIconBubble extends StatelessWidget {
  final FormCategoryItem category;
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
        category.iconData,
        color: filled ? Colors.white : color,
        size: iconSize,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.bodySemiBold);
  }
}
