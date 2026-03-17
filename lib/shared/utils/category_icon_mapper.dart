import 'package:flutter/material.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';

/// Icon mapping utility for categories
/// Maps category IDs to Material Icons
class CategoryIconMapper {
  /// Get icon for a category ID or icon code point
  static IconData getIconForCategory(String codePoint) {
    // First, try to parse as icon code point (stored as string number)
    try {
      final intCodePoint = int.parse(codePoint);
      return IconData(intCodePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      // Not a code point, treat as category ID
    }

    // Match against predefined category IDs
    switch (codePoint.toLowerCase()) {
      // Food & Dining
      case PredefinedCategories.food:
        return Icons.restaurant_rounded;
      case 'dining':
        return Icons.local_dining_rounded;
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'liquor':
        return Icons.liquor_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      case 'cake':
        return Icons.cake_rounded;

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
      case 'motorcycle':
        return Icons.motorcycle_rounded;
      case 'bicycle':
        return Icons.pedal_bike_rounded;
      case 'ev_charger':
        return Icons.ev_station_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'subway':
        return Icons.subway_rounded;
      case 'airport':
        return Icons.airport_shuttle_rounded;

      // Shopping
      case PredefinedCategories.shopping:
        return Icons.shopping_bag_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'mall':
        return Icons.store_mall_directory_rounded;
      case 'local_mall':
        return Icons.local_mall_rounded;
      case 'card_giftcard':
        return Icons.card_giftcard_rounded;

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
      case 'theater':
        return Icons.theater_comedy_rounded;
      case 'festival':
        return Icons.festival_rounded;
      case 'nightlife':
        return Icons.nightlife_rounded;
      case 'park':
        return Icons.park_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'book':
        return Icons.book_rounded;

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
      case 'insurance':
        return Icons.security_rounded;
      case 'tax':
        return Icons.gavel_rounded;
      case 'loan':
        return Icons.monetization_on_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'savings':
        return Icons.savings_rounded;

      // Health
      case PredefinedCategories.health:
        return Icons.medical_services_rounded;
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'pharmacy':
        return Icons.medication_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'dentist':
        return Icons.density_medium_rounded;
      case 'eye':
        return Icons.visibility_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'self_care':
        return Icons.self_improvement_rounded;
      case 'blood':
        return Icons.bloodtype_rounded;
      case 'mental_health':
        return Icons.psychology_rounded;

      // Education
      case PredefinedCategories.education:
        return Icons.school_rounded;
      case 'books':
        return Icons.book_rounded;
      case 'courses':
        return Icons.menu_book_rounded;
      case 'library':
        return Icons.library_books_rounded;
      case 'graduation':
        return Icons.school_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'language':
        return Icons.translate_rounded;

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
      case 'bonus':
        return Icons.auto_graph_rounded;
      case 'commission':
        return Icons.percent_rounded;
      case 'rental_income':
        return Icons.key_rounded;
      case 'pension':
        return Icons.account_balance_rounded;
      case 'allowance':
        return Icons.monetization_on_rounded;

      // Home & Garden
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'garden':
        return Icons.yard_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'childcare':
        return Icons.child_care_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'appliances':
        return Icons.house_rounded;
      case 'tools':
        return Icons.build_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;

      // Technology
      case 'software':
        return Icons.code_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'streaming':
        return Icons.cast_rounded;
      case 'gaming':
        return Icons.games_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'smartphone':
        return Icons.phone_android_rounded;
      case 'tablet':
        return Icons.tablet_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'headphones':
        return Icons.headphones_rounded;

      // Travel
      case 'travel':
        return Icons.flight_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'luggage':
        return Icons.luggage_rounded;
      case 'cruise':
        return Icons.sailing_rounded;
      case 'tour':
        return Icons.attractions_rounded;

      // Personal Care
      case 'salon':
        return Icons.content_cut_rounded;
      case 'cosmetics':
        return Icons.face_rounded;
      case 'haircut':
        return Icons.content_cut_rounded;
      case 'massage':
        return Icons.spa_rounded;

      // Charity & Donations
      case 'charity':
        return Icons.favorite_rounded;
      case 'donation':
        return Icons.volunteer_activism_rounded;
      case 'religious':
        return Icons.church_rounded;

      // Other
      case PredefinedCategories.other:
        return Icons.more_horiz_rounded;
      case 'misc':
        return Icons.category_rounded;
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

  /// Get all available icons for the icon picker, organized by category
  static List<Map<String, dynamic>> getAllAvailableIcons() {
    return [
      // Food & Dining Icons
      ..._buildIconList('food', [
        {'icon': Icons.restaurant, 'label': 'Restaurant'},
        {'icon': Icons.local_dining, 'label': 'Dining'},
        {'icon': Icons.shopping_basket, 'label': 'Groceries'},
        {'icon': Icons.local_cafe, 'label': 'Cafe'},
        {'icon': Icons.bakery_dining, 'label': 'Bakery'},
        {'icon': Icons.fastfood, 'label': 'Fast Food'},
        {'icon': Icons.kitchen, 'label': 'Kitchen'},
        {'icon': Icons.liquor, 'label': 'Liquor'},
        {'icon': Icons.icecream, 'label': 'Ice Cream'},
        {'icon': Icons.cake, 'label': 'Cake'},
      ]),

      // Transport Icons
      ..._buildIconList('transport', [
        {'icon': Icons.directions_car, 'label': 'Car'},
        {'icon': Icons.local_gas_station, 'label': 'Fuel'},
        {'icon': Icons.local_parking, 'label': 'Parking'},
        {'icon': Icons.local_taxi, 'label': 'Taxi'},
        {'icon': Icons.directions_bus, 'label': 'Bus'},
        {'icon': Icons.motorcycle, 'label': 'Motorcycle'},
        {'icon': Icons.pedal_bike, 'label': 'Bicycle'},
        {'icon': Icons.ev_station, 'label': 'EV Charger'},
        {'icon': Icons.train, 'label': 'Train'},
        {'icon': Icons.subway, 'label': 'Subway'},
        {'icon': Icons.airport_shuttle, 'label': 'Airport'},
      ]),

      // Shopping Icons
      ..._buildIconList('shopping', [
        {'icon': Icons.shopping_bag, 'label': 'Shopping'},
        {'icon': Icons.checkroom, 'label': 'Clothing'},
        {'icon': Icons.devices, 'label': 'Electronics'},
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.store_mall_directory, 'label': 'Mall'},
        {'icon': Icons.local_mall, 'label': 'Mall Bag'},
        {'icon': Icons.card_giftcard, 'label': 'Gift'},
      ]),

      // Entertainment Icons
      ..._buildIconList('entertainment', [
        {'icon': Icons.movie, 'label': 'Movie'},
        {'icon': Icons.local_movies, 'label': 'Cinema'},
        {'icon': Icons.sports_esports, 'label': 'Games'},
        {'icon': Icons.music_note, 'label': 'Music'},
        {'icon': Icons.sports, 'label': 'Sports'},
        {'icon': Icons.art_track, 'label': 'Hobbies'},
        {'icon': Icons.theater_comedy, 'label': 'Theater'},
        {'icon': Icons.festival, 'label': 'Festival'},
        {'icon': Icons.nightlife, 'label': 'Nightlife'},
        {'icon': Icons.park, 'label': 'Park'},
        {'icon': Icons.beach_access, 'label': 'Beach'},
        {'icon': Icons.camera_alt, 'label': 'Camera'},
        {'icon': Icons.book, 'label': 'Book'},
      ]),

      // Bills & Utilities Icons
      ..._buildIconList('bills', [
        {'icon': Icons.receipt_long, 'label': 'Receipt'},
        {'icon': Icons.bolt, 'label': 'Electricity'},
        {'icon': Icons.water_drop, 'label': 'Water'},
        {'icon': Icons.wifi, 'label': 'Internet'},
        {'icon': Icons.phone, 'label': 'Phone'},
        {'icon': Icons.account_balance, 'label': 'Bank'},
        {'icon': Icons.security, 'label': 'Insurance'},
        {'icon': Icons.gavel, 'label': 'Tax'},
        {'icon': Icons.monetization_on, 'label': 'Loan'},
        {'icon': Icons.credit_card, 'label': 'Credit Card'},
        {'icon': Icons.savings, 'label': 'Savings'},
      ]),

      // Health Icons
      ..._buildIconList('health', [
        {'icon': Icons.medical_services, 'label': 'Medical'},
        {'icon': Icons.local_hospital, 'label': 'Hospital'},
        {'icon': Icons.medication, 'label': 'Pharmacy'},
        {'icon': Icons.fitness_center, 'label': 'Fitness'},
        {'icon': Icons.spa, 'label': 'Spa'},
        {'icon': Icons.self_improvement, 'label': 'Self Care'},
        {'icon': Icons.bloodtype, 'label': 'Blood'},
        {'icon': Icons.psychology, 'label': 'Mental Health'},
      ]),

      // Education Icons
      ..._buildIconList('education', [
        {'icon': Icons.school, 'label': 'School'},
        {'icon': Icons.book, 'label': 'Books'},
        {'icon': Icons.menu_book, 'label': 'Courses'},
        {'icon': Icons.library_books, 'label': 'Library'},
        {'icon': Icons.science, 'label': 'Science'},
        {'icon': Icons.history_edu, 'label': 'History'},
        {'icon': Icons.translate, 'label': 'Language'},
      ]),

      // Income Icons
      ..._buildIconList('income', [
        {'icon': Icons.attach_money, 'label': 'Money'},
        {'icon': Icons.work, 'label': 'Work'},
        {'icon': Icons.trending_up, 'label': 'Investment'},
        {'icon': Icons.account_balance_wallet, 'label': 'Wallet'},
        {'icon': Icons.card_giftcard, 'label': 'Gift'},
        {'icon': Icons.undo, 'label': 'Refund'},
        {'icon': Icons.auto_graph, 'label': 'Bonus'},
        {'icon': Icons.percent, 'label': 'Commission'},
        {'icon': Icons.key, 'label': 'Rental'},
      ]),

      // Home Icons
      ..._buildIconList('home', [
        {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
        {'icon': Icons.yard, 'label': 'Garden'},
        {'icon': Icons.pets, 'label': 'Pets'},
        {'icon': Icons.child_care, 'label': 'Childcare'},
        {'icon': Icons.chair, 'label': 'Furniture'},
        {'icon': Icons.house, 'label': 'House'},
        {'icon': Icons.build, 'label': 'Tools'},
        {'icon': Icons.plumbing, 'label': 'Plumbing'},
        {'icon': Icons.electrical_services, 'label': 'Electrical'},
      ]),

      // Technology Icons
      ..._buildIconList('technology', [
        {'icon': Icons.code, 'label': 'Software'},
        {'icon': Icons.cloud, 'label': 'Cloud'},
        {'icon': Icons.cast, 'label': 'Streaming'},
        {'icon': Icons.games, 'label': 'Gaming'},
        {'icon': Icons.computer, 'label': 'Computer'},
        {'icon': Icons.phone_android, 'label': 'Phone'},
        {'icon': Icons.tablet, 'label': 'Tablet'},
        {'icon': Icons.watch, 'label': 'Watch'},
        {'icon': Icons.headphones, 'label': 'Headphones'},
      ]),

      // Travel Icons
      ..._buildIconList('travel', [
        {'icon': Icons.flight, 'label': 'Flight'},
        {'icon': Icons.hotel, 'label': 'Hotel'},
        {'icon': Icons.luggage, 'label': 'Luggage'},
        {'icon': Icons.sailing, 'label': 'Cruise'},
        {'icon': Icons.attractions, 'label': 'Tour'},
      ]),

      // Personal Care Icons
      ..._buildIconList('other', [
        {'icon': Icons.content_cut, 'label': 'Salon'},
        {'icon': Icons.face, 'label': 'Cosmetics'},
        {'icon': Icons.spa, 'label': 'Massage'},
        {'icon': Icons.favorite, 'label': 'Charity'},
        {'icon': Icons.volunteer_activism, 'label': 'Donation'},
        {'icon': Icons.more_horiz, 'label': 'Other'},
        {'icon': Icons.category, 'label': 'Misc'},
      ]),
    ];
  }

  /// Helper to build icon list with category
  static List<Map<String, dynamic>> _buildIconList(
    String category,
    List<Map<String, dynamic>> icons,
  ) {
    return icons.map((icon) {
      return {
        'codePoint': icon['icon'].codePoint,
        'label': icon['label'],
        'category': category,
      };
    }).toList();
  }
}
