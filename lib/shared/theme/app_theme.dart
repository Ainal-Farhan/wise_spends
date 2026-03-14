import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
// Keep every raw colour in one place so light/dark themes stay consistent.

class _Light {
  // Brand
  static const primary = Color(0xFF4CAF82); // green
  static const primaryDark = Color(0xFF388E5E);
  static const primaryLight = Color(0xFFB7EDD4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFDCF5EA);
  static const onPrimaryContainer = Color(0xFF00391F);

  // Accent / error
  static const secondary = Color(0xFFFF6B6B); // coral-red
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFFDAD6);
  static const onSecondaryContainer = Color(0xFF410001);

  // Info / tertiary
  static const tertiary = Color(0xFF42A5F5); // blue
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFD3E4FF);
  static const onTertiaryContainer = Color(0xFF001C3D);

  // Surfaces
  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F4F1);
  static const onSurface = Color(0xFF1A1A1A);
  static const onSurfaceVariant = Color(0xFF44493F);
  static const outline = Color(0xFFD0D5DD);
  static const outlineVariant = Color(0xFFE9ECEF);

  // Semantic
  static const error = Color(0xFFB00020);
  static const onError = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5F6368);
  static const textHint = Color(0xFFADB5BD);

  // Misc
  static const divider = Color(0xFFE0E0E0);
  static const shadow = Color(0x1A000000); // black 10%
}

class _Dark {
  // Brand — same hue, slightly brighter for contrast on dark bg
  static const primary = Color(0xFF66BB9A);
  static const primaryDark = Color(0xFF4CAF82);
  static const onPrimary = Color(0xFF003822); // dark text on green btn
  static const primaryContainer = Color(0xFF00522F);
  static const onPrimaryContainer = Color(0xFFB7EDD4);

  // Accent / error
  static const secondary = Color(0xFFFF8A80);
  static const onSecondary = Color(0xFF690001);
  static const secondaryContainer = Color(0xFF93000A);
  static const onSecondaryContainer = Color(0xFFFFDAD6);

  // Info / tertiary
  static const tertiary = Color(0xFF90CAF9);
  static const onTertiary = Color(0xFF003258);
  static const tertiaryContainer = Color(0xFF004880);
  static const onTertiaryContainer = Color(0xFFD3E4FF);

  // Surfaces — true dark, not black
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceVariant = Color(0xFF2C2C2C);
  static const onSurface = Color(0xFFE4E4E4);
  static const onSurfaceVariant = Color(0xFFBFC9C2);
  static const outline = Color(0xFF3D3D3D);
  static const outlineVariant = Color(0xFF2A2A2A);

  // Semantic
  static const error = Color(0xFFFF6B6B);
  static const onError = Color(0xFF690001);

  // Text
  static const textPrimary = Color(0xFFE4E4E4);
  static const textSecondary = Color(0xFFADB5BD);
  static const textHint = Color(0xFF6C757D);

  // Misc
  static const divider = Color(0xFF2E2E2E);
  static const shadow = Color(0x33000000); // black 20%
}

// ── AppTheme ──────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Public entry points ───────────────────────────────────────────────────
  // No BuildContext parameter — static methods cannot use Theme.of(context).

  static ThemeData getLightTheme() => _buildTheme(
    brightness: Brightness.light,
    cs: _lightColorScheme(),
    bg: _Light.background,
    surface: _Light.surface,
    surfaceVariant: _Light.surfaceVariant,
    appBarBg: _Light.surface,
    appBarFg: _Light.textPrimary,
    cardColor: _Light.surface,
    cardBorder: _Light.outline,
    inputFill: _Light.surfaceVariant,
    inputBorder: _Light.outline,
    divider: _Light.divider,
    snackBg: const Color(0xFF1A1A2E),
    snackFg: Colors.white,
    dialogBg: _Light.surface,
    bottomSheetBg: _Light.surface,
    dragHandle: _Light.divider,
    shadow: _Light.shadow,
  );

  static ThemeData getDarkTheme() => _buildTheme(
    brightness: Brightness.dark,
    cs: _darkColorScheme(),
    bg: _Dark.background,
    surface: _Dark.surface,
    surfaceVariant: _Dark.surfaceVariant,
    appBarBg: _Dark.surface,
    appBarFg: _Dark.textPrimary,
    cardColor: _Dark.surfaceVariant,
    cardBorder: _Dark.outline,
    inputFill: _Dark.surfaceVariant,
    inputBorder: _Dark.outline,
    divider: _Dark.divider,
    snackBg: _Dark.surfaceVariant,
    snackFg: _Dark.textPrimary,
    dialogBg: _Dark.surface,
    bottomSheetBg: _Dark.surface,
    dragHandle: _Dark.outline,
    shadow: _Dark.shadow,
  );

  // ── Shared theme builder ──────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme cs,
    required Color bg,
    required Color surface,
    required Color surfaceVariant,
    required Color appBarBg,
    required Color appBarFg,
    required Color cardColor,
    required Color cardBorder,
    required Color inputFill,
    required Color inputBorder,
    required Color divider,
    required Color snackBg,
    required Color snackFg,
    required Color dialogBg,
    required Color bottomSheetBg,
    required Color dragHandle,
    required Color shadow,
  }) {
    final textTheme = _buildTextTheme(brightness);
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? _Dark.primary : _Light.primary;
    final onPrimary = isDark ? _Dark.onPrimary : _Light.onPrimary;
    final error = isDark ? _Dark.error : _Light.error;
    final textPrimary = isDark ? _Dark.textPrimary : _Light.textPrimary;
    final textSecondary = isDark ? _Dark.textSecondary : _Light.textSecondary;
    final textHint = isDark ? _Dark.textHint : _Light.textHint;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: AppElevation.none,
        centerTitle: true,
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: appBarFg,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: appBarFg, size: AppIconSize.md),
        actionsIconTheme: IconThemeData(color: appBarFg, size: AppIconSize.md),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevation.none,
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: textHint.withValues(alpha: 0.38),
          disabledForegroundColor: textHint,
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

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          foregroundColor: primary,
          disabledForegroundColor: textHint.withValues(alpha: 0.38),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTouchTarget.min, AppTouchTarget.min),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          foregroundColor: primary,
          disabledForegroundColor: textHint.withValues(alpha: 0.38),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── Filled Button ─────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
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

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppElevation.sm,
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.fab)),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: textHint.withValues(alpha: 0.3)),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: textHint),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(color: primary),
        errorStyle: AppTextStyles.captionSmall.copyWith(color: error),
        errorMaxLines: 2,
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        deleteIconColor: textPrimary,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        selectedColor: primary.withValues(alpha: 0.2),
        checkmarkColor: primary,
        disabledColor: surfaceVariant,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
        indent: AppSpacing.lg,
        endIndent: AppSpacing.lg,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBg,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: snackFg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.lg,
        actionTextColor: primary,
      ),

      // ── Bottom Nav Bar ────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.lg,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBg,
        elevation: AppElevation.lg,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: textSecondary,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bottomSheetBg,
        modalBackgroundColor: bottomSheetBg,
        elevation: AppElevation.lg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        dragHandleColor: dragHandle,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),

      // ── Navigation Drawer ─────────────────────────────────────────────────
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: surface,
        elevation: AppElevation.lg,
        indicatorColor: primary.withValues(alpha: isDark ? 0.3 : 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelLarge.copyWith(color: primary);
          }
          return AppTextStyles.labelLarge.copyWith(color: textPrimary);
        }),
      ),

      // ── Navigation Rail ───────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        elevation: AppElevation.none,
        indicatorColor: primary.withValues(alpha: 0.15),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.2),
        circularTrackColor: primary.withValues(alpha: 0.2),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : (isDark ? _Dark.textSecondary : _Light.textSecondary),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.5)
              : (isDark ? _Dark.outline : _Light.outline),
        ),
      ),

      // ── Radio ─────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : textSecondary,
        ),
      ),

      // ── Checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(onPrimary),
        side: BorderSide(color: textSecondary),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.2),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.15),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: textSecondary,
        ),
        dense: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: textPrimary, size: AppIconSize.md),

      // ── Back button ───────────────────────────────────────────────────────
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) => Icon(
          Icons.arrow_back_ios_new_rounded,
          color: appBarFg,
          size: AppIconSize.md,
        ),
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? _Dark.surfaceVariant : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTextStyles.captionSmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Badge ─────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: isDark ? _Dark.secondary : _Light.secondary,
        textColor: Colors.white,
      ),

      // ── Search Bar ────────────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(surfaceVariant),
        elevation: WidgetStateProperty.all(AppElevation.none),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }

  // ── Color schemes ─────────────────────────────────────────────────────────

  static ColorScheme _lightColorScheme() => ColorScheme(
    brightness: Brightness.light,
    primary: _Light.primary,
    onPrimary: _Light.onPrimary,
    primaryContainer: _Light.primaryContainer,
    onPrimaryContainer: _Light.onPrimaryContainer,
    // primaryFixed = the darker pressed/hover shade of primary.
    // Used by buttons for ripple targets and gradient stops.
    primaryFixed: _Light.primaryDark,
    primaryFixedDim: _Light.primaryDark,
    secondary: _Light.secondary,
    onSecondary: _Light.onSecondary,
    secondaryContainer: _Light.secondaryContainer,
    onSecondaryContainer: _Light.onSecondaryContainer,
    tertiary: _Light.tertiary,
    onTertiary: _Light.onTertiary,
    tertiaryContainer: _Light.tertiaryContainer,
    onTertiaryContainer: _Light.onTertiaryContainer,
    error: _Light.error,
    onError: _Light.onError,
    surface: _Light.surface,
    onSurface: _Light.onSurface,
    surfaceContainerHighest: _Light.surfaceVariant,
    onSurfaceVariant: _Light.onSurfaceVariant,
    outline: _Light.outline,
    outlineVariant: _Light.outlineVariant,
    shadow: _Light.shadow,
    scrim: Colors.black54,
    inverseSurface: _Light.onSurface,
    onInverseSurface: _Light.surface,
    // inversePrimary = the light tint shown on dark surfaces (e.g. dark
    // AppBar action highlight). Reuses primaryLight token.
    inversePrimary: _Light.primaryLight,
  );

  static ColorScheme _darkColorScheme() => ColorScheme(
    brightness: Brightness.dark,
    primary: _Dark.primary,
    onPrimary: _Dark.onPrimary,
    primaryContainer: _Dark.primaryContainer,
    onPrimaryContainer: _Dark.onPrimaryContainer,
    // primaryFixed = the base (less-bright) green used for pressed states
    // and gradient bottom stops on dark surfaces.
    primaryFixed: _Dark.primaryDark,
    primaryFixedDim: _Dark.primaryDark,
    secondary: _Dark.secondary,
    onSecondary: _Dark.onSecondary,
    secondaryContainer: _Dark.secondaryContainer,
    onSecondaryContainer: _Dark.onSecondaryContainer,
    tertiary: _Dark.tertiary,
    onTertiary: _Dark.onTertiary,
    tertiaryContainer: _Dark.tertiaryContainer,
    onTertiaryContainer: _Dark.onTertiaryContainer,
    error: _Dark.error,
    onError: _Dark.onError,
    surface: _Dark.surface,
    onSurface: _Dark.onSurface,
    surfaceContainerHighest: _Dark.surfaceVariant,
    onSurfaceVariant: _Dark.onSurfaceVariant,
    outline: _Dark.outline,
    outlineVariant: _Dark.outlineVariant,
    shadow: _Dark.shadow,
    scrim: Colors.black87,
    inverseSurface: _Dark.onSurface,
    onInverseSurface: _Dark.surface,
    inversePrimary: _Light.primary,
  );

  // ── Text theme ────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark
        ? _Dark.textPrimary
        : _Light.textPrimary;

    return GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
      ),
    );
  }
}

// ── Convenience top-level functions (match existing call sites) ────────────────

ThemeData getLightTheme() => AppTheme.getLightTheme();
ThemeData getDarkTheme() => AppTheme.getDarkTheme();
