import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

/// Size options for AppAvatar
enum AppAvatarSize {
  /// Small - 32dp
  small,

  /// Medium - 40dp (default)
  medium,

  /// Large - 48dp
  large,

  /// Extra large - 64dp
  xLarge,

  /// Hero - 80dp
  hero,
}

/// WiseSpends AppAvatar Component
///
/// A standardized avatar component for displaying category icons with colored backgrounds.
///
/// Features:
/// - Multiple sizes (small, medium, large, xLarge, hero)
/// - Icon support
/// - Image support
/// - Colored background circle
/// - Optional border
/// - Consistent styling
///
/// Usage:
/// ```dart
/// // Icon avatar
/// AppAvatar(
///   icon: Icons.shopping_bag,
///   backgroundColor: AppColors.primary,
/// )
///
/// // With custom size
/// AppAvatar.large(
///   icon: Icons.home,
///   backgroundColor: AppColors.secondary,
/// )
///
/// // Image avatar
/// AppAvatar.image(
///   imageUrl: 'https://example.com/image.png',
/// )
///
/// // Category avatar (with automatic color)
/// AppAvatar.category(
///   categoryId: 'food',
///   icon: Icons.restaurant,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;
  final AppAvatarSize size;
  final double? borderWidth;
  final Color? borderColor;
  final String? semanticLabel;

  const AppAvatar({
    super.key,
    this.icon,
    this.imageUrl,
    this.label,
    this.backgroundColor,
    this.iconColor,
    this.size = AppAvatarSize.medium,
    this.borderWidth,
    this.borderColor,
    this.semanticLabel,
  });

  /// Large size constructor
  factory AppAvatar.large({
    IconData? icon,
    String? imageUrl,
    String? label,
    Color? backgroundColor,
    Color? iconColor,
    double? borderWidth,
    Color? borderColor,
    String? semanticLabel,
  }) {
    return AppAvatar(
      icon: icon,
      imageUrl: imageUrl,
      label: label,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: AppAvatarSize.large,
      borderWidth: borderWidth,
      borderColor: borderColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Extra large size constructor
  factory AppAvatar.xLarge({
    IconData? icon,
    String? imageUrl,
    String? label,
    Color? backgroundColor,
    Color? iconColor,
    double? borderWidth,
    Color? borderColor,
    String? semanticLabel,
  }) {
    return AppAvatar(
      icon: icon,
      imageUrl: imageUrl,
      label: label,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: AppAvatarSize.xLarge,
      borderWidth: borderWidth,
      borderColor: borderColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Hero size constructor
  factory AppAvatar.hero({
    IconData? icon,
    String? imageUrl,
    String? label,
    Color? backgroundColor,
    Color? iconColor,
    double? borderWidth,
    Color? borderColor,
    String? semanticLabel,
  }) {
    return AppAvatar(
      icon: icon,
      imageUrl: imageUrl,
      label: label,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: AppAvatarSize.hero,
      borderWidth: borderWidth,
      borderColor: borderColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Category avatar with automatic color based on category
  factory AppAvatar.category({
    required String categoryId,
    required IconData icon,
    AppAvatarSize size = AppAvatarSize.medium,
    String? semanticLabel,
  }) {
    return AppAvatar(
      icon: icon,
      backgroundColor: _getColorForCategory(categoryId),
      iconColor: _getIconColorForCategory(categoryId),
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  /// Image avatar
  factory AppAvatar.image({
    required String imageUrl,
    AppAvatarSize size = AppAvatarSize.medium,
    String? semanticLabel,
  }) {
    return AppAvatar(
      imageUrl: imageUrl,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, child: avatar);
    }

    return avatar;
  }

  Widget _buildAvatar() {
    final sizeValue = _getSizeValue();

    Widget avatarContent;

    if (imageUrl != null) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: sizeValue,
          height: sizeValue,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(sizeValue);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator(sizeValue);
          },
        ),
      );
    } else if (icon != null) {
      avatarContent = _buildFallbackIcon(sizeValue);
    } else if (label != null) {
      avatarContent = _buildLabelAvatar(sizeValue);
    } else {
      avatarContent = _buildFallbackIcon(sizeValue);
    }

    if (borderWidth != null && borderWidth! > 0) {
      return Container(
        width: sizeValue + borderWidth! * 2,
        height: sizeValue + borderWidth! * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.divider,
            width: borderWidth!,
          ),
        ),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallbackIcon(double sizeValue) {
    final iconSize = sizeValue * 0.5;

    return Container(
      width: sizeValue,
      height: sizeValue,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.category,
        size: iconSize,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }

  Widget _buildLabelAvatar(double sizeValue) {
    return Container(
      width: sizeValue,
      height: sizeValue,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label!.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: sizeValue * 0.4,
            fontWeight: FontWeight.bold,
            color: iconColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double sizeValue) {
    return Container(
      width: sizeValue,
      height: sizeValue,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: sizeValue * 0.4,
          height: sizeValue * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  double _getSizeValue() {
    switch (size) {
      case AppAvatarSize.small:
        return 32;
      case AppAvatarSize.medium:
        return 40;
      case AppAvatarSize.large:
        return 48;
      case AppAvatarSize.xLarge:
        return 64;
      case AppAvatarSize.hero:
        return 80;
    }
  }

  static Color _getColorForCategory(String categoryId) {
    // Generate consistent colors based on category ID hash
    final colors = [
      AppColors.primaryContainer,
      AppColors.secondaryContainer,
      AppColors.tertiaryContainer,
      AppColors.primaryContainer,
      AppColors.secondaryContainer,
    ];

    final index = categoryId.hashCode.abs() % colors.length;
    return colors[index];
  }

  static Color _getIconColorForCategory(String categoryId) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.primary,
      AppColors.secondary,
    ];

    final index = categoryId.hashCode.abs() % colors.length;
    return colors[index];
  }
}

/// Category icon with background - specialized for transaction categories
class CategoryAvatar extends StatelessWidget {
  final IconData icon;
  final String categoryId;
  final AppAvatarSize size;
  final String? semanticLabel;

  const CategoryAvatar({
    super.key,
    required this.icon,
    required this.categoryId,
    this.size = AppAvatarSize.medium,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar.category(
      categoryId: categoryId,
      icon: icon,
      size: size,
      semanticLabel: semanticLabel ?? 'Category icon',
    );
  }
}
