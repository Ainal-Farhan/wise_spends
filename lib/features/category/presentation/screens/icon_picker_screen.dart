import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Icon picker screen with categorized icons for better UX
/// Supports search, categories, and preview functionality
class IconPickerScreen extends StatefulWidget {
  final int? selectedIconCodePoint;
  final Function(int codePoint) onIconSelected;

  const IconPickerScreen({
    super.key,
    this.selectedIconCodePoint,
    required this.onIconSelected,
  });

  @override
  State<IconPickerScreen> createState() => _IconPickerScreenState();
}

class _IconPickerScreenState extends State<IconPickerScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  late int _selectedCodePoint;

  // Preview text for testing how icon looks with category name
  final _previewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCodePoint = widget.selectedIconCodePoint ?? Icons.category.codePoint;
    _previewController.text = 'Preview';
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredIcons = _getFilteredIcons();

    return Scaffold(
      appBar: AppBar(
        title: Text('categories.select_icon'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onIconSelected(_selectedCodePoint);
              Navigator.pop(context);
            },
            tooltip: 'general.select'.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),
          
          // Category Filter Chips
          _buildCategoryFilter(theme),
          
          // Preview Section
          _buildPreviewSection(theme),
          
          // Icon Grid
          Expanded(
            child: filteredIcons.isEmpty
                ? _buildEmptyState(theme)
                : _buildIconGrid(filteredIcons, theme),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bar
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'icons.search'.tr,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category Filter
  // ---------------------------------------------------------------------------

  Widget _buildCategoryFilter(ThemeData theme) {
    final categories = [
      {'id': null, 'label': 'icons.all'.tr, 'icon': Icons.apps},
      {'id': 'food', 'label': 'icons.food'.tr, 'icon': Icons.restaurant},
      {'id': 'transport', 'label': 'icons.transport'.tr, 'icon': Icons.directions_car},
      {'id': 'shopping', 'label': 'icons.shopping'.tr, 'icon': Icons.shopping_bag},
      {'id': 'entertainment', 'label': 'icons.entertainment'.tr, 'icon': Icons.movie},
      {'id': 'bills', 'label': 'icons.bills'.tr, 'icon': Icons.receipt_long},
      {'id': 'health', 'label': 'icons.health'.tr, 'icon': Icons.medical_services},
      {'id': 'education', 'label': 'icons.education'.tr, 'icon': Icons.school},
      {'id': 'income', 'label': 'icons.income'.tr, 'icon': Icons.attach_money},
      {'id': 'technology', 'label': 'icons.technology'.tr, 'icon': Icons.devices},
      {'id': 'home', 'label': 'icons.home'.tr, 'icon': Icons.home},
      {'id': 'sports', 'label': 'icons.sports'.tr, 'icon': Icons.sports},
      {'id': 'travel', 'label': 'icons.travel'.tr, 'icon': Icons.flight},
      {'id': 'other', 'label': 'icons.other'.tr, 'icon': Icons.more_horiz},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(category['label'] as String),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category['id'] as String? : null;
              });
            },
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: theme.colorScheme.onPrimary,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Preview Section
  // ---------------------------------------------------------------------------

  Widget _buildPreviewSection(ThemeData theme) {
    final selectedIcon = IconData(
      _selectedCodePoint,
      fontFamily: 'MaterialIcons',
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon Preview
            SizedBox(
              width: 64,
              height: 64,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  selectedIcon,
                  color: theme.colorScheme.onPrimary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Preview Text Field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'icons.preview'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _previewController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
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
  // Icon Grid
  // ---------------------------------------------------------------------------

  Widget _buildIconGrid(List<Map<String, dynamic>> icons, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconData = icons[index];
        final codePoint = iconData['codePoint'] as int;
        final icon = IconData(codePoint, fontFamily: 'MaterialIcons');
        final label = iconData['label'] as String;
        final isSelected = codePoint == _selectedCodePoint;

        return GestureDetector(
          onTap: () => setState(() => _selectedCodePoint = codePoint),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'icons.no_results'.tr,
            style: AppTextStyles.bodySemiBold.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'icons.no_results_desc'.tr,
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _getFilteredIcons() {
    final allIcons = CategoryIconMapper.getAllAvailableIcons();
    
    return allIcons.where((iconData) {
      final matchesSearch = _searchQuery.isEmpty ||
          iconData['label'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null ||
          iconData['category'] == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
