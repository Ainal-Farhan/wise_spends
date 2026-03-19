import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/category/presentation/screens/add_category_screen.dart';
import 'package:wise_spends/features/category/presentation/screens/edit_category_screen.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/custom_dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Enhanced Category Management Screen
/// Features:
/// - Modern glass morphism design
/// - Refined header with gradient background
/// - Better visual hierarchy
/// - Smooth animations and transitions
/// - Haptic feedback for interactions
/// - Swipe-to-delete support
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

class _CategoryManagementScreenContent extends StatefulWidget {
  const _CategoryManagementScreenContent();

  @override
  State<_CategoryManagementScreenContent> createState() =>
      _CategoryManagementScreenContentState();
}

class _CategoryManagementScreenContentState
    extends State<_CategoryManagementScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: NavigationSidebar(),
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              stretch: true,
              elevation: 0,
              backgroundColor: colorScheme.primary,
              title: Text(
                'categories.manage'.tr,
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _navigateToAddCategory(context);
                  },
                  tooltip: 'categories.add'.tr,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: _buildHeaderBackground(context, theme),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildModernTabBar(theme),
              ),
            ),
          ];
        },
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return _buildLoadingState();
            } else if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildCategoryList(context, state);
            } else if (state is CategoryError) {
              return _buildErrorState(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header Background with Glass Stats Card
  // ---------------------------------------------------------------------------

  Widget _buildHeaderBackground(BuildContext context, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient Layer
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
          ),
        ),
        // Stats Card Layer
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      return _buildGlassStatsCard(context, state);
                    }
                    return const SizedBox(height: 80);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatsCard(BuildContext context, CategoryLoaded state) {
    final incomeCount = state.categories.where((c) => c.isIncome).length;
    final expenseCount = state.categories.where((c) => c.isExpense).length;
    final totalCount = state.categories.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'categories.total'.tr,
            totalCount,
            Icons.category_outlined,
          ),
          VerticalDivider(
            color: Colors.white.withValues(alpha: 0.3),
            indent: 10,
            endIndent: 10,
          ),
          _buildStatItem(
            context,
            'categories.income'.tr,
            incomeCount,
            Icons.arrow_downward,
          ),
          VerticalDivider(
            color: Colors.white.withValues(alpha: 0.3),
            indent: 10,
            endIndent: 10,
          ),
          _buildStatItem(
            context,
            'categories.expense'.tr,
            expenseCount,
            Icons.arrow_upward,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Modern TabBar
  // ---------------------------------------------------------------------------

  Widget _buildModernTabBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        dividerColor: Colors.transparent,
        onTap: (index) {
          HapticFeedback.selectionClick();
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
    );
  }

  // ---------------------------------------------------------------------------
  // Category List
  // ---------------------------------------------------------------------------

  Widget _buildCategoryList(BuildContext context, CategoryLoaded state) {
    final filterType = state.filterType ?? 'all';
    final categories = filterType == 'income'
        ? state.categories.where((c) => c.isIncome).toList()
        : filterType == 'expense'
        ? state.categories.where((c) => c.isExpense).toList()
        : state.categories;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<CategoryBloc>().add(LoadCategoriesEvent()),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(context, categories[index], index);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category Card
  // ---------------------------------------------------------------------------

  Widget _buildCategoryCard(BuildContext context, dynamic category, int index) {
    final theme = Theme.of(context);
    final iconData = category.iconCodePoint != null
        ? CategoryIconMapper.getIconForCategory(category.iconCodePoint)
        : Icons.category;

    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    final color = _getCategoryColor(context, category);

    final typeLabel = isIncome && isExpense
        ? 'categories.both'.tr
        : isIncome
        ? 'categories.income'.tr
        : 'categories.expense'.tr;

    final typeColor = isIncome && isExpense
        ? theme.colorScheme.tertiary
        : isIncome
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Dismissible(
      key: Key(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDelete(context, category);
      },
      onDismissed: (direction) {
        _deleteCategory(context, category);
      },
      child: Hero(
        tag: 'category-${category.id}',
        child: AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            onTap: () => _showEditCategoryScreen(context, category),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(iconData, color: color, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name ?? 'Unnamed',
                          style: AppTextStyles.bodyLargeSemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildTypeBadge(label: typeLabel, color: typeColor),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.edit_outlined,
                        onTap: () => _showEditCategoryScreen(context, category),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading State
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'general.loading'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'categories.no_categories'.tr,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'categories.no_categories_desc'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'categories.add'.tr,
                icon: Icons.add,
                onPressed: () => _navigateToAddCategory(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error State
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(BuildContext context, CategoryError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('general.error'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: 'general.retry'.tr,
              icon: Icons.refresh,
              onPressed: () =>
                  context.read<CategoryBloc>().add(LoadCategoriesEvent()),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  Color _getCategoryColor(BuildContext context, dynamic category) {
    final isIncome = category.isIncome == true;
    final isExpense = category.isExpense == true;
    if (isIncome && isExpense) return Theme.of(context).colorScheme.tertiary;
    if (isIncome) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.secondary;
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    ).then((_) {
      context.read<CategoryBloc>().add(LoadCategoriesEvent());
    });
  }

  void _showEditCategoryScreen(BuildContext context, dynamic category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCategoryScreen(category: category)),
    ).then((_) {
      context.read<CategoryBloc>().add(LoadCategoriesEvent());
    });
  }

  Future<bool> _confirmDelete(BuildContext context, dynamic category) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => CustomDialog(
            config: CustomDialogConfig(
              title: 'general.delete'.tr,
              message: 'categories.delete_confirm'.trWith({
                'name': category.name ?? '',
              }),
              icon: Icons.delete_outline_rounded,
              iconColor: theme.colorScheme.secondary,
              buttons: [
                CustomDialogButton(
                  text: 'general.cancel'.tr,
                  onPressed: () => Navigator.pop(dialogContext, false),
                ),
                CustomDialogButton(
                  text: 'general.delete'.tr,
                  isDestructive: true,
                  onPressed: () => Navigator.pop(dialogContext, true),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _deleteCategory(BuildContext context, dynamic category) {
    final categoryBloc = context.read<CategoryBloc>();
    categoryBloc.add(DeleteCategoryEvent(category.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text('categories.deleted'.tr),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
