import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  /// Get the light theme
  static ThemeData getLightTheme(BuildContext context) {
    final colorScheme = _createLightColorScheme();
    final textTheme = _createTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest,
      textTheme: textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: AppElevation.none,
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FA),
        foregroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: const Color(0xFF1A1A1A),
          size: AppIconSize.md,
        ),
        actionsIconTheme: IconThemeData(
          color: const Color(0xFF1A1A1A),
          size: AppIconSize.md,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevation.none,
          backgroundColor: const Color(0xFF4CAF82),
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.38),
          disabledForegroundColor: const Color(0xFFE0E0E0),
          minimumSize: const Size(double.infinity, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          side: BorderSide(color: const Color(0xFF4CAF82), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          foregroundColor: const Color(0xFF4CAF82),
          disabledForegroundColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTouchTarget.min, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          foregroundColor: const Color(0xFF4CAF82),
          disabledForegroundColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF82),
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(double.infinity, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppElevation.sm,
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.fab)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFF4CAF82), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFB00020)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFB00020), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFFE0E0E0),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFF4CAF82),
        ),
        errorStyle: AppTextStyles.captionSmall.copyWith(
          color: const Color(0xFFB00020),
        ),
        errorMaxLines: 2,
        prefixIconColor: const Color(0xFF1A1A1A),
        suffixIconColor: const Color(0xFF1A1A1A),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        deleteIconColor: const Color(0xFF1A1A1A),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        selectedColor: const Color(0xFF4CAF82),
        secondarySelectedColor: const Color(0xFF4CAF82),
        disabledColor: const Color(0xFFF8F9FA),
        checkmarkColor: const Color(0xFF4CAF82),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: const Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
        indent: AppSpacing.lg,
        endIndent: AppSpacing.lg,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.lg,
        actionTextColor: const Color(0xFF4CAF82),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        selectedItemColor: const Color(0xFF4CAF82),
        unselectedItemColor: const Color(0xFFE0E0E0),
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.lg,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: AppElevation.lg,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: AppElevation.lg,
        modalBackgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        dragHandleColor: const Color(0xFFE0E0E0),
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),

      // Navigation Drawer Theme
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: AppElevation.lg,
        indicatorColor: const Color(0xFF4CAF82),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFF4CAF82),
            );
          }
          return AppTextStyles.labelLarge;
        }),
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: AppElevation.none,
        indicatorColor: const Color(0xFF4CAF82),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(0xFF4CAF82),
        linearTrackColor: const Color(0xFFE0E0E0),
        circularTrackColor: const Color(0xFFE0E0E0),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4CAF82);
          }
          return const Color(0xFF1A1A1A);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4CAF82);
          }
          return const Color(0xFFE0E0E0);
        }),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4CAF82);
          }
          return const Color(0xFF1A1A1A);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4CAF82);
          }
          return const Color(0xFF1A1A1A);
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF4CAF82),
        inactiveTrackColor: const Color(0xFFE0E0E0),
        thumbColor: const Color(0xFF4CAF82),
        overlayColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall,
        dense: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: const Color(0xFF1A1A1A),
        size: AppIconSize.md,
      ),

      // Action Icon Theme
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) => Icon(
          Icons.arrow_back_ios_new_rounded,
          color: const Color(0xFF1A1A1A),
          size: AppIconSize.md,
        ),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTextStyles.captionSmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // Badge Theme
      badgeTheme: BadgeThemeData(
        backgroundColor: const Color(0xFFFF6B6B),
        textColor: Colors.white,
      ),

      // Search Bar Theme
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
        elevation: WidgetStateProperty.all(AppElevation.none),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }

  /// Get the dark theme
  static ThemeData getDarkTheme(BuildContext context) {
    final colorScheme = _createDarkColorScheme();
    final textTheme = _createTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest,
      textTheme: textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: AppElevation.none,
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FA),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: AppIconSize.md,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: const Color(0xFF4CAF82),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: const Color(0xFF4CAF82)),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevation.none,
          backgroundColor: const Color(0xFF4CAF82),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFF4CAF82)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFF4CAF82)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFF4CAF82), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFB00020)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: const Color(0xFFB00020), width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFFE0E0E0),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
        errorStyle: AppTextStyles.captionSmall.copyWith(
          color: const Color(0xFFB00020),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFF8F9FA),
        selectedItemColor: const Color(0xFF4CAF82),
        unselectedItemColor: const Color(0xFFE0E0E0),
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.lg,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF4CAF82),
        elevation: AppElevation.lg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white70,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: AppElevation.lg,
        modalBackgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        dragHandleColor: const Color(0xFF4CAF82),
        showDragHandle: true,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: const Color(0xFF4CAF82),
        thickness: 1,
        space: 1,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Create light color scheme
  static ColorScheme _createLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF82),
      brightness: Brightness.light,
      primary: const Color(0xFF4CAF82),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFF4CAF82),
      onPrimaryContainer: const Color(0xFFFFFFFF),
      secondary: const Color(0xFFFF6B6B),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFF6B6B),
      onSecondaryContainer: const Color(0xFFFFFFFF),
      tertiary: const Color(0xFF42A5F5),
      onTertiary: const Color(0xFF4CAF82),
      tertiaryContainer: const Color(0xFF42A5F5),
      surface: const Color(0xFFF8F9FA),
      onSurface: const Color(0xFF1A1A1A),
      error: const Color(0xFFB00020),
      onError: Colors.white,
    );
  }

  /// Create dark color scheme
  static ColorScheme _createDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF82),
      brightness: Brightness.dark,
      primary: const Color(0xFF4CAF82),
      onPrimary: const Color(0xFF4CAF82),
      primaryContainer: const Color(0xFF4CAF82),
      onPrimaryContainer: const Color(0xFF4CAF82),
      secondary: const Color(0xFFFF6B6B),
      onSecondary: const Color(0xFFFF6B6B),
      secondaryContainer: const Color(0xFFFF6B6B),
      onSecondaryContainer: const Color(0xFFFF6B6B),
      tertiary: const Color(0xFF42A5F5),
      onTertiary: const Color(0xFF42A5F5),
      tertiaryContainer: const Color(0xFF42A5F5),
      surface: const Color(0xFFF8F9FA),
      onSurface: Colors.white,
      error: const Color(0xFFB00020),
      onError: Colors.white,
    );
  }

  /// Create Montserrat text theme
  static TextTheme _createTextTheme() {
    return GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: const Color(0xFF1A1A1A),
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: const Color(0xFF1A1A1A),
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF1A1A1A),
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF1A1A1A),
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF1A1A1A),
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: const Color(0xFF1A1A1A),
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: const Color(0xFF1A1A1A),
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: const Color(0xFF1A1A1A),
      ),
    );
  }
}
