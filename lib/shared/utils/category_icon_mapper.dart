import 'package:flutter/material.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';

/// Icon mapping utility for categories
/// Maps category IDs to Material Icons
class CategoryIconMapper {
  /// Get icon for a category ID
  static IconData getIconForCategory(String categoryId) {
    switch (categoryId.toLowerCase()) {
      // Food & Dining
      case PredefinedCategories.food:
        return Icons.restaurant_rounded;
      case 'dining':
        return Icons.local_dining_rounded;
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;

      // Transportation
      case PredefinedCategories.transport:
        return Icons.directions_car_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'taxi':
        return Icons.local_taxi_rounded;
      case 'public_transport':
        return Icons.directions_bus_rounded;

      // Shopping
      case PredefinedCategories.shopping:
        return Icons.shopping_bag_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'home':
        return Icons.home_rounded;

      // Entertainment
      case PredefinedCategories.entertainment:
        return Icons.movie_rounded;
      case 'movies':
        return Icons.local_movies_rounded;
      case 'games':
        return Icons.sports_esports_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'sports':
        return Icons.sports_rounded;
      case 'hobbies':
        return Icons.art_track_rounded;

      // Bills & Utilities
      case PredefinedCategories.bills:
        return Icons.receipt_long_rounded;
      case 'electricity':
        return Icons.bolt_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'internet':
        return Icons.wifi_rounded;
      case 'phone':
        return Icons.phone_rounded;
      case 'rent':
        return Icons.account_balance_rounded;

      // Health
      case PredefinedCategories.health:
        return Icons.medical_services_rounded;
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'pharmacy':
        return Icons.medication_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;

      // Education
      case PredefinedCategories.education:
        return Icons.school_rounded;
      case 'books':
        return Icons.book_rounded;
      case 'courses':
        return Icons.menu_book_rounded;

      // Income categories
      case PredefinedCategories.salary:
        return Icons.attach_money_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case PredefinedCategories.investment:
        return Icons.trending_up_rounded;
      case 'dividends':
        return Icons.account_balance_wallet_rounded;
      case PredefinedCategories.gift:
        return Icons.card_giftcard_rounded;
      case 'refund':
        return Icons.undo_rounded;

      // Other
      case PredefinedCategories.other:
        return Icons.more_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get all predefined categories with icons
  static List<Map<String, dynamic>> getPredefinedCategories() {
    return [
      // Expense Categories
      {
        'id': PredefinedCategories.food,
        'name': 'Food',
        'icon': Icons.restaurant_rounded,
        'isExpense': true,
      },
      {
        'id': 'groceries',
        'name': 'Groceries',
        'icon': Icons.shopping_basket_rounded,
        'isExpense': true,
      },
      {
        'id': 'dining',
        'name': 'Dining',
        'icon': Icons.local_dining_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.transport,
        'name': 'Transport',
        'icon': Icons.directions_car_rounded,
        'isExpense': true,
      },
      {
        'id': 'fuel',
        'name': 'Fuel',
        'icon': Icons.local_gas_station_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.shopping,
        'name': 'Shopping',
        'icon': Icons.shopping_bag_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.entertainment,
        'name': 'Entertainment',
        'icon': Icons.movie_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.bills,
        'name': 'Bills',
        'icon': Icons.receipt_long_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.health,
        'name': 'Health',
        'icon': Icons.medical_services_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.education,
        'name': 'Education',
        'icon': Icons.school_rounded,
        'isExpense': true,
      },
      {
        'id': PredefinedCategories.other,
        'name': 'Other',
        'icon': Icons.more_horiz_rounded,
        'isExpense': true,
      },

      // Income Categories
      {
        'id': PredefinedCategories.salary,
        'name': 'Salary',
        'icon': Icons.attach_money_rounded,
        'isIncome': true,
      },
      {
        'id': 'freelance',
        'name': 'Freelance',
        'icon': Icons.work_rounded,
        'isIncome': true,
      },
      {
        'id': PredefinedCategories.investment,
        'name': 'Investment',
        'icon': Icons.trending_up_rounded,
        'isIncome': true,
      },
      {
        'id': PredefinedCategories.gift,
        'name': 'Gift',
        'icon': Icons.card_giftcard_rounded,
        'isIncome': true,
      },
      {
        'id': PredefinedCategories.other,
        'name': 'Other Income',
        'icon': Icons.add_circle_rounded,
        'isIncome': true,
      },
    ];
  }
}
