import 'package:flutter/material.dart';

/// WiseSpends Typography System
/// Consistent text styles using Montserrat font family
///
/// Usage: Always use these styles instead of inline TextStyle creation
/// Example: `style: AppTextStyles.h1` instead of `style: TextStyle(fontSize: 24)`

class AppTextStyles {
  AppTextStyles._();

  /// Font family for all text
  static const String fontFamily = 'Montserrat';

  // ==========================================================================
  // HEADINGS - For titles and prominent text
  // ==========================================================================

  /// H1 - 24sp, Bold
  /// Usage: Screen titles, hero headings
  static TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// H2 - 20sp, Bold
  /// Usage: Section headings, card titles
  static TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// H3 - 16sp, SemiBold
  /// Usage: Subsection headings, prominent labels
  static TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
  );

  // ==========================================================================
  // BODY TEXT - For general content
  // ==========================================================================

  /// Body Large - 16sp, Regular
  /// Usage: Primary body text, important content
  static TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
  );

  /// Body Medium - 14sp, Regular
  /// Usage: Standard body text, descriptions
  static TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
  );

  /// Body Small - 12sp, Regular
  /// Usage: Secondary text, metadata
  static TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
  );

  // ==========================================================================
  /// Body Medium - 14sp, SemiBold
  /// Usage: Emphasized body text, important labels
  static TextStyle bodySemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
  );

  /// Body Large - 16sp, SemiBold
  /// Usage: Emphasized larger text
  static TextStyle bodyLargeSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
  );

  // ==========================================================================
  // AMOUNT DISPLAYS - For monetary values
  // ==========================================================================

  /// Amount Extra Large - 32sp, Bold
  /// Usage: Hero balance displays, primary amounts
  static TextStyle amountXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Amount Large - 24sp, Bold
  /// Usage: Large amount displays, card amounts
  static TextStyle amountLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.3,
  );

  /// Amount Medium - 20sp, Bold
  /// Usage: Medium amount displays
  static TextStyle amountMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.3,
  );

  /// Amount Small - 16sp, SemiBold
  /// Usage: Small amount displays, list item amounts
  static TextStyle amountSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
  );

  // ==========================================================================
  // LABELS & BUTTONS - For interactive elements
  // ==========================================================================

  /// Label Large - 14sp, SemiBold
  /// Usage: Button text, prominent labels
  static TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label Medium - 12sp, SemiBold
  /// Usage: Chip text, small labels
  static TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
    letterSpacing: 0.15,
  );

  /// Label Small - 11sp, Medium
  /// Usage: Tiny labels, overlines
  static TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ==========================================================================
  // CAPTION & HELPER TEXT - For supplementary information
  // ==========================================================================

  /// Caption - 12sp, Regular
  /// Usage: Helper text, hints, timestamps
  static TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
  );

  /// Caption Small - 11sp, Regular
  /// Usage: Tiny helper text
  static TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFE0E0E0),
    height: 1.4,
  );

  /// Overline - 10sp, SemiBold, Uppercase
  /// Usage: Category labels, section markers
  static TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
    letterSpacing: 1.5,
  );

  // ==========================================================================
  // SPECIALIZED STYLES
  // ==========================================================================

  /// Balance Display - 28sp, Bold
  /// Usage: Main balance display on home screen
  static TextStyle balanceDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Stat Number - 20sp, Bold
  /// Usage: Statistics, metrics
  static TextStyle statNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
    height: 1.3,
  );

  /// Empty State Title - 18sp, SemiBold
  /// Usage: Empty state headings
  static TextStyle emptyStateTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1A1A),
    height: 1.4,
  );

  /// Empty State Subtitle - 14sp, Regular
  /// Usage: Empty state descriptions
  static TextStyle emptyStateSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1A1A1A),
    height: 1.5,
  );

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  /// Get text style with custom font weight
  static TextStyle withWeight(TextStyle base, FontWeight weight) {
    return base.copyWith(fontWeight: weight);
  }

  /// Get text style with custom font size
  static TextStyle withSize(TextStyle base, double size) {
    return base.copyWith(fontSize: size);
  }

  /// Get amount style with transaction type color
  static TextStyle getAmountStyleForType(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'income':
        color = const Color(0xFF4CAF82);
        break;
      case 'expense':
        color = const Color(0xFFFF6B6B);
        break;
      case 'transfer':
        color = const Color(0xFF42A5F5);
        break;
      default:
        color = const Color(0xFF1A1A1A);
    }
    return amountMedium.copyWith(color: color);
  }

  /// Get status badge style
  static TextStyle getBadgeStyle(String status) {
    return labelMedium.copyWith(color: const Color(0xFF4CAF82));
  }
}
