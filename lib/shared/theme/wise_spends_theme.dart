import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WiseSpends color scheme
/// Material 3 design tokens
class WiseSpendsColors {
  // Primary - Green (money/growth)
  static const Color primary = Color(0xFF4CAF82);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);

  // Secondary - Red/Coral (expenses)
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF8A80);
  static const Color secondaryDark = Color(0xFFD32F2F);
  static const Color secondaryContainer = Color(0xFFFFCDD2);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFB71C1C);

  // Tertiary - Blue (transfers)
  static const Color tertiary = Color(0xFF42A5F5);
  static const Color tertiaryLight = Color(0xFF90CAF9);
  static const Color tertiaryDark = Color(0xFF1976D2);
  static const Color tertiaryContainer = Color(0xFFBBDEFB);
  static const Color commitmentContainer = Color(0xFFFEF3C7);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color surface = Color(0xFFF8F9FA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Border/Divider colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE8E8E8);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Budget progress colors
  static const Color budgetGood = Color(0xFF4CAF50); // <60%
  static const Color budgetWarning = Color(0xFFFFA726); // 60-85%
  static const Color budgetDanger = Color(0xFFFF6B6B); // >85%

  // Dark theme colors
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF2C2C2C);

  /// Get color for budget progress percentage
  static Color getBudgetProgressColor(double percentage) {
    if (percentage < 0.6) {
      return budgetGood;
    } else if (percentage < 0.85) {
      return budgetWarning;
    } else {
      return budgetDanger;
    }
  }

  /// Get color for transaction type
  static Color getTransactionTypeColor(dynamic type) {
    // Handle both enum and string types
    final typeStr = type.toString().split('.').last.toLowerCase();
    switch (typeStr) {
      case 'income':
        return success;
      case 'expense':
        return secondary;
      case 'transfer':
        return tertiary;
      default:
        return textSecondary;
    }
  }
}

/// UI Constants for consistent spacing, radius, and sizing
class UIConstants {
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Touch targets (Material Design minimum)
  static const double touchTargetMin = 48.0;
  static const double touchTargetComfortable = 56.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;

  // Card elevations
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

/// Get Material 3 light color scheme
ColorScheme getLightColorScheme() {
  return ColorScheme.fromSeed(
    seedColor: WiseSpendsColors.primary,
    brightness: Brightness.light,
    primary: WiseSpendsColors.primary,
    onPrimary: WiseSpendsColors.onPrimary,
    primaryContainer: WiseSpendsColors.primaryContainer,
    onPrimaryContainer: WiseSpendsColors.onPrimaryContainer,
    secondary: WiseSpendsColors.secondary,
    onSecondary: WiseSpendsColors.onSecondary,
    secondaryContainer: WiseSpendsColors.secondaryContainer,
    onSecondaryContainer: WiseSpendsColors.onSecondaryContainer,
    tertiary: WiseSpendsColors.tertiary,
    onTertiary: WiseSpendsColors.onTertiary,
    tertiaryContainer: WiseSpendsColors.tertiaryContainer,
    surface: WiseSpendsColors.surface,
    onSurface: WiseSpendsColors.textPrimary,
    error: WiseSpendsColors.error,
    onError: Colors.white,
  );
}

/// Get Material 3 dark color scheme
ColorScheme getDarkColorScheme() {
  return ColorScheme.fromSeed(
    seedColor: WiseSpendsColors.primary,
    brightness: Brightness.dark,
    primary: WiseSpendsColors.primaryLight,
    onPrimary: WiseSpendsColors.primaryDark,
    primaryContainer: WiseSpendsColors.primaryDark,
    onPrimaryContainer: WiseSpendsColors.primaryLight,
    secondary: WiseSpendsColors.secondaryLight,
    onSecondary: WiseSpendsColors.secondaryDark,
    secondaryContainer: WiseSpendsColors.secondaryDark,
    onSecondaryContainer: WiseSpendsColors.secondaryLight,
    tertiary: WiseSpendsColors.tertiaryLight,
    onTertiary: WiseSpendsColors.tertiaryDark,
    tertiaryContainer: WiseSpendsColors.tertiaryDark,
    surface: WiseSpendsColors.darkSurface,
    onSurface: Colors.white,
    error: WiseSpendsColors.error,
    onError: Colors.white,
  );
}

/// Get Montserrat text theme
TextTheme getMontserratTextTheme() {
  return GoogleFonts.montserratTextTheme().copyWith(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.montserrat(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.montserrat(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}

/// Get light theme
ThemeData getLightTheme() {
  final colorScheme = getLightColorScheme();
  final textTheme = getMontserratTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: WiseSpendsColors.background,
    textTheme: textTheme.apply(
      bodyColor: WiseSpendsColors.textPrimary,
      displayColor: WiseSpendsColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: WiseSpendsColors.background,
      foregroundColor: WiseSpendsColors.textPrimary,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: WiseSpendsColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: WiseSpendsColors.textPrimary,
        size: 24,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: WiseSpendsColors.background,
      surfaceTintColor: WiseSpendsColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: WiseSpendsColors.divider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: WiseSpendsColors.primary,
        foregroundColor: WiseSpendsColors.onPrimary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: WiseSpendsColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: WiseSpendsColors.primary,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: WiseSpendsColors.primary,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: WiseSpendsColors.primary,
      foregroundColor: WiseSpendsColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WiseSpendsColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.error, width: 2),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: WiseSpendsColors.textHint,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: WiseSpendsColors.textSecondary,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: WiseSpendsColors.error),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: WiseSpendsColors.surface,
      deleteIconColor: WiseSpendsColors.textSecondary,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: WiseSpendsColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      selectedColor: WiseSpendsColors.primaryContainer,
      secondarySelectedColor: WiseSpendsColors.primaryContainer,
    ),
    dividerTheme: const DividerThemeData(
      color: WiseSpendsColors.divider,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: WiseSpendsColors.textPrimary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WiseSpendsColors.background,
      selectedItemColor: WiseSpendsColors.primary,
      unselectedItemColor: WiseSpendsColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: WiseSpendsColors.background,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}

/// Get dark theme
ThemeData getDarkTheme() {
  final colorScheme = getDarkColorScheme();
  final textTheme = getMontserratTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: WiseSpendsColors.darkBackground,
    textTheme: textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: WiseSpendsColors.darkBackground,
      foregroundColor: Colors.white,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: WiseSpendsColors.darkCard,
      surfaceTintColor: WiseSpendsColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: WiseSpendsColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: WiseSpendsColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: WiseSpendsColors.primaryLight,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: WiseSpendsColors.primaryLight,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: WiseSpendsColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WiseSpendsColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: WiseSpendsColors.error, width: 2),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: WiseSpendsColors.textHint,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: WiseSpendsColors.textSecondary,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: WiseSpendsColors.error),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: WiseSpendsColors.darkSurface,
      deleteIconColor: WiseSpendsColors.textSecondary,
      labelStyle: textTheme.labelMedium?.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      selectedColor: WiseSpendsColors.primaryDark,
      secondarySelectedColor: WiseSpendsColors.primaryDark,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3D3D3D),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: WiseSpendsColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WiseSpendsColors.darkBackground,
      selectedItemColor: WiseSpendsColors.primary,
      unselectedItemColor: WiseSpendsColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: WiseSpendsColors.darkCard,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}
