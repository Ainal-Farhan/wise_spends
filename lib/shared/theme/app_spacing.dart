/// WiseSpends Spacing & Radius System
/// Consistent spacing and border radius values across the app
///
/// All spacing values are multiples of 4dp (Material Design baseline)
/// Usage: Always use these constants instead of hardcoded values
/// Example: `padding: EdgeInsets.all(AppSpacing.md)` instead of `padding: EdgeInsets.all(16)`
library;

class AppSpacing {
  AppSpacing._();

  // ==========================================================================
  // SPACING SCALE - Based on 4dp grid system
  // ==========================================================================

  /// Extra Small - 4dp
  /// Usage: Tight spacing between related elements
  static const double xs = 4.0;

  /// Small - 8dp
  /// Usage: Spacing between icons and text, small gaps
  static const double sm = 8.0;

  /// Medium - 12dp
  /// Usage: Standard spacing between related components
  static const double md = 12.0;

  /// Large - 16dp
  /// Usage: Standard padding for cards, screens
  static const double lg = 16.0;

  /// Extra Large - 20dp
  /// Usage: Larger section spacing
  static const double xl = 20.0;

  /// Double Extra Large - 24dp
  /// Usage: Major section separation
  static const double xxl = 24.0;

  /// Triple Extra Large - 32dp
  /// Usage: Large margins between major sections
  static const double xxxl = 32.0;

  /// Quadruple Extra Large - 48dp
  /// Usage: Maximum spacing for hero sections
  static const double xxxxl = 48.0;

  // ==========================================================================
  // HORIZONTAL SPACING PRESETS
  // ==========================================================================

  /// Standard horizontal padding for screen edges
  static const double horizontalPadding = lg;

  /// Comfortable horizontal padding
  static const double horizontalPaddingComfortable = xl;

  // ==========================================================================
  // VERTICAL SPACING PRESETS
  // ==========================================================================

  /// Standard vertical spacing between sections
  static const double sectionSpacing = xxl;

  /// Spacing between related components
  static const double componentSpacing = lg;

  /// Spacing between list items
  static const double listItemSpacing = sm;
}

/// Border Radius Constants
/// Usage: Always use these constants for consistent corner rounding
class AppRadius {
  AppRadius._();

  // ==========================================================================
  // BORDER RADIUS SCALE
  // ==========================================================================

  /// Small - 4dp
  /// Usage: Minimal rounding for subtle edges
  static const double xs = 4.0;

  /// Small - 8dp
  /// Usage: Input fields, small buttons, chips
  static const double sm = 8.0;

  /// Medium - 12dp
  /// Usage: Cards, standard buttons, dialogs
  static const double md = 12.0;

  /// Large - 16dp
  /// Usage: Large cards, bottom sheets
  static const double lg = 16.0;

  /// Extra Large - 20dp
  /// Usage: Hero cards, prominent containers
  static const double xl = 20.0;

  /// Double Extra Large - 24dp
  /// Usage: Maximum rounding for special cards
  static const double xxl = 24.0;

  /// Full - 999dp (Pill/Circle)
  /// Usage: Pill-shaped buttons, chips, circular containers
  static const double full = 999.0;

  // ==========================================================================
  // COMPONENT-SPECIFIC RADIUS PRESETS
  // ==========================================================================

  /// Card border radius (standard)
  static const double card = md;

  /// Input field border radius
  static const double input = sm;

  /// Button border radius
  static const double button = lg;

  /// FAB border radius
  static const double fab = xl;

  /// Bottom sheet border radius (top corners)
  static const double bottomSheet = xl;

  /// Dialog border radius
  static const double dialog = lg;

  /// Chip border radius
  static const double chip = full;

  /// Avatar border radius (circle)
  static const double avatar = full;
}

/// Elevation Constants
/// Usage: Consistent shadow depths for elevation
class AppElevation {
  AppElevation._();

  /// No elevation
  static const double none = 0.0;

  /// Small elevation - 2dp
  /// Usage: Subtle cards, low-priority elements
  static const double xs = 2.0;

  /// Medium elevation - 4dp
  /// Usage: Standard cards, buttons
  static const double sm = 4.0;

  /// Large elevation - 8dp
  /// Usage: Prominent cards, FAB
  static const double md = 8.0;

  /// Extra large elevation - 12dp
  /// Usage: Modal elements, dialogs
  static const double lg = 12.0;

  /// Maximum elevation - 16dp
  /// Usage: Highest priority elements
  static const double xl = 16.0;
}

/// Icon Size Constants
/// Usage: Consistent icon sizing across the app
class AppIconSize {
  AppIconSize._();

  /// Small icon - 16dp
  static const double xs = 16.0;

  /// Medium icon - 20dp
  static const double sm = 20.0;

  /// Standard icon - 24dp
  static const double md = 24.0;

  /// Large icon - 32dp
  static const double lg = 32.0;

  /// Extra large icon - 48dp
  static const double xl = 48.0;

  /// Hero icon - 64dp
  static const double hero = 64.0;
}

/// Touch Target Constants
/// Usage: Ensure accessible touch targets (Material Design guidelines)
class AppTouchTarget {
  AppTouchTarget._();

  /// Minimum touch target - 48dp (Material Design minimum)
  static const double min = 48.0;

  /// Comfortable touch target - 56dp
  static const double comfortable = 56.0;

  /// Large touch target - 64dp
  static const double large = 64.0;
}
