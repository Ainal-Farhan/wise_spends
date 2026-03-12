import 'package:equatable/equatable.dart';

/// Category entity for transactions
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconCodePoint;
  final String iconFontFamily;
  final bool isIncome;
  final bool isExpense;
  final int orderIndex;
  final bool isActive;
  final DateTime? createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.isIncome = false,
    this.isExpense = false,
    this.orderIndex = 0,
    this.isActive = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        iconCodePoint,
        iconFontFamily,
        isIncome,
        isExpense,
        orderIndex,
        isActive,
        createdAt,
      ];

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? iconCodePoint,
    String? iconFontFamily,
    bool? isIncome,
    bool? isExpense,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      isIncome: isIncome ?? this.isIncome,
      isExpense: isExpense ?? this.isExpense,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Predefined categories for quick access
class PredefinedCategories {
  static const String food = 'food';
  static const String transport = 'transport';
  static const String shopping = 'shopping';
  static const String entertainment = 'entertainment';
  static const String bills = 'bills';
  static const String health = 'health';
  static const String education = 'education';
  static const String salary = 'salary';
  static const String investment = 'investment';
  static const String gift = 'gift';
  static const String other = 'other';
}
