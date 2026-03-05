import 'package:flutter/material.dart';

/// WiseSpends Color System
/// Material 3 design tokens for consistent color usage
/// 
/// Usage: Always import and use these colors instead of hardcoded hex values
/// Example: `color: AppColors.primary` instead of `color: Color(0xFF4CAF82)`
class AppColors {
  AppColors._();

  // ==========================================================================
  // PRIMARY COLORS - Green (Money, Growth, Success)
  // ==========================================================================
  
  /// Main primary color - Used for: primary actions, income, positive indicators
  static const Color primary = Color(0xFF4CAF82);
  
  /// Lighter variant - Used for: backgrounds, hover states
  static const Color primaryLight = Color(0xFF80E0AA);
  
  /// Darker variant - Used for: pressed states, depth
  static const Color primaryDark = Color(0xFF2E7D57);
  
  /// Container color - Used for: filled backgrounds with primary tint
  static const Color primaryContainer = Color(0xFFC8E6C9);
  
  /// Color for text/icons on primary background
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  /// Color for text/icons on primary container background
  static const Color onPrimaryContainer = Color(0xFF1B5E20);

  // ==========================================================================
  // SECONDARY COLORS - Red/Coral (Expenses, Destructive Actions)
  // ==========================================================================
  
  /// Main secondary color - Used for: expenses, destructive actions, alerts
  static const Color secondary = Color(0xFFFF6B6B);
  
  /// Lighter variant
  static const Color secondaryLight = Color(0xFFFF8A80);
  
  /// Darker variant
  static const Color secondaryDark = Color(0xFFD32F2F);
  
  /// Container color
  static const Color secondaryContainer = Color(0xFFFFCDD2);
  
  /// Color for text/icons on secondary background
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  /// Color for text/icons on secondary container background
  static const Color onSecondaryContainer = Color(0xFFB71C1C);

  // ==========================================================================
  // TERTIARY COLORS - Blue (Transfers, Neutral Info)
  // ==========================================================================
  
  /// Main tertiary color - Used for: transfers, neutral information
  static const Color tertiary = Color(0xFF42A5F5);
  
  /// Lighter variant
  static const Color tertiaryLight = Color(0xFF90CAF9);
  
  /// Darker variant
  static const Color tertiaryDark = Color(0xFF1976D2);
  
  /// Container color
  static const Color tertiaryContainer = Color(0xFFBBDEFB);
  
  /// Color for text/icons on tertiary background
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ==========================================================================
  // SEMANTIC COLORS - Transaction Types
  // ==========================================================================
  
  /// Income transactions - Green
  static const Color income = Color(0xFF4CAF82);
  
  /// Expense transactions - Red/Coral
  static const Color expense = Color(0xFFFF6B6B);
  
  /// Transfer transactions - Blue
  static const Color transfer = Color(0xFF42A5F5);

  // ==========================================================================
  // STATUS COLORS - Budget/Goal Health
  // ==========================================================================
  
  /// On Track - Green
  static const Color onTrack = Color(0xFF4CAF82);
  
  /// Slightly Behind - Amber/Yellow
  static const Color slightlyBehind = Color(0xFFFFC107);
  
  /// At Risk - Red/Coral
  static const Color atRisk = Color(0xFFFF6B6B);
  
  /// Completed - Grey
  static const Color completed = Color(0xFF9E9E9E);
  
  /// Warning state - Amber
  static const Color warning = Color(0xFFFFC107);
  
  /// Success state - Green
  static const Color success = Color(0xFF4CAF50);
  
  /// Info state - Blue
  static const Color info = Color(0xFF42A5F5);
  
  /// Error state - Red
  static const Color error = Color(0xFFB00020);

  // ==========================================================================
  // NEUTRAL COLORS - Surfaces & Backgrounds
  // ==========================================================================
  
  /// Surface color - Used for: cards, sheets, elevated surfaces
  static const Color surface = Color(0xFFF8F9FA);
  
  /// Background color - Used for: screen backgrounds
  static const Color background = Color(0xFFFFFFFF);
  
  /// Inverse surface (for dark mode)
  static const Color inverseSurface = Color(0xFF1A1A2E);
  
  /// Surface variant
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // ==========================================================================
  // TEXT COLORS
  // ==========================================================================
  
  /// Primary text - High emphasis
  static const Color textPrimary = Color(0xFF1A1A2E);
  
  /// Secondary text - Medium emphasis
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Hint text - Low emphasis (placeholders, hints)
  static const Color textHint = Color(0xFFADB5BD);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Text on inverse surface
  static const Color onInverseSurface = Color(0xFFFFFFFF);

  // ==========================================================================
  // BORDER & DIVIDER COLORS
  // ==========================================================================
  
  /// Divider color - Used for: list separators, section dividers
  static const Color divider = Color(0xFFE0E0E0);
  
  /// Border color - Used for: input borders, card outlines
  static const Color border = Color(0xFFE8E8E8);
  
  /// Stronger border for emphasis
  static const Color borderStrong = Color(0xFFBDBDBD);

  // ==========================================================================
  // BUDGET PROGRESS COLORS
  // ==========================================================================
  
  /// Budget on track (<60% spent)
  static const Color budgetGood = Color(0xFF4CAF50);
  
  /// Budget warning (60-85% spent)
  static const Color budgetWarning = Color(0xFFFFA726);
  
  /// Budget danger (>85% spent)
  static const Color budgetDanger = Color(0xFFFF6B6B);

  // ==========================================================================
  // DARK THEME COLORS
  // ==========================================================================
  
  /// Dark surface
  static const Color darkSurface = Color(0xFF1E1E1E);
  
  /// Dark background
  static const Color darkBackground = Color(0xFF121212);
  
  /// Dark card
  static const Color darkCard = Color(0xFF2C2C2C);
  
  /// Dark divider
  static const Color darkDivider = Color(0xFF3D3D3D);
  
  /// Dark border
  static const Color darkBorder = Color(0xFF424242);

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

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

  /// Get color for budget health status
  static Color getBudgetHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'on_track':
      case 'on track':
        return onTrack;
      case 'slightly_behind':
      case 'slightly behind':
        return slightlyBehind;
      case 'at_risk':
      case 'at risk':
      case 'over_budget':
      case 'overbudget':
        return atRisk;
      case 'completed':
        return completed;
      default:
        return textHint;
    }
  }

  /// Get color for transaction type
  static Color getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      case 'transfer':
        return transfer;
      default:
        return textSecondary;
    }
  }

  /// Get background color for transaction type
  static Color getTransactionTypeBackgroundColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return income.withValues(alpha: 0.1);
      case 'expense':
        return expense.withValues(alpha: 0.1);
      case 'transfer':
        return transfer.withValues(alpha: 0.1);
      default:
        return surface;
    }
  }

  /// Get icon color for transaction type
  static Color getTransactionTypeIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      case 'transfer':
        return transfer;
      default:
        return textSecondary;
    }
  }

  /// Get gradient colors for balance card
  static List<Color> getBalanceCardGradient() {
    return [primary, primaryDark];
  }

  /// Get gradient colors for income card
  static List<Color> getIncomeCardGradient() {
    return [income, const Color(0xFF2E7D57)];
  }

  /// Get gradient colors for expense card
  static List<Color> getExpenseCardGradient() {
    return [expense, const Color(0xFFC62828)];
  }
}
