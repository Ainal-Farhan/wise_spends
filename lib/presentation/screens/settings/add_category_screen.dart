import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/category_enum.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Add Category Screen
/// Allows users to create new transaction categories
class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoryBloc(context.read<ICategoryRepository>())
            ..add(LoadCategoriesEvent()),
      child: const _AddCategoryScreenContent(),
    );
  }
}

class _AddCategoryScreenContent extends StatefulWidget {
  const _AddCategoryScreenContent();

  @override
  State<_AddCategoryScreenContent> createState() =>
      _AddCategoryScreenContentState();
}

class _AddCategoryScreenContentState extends State<_AddCategoryScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CategoryType _categoryType = CategoryType.expense;
  IconData _selectedIcon = Icons.category;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              AppTextField(
                label: 'Category Name',
                controller: _nameController,
                hint: 'e.g., Food, Transport, Shopping',
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: 24),

              // Category Type
              Text('Category Type', style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: RadioGroup<CategoryType>(
                  groupValue: _categoryType,
                  onChanged: (value) {
                    setState(
                      () => _categoryType = value ?? CategoryType.expense,
                    );
                  },
                  child: Column(
                    children: [
                      RadioListTile<CategoryType>(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: AppColors.income,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Income'),
                          ],
                        ),
                        subtitle: const Text('For money received'),
                        value: CategoryType.income,
                      ),
                      const Divider(height: 1),
                      RadioListTile<CategoryType>(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: AppColors.expense,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Expense'),
                          ],
                        ),
                        subtitle: const Text('For money spent'),
                        value: CategoryType.expense,
                      ),
                      const Divider(height: 1),
                      RadioListTile<CategoryType>(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: AppColors.tertiary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Both'),
                          ],
                        ),
                        subtitle: const Text('For both income and expense'),
                        value: CategoryType.both,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Icon Selection
              Text('Select Icon', style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildIconOption(Icons.restaurant, 'Food'),
                  _buildIconOption(Icons.directions_car, 'Transport'),
                  _buildIconOption(Icons.shopping_bag, 'Shopping'),
                  _buildIconOption(Icons.home, 'Housing'),
                  _buildIconOption(Icons.medical_services, 'Healthcare'),
                  _buildIconOption(Icons.school, 'Education'),
                  _buildIconOption(Icons.flight, 'Travel'),
                  _buildIconOption(Icons.sports_gymnastics, 'Sports'),
                  _buildIconOption(Icons.movie, 'Entertainment'),
                  _buildIconOption(Icons.credit_card, 'Finance'),
                  _buildIconOption(Icons.phone_android, 'Electronics'),
                  _buildIconOption(Icons.pets, 'Pets'),
                  _buildIconOption(Icons.child_care, 'Childcare'),
                  _buildIconOption(Icons.cleaning_services, 'Services'),
                  _buildIconOption(Icons.local_gas_station, 'Fuel'),
                  _buildIconOption(Icons.checkroom, 'Clothing'),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              BlocListener<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  if (state is CategoryCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category added successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is CategoryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: 'Add Category',
                    icon: Icons.add,
                    onPressed: _submitForm,
                    size: AppButtonSize.large,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(IconData icon, String label) {
    final isSelected = _selectedIcon == icon;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a category name'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Get icon code point as string
      final iconCodePoint = _selectedIcon.codePoint.toString();

      // Determine isIncome and isExpense based on CategoryType
      final isIncome = _categoryType == CategoryType.income ||
          _categoryType == CategoryType.both;
      final isExpense = _categoryType == CategoryType.expense ||
          _categoryType == CategoryType.both;

      context.read<CategoryBloc>().add(
        CreateCategoryEvent(
          name: _nameController.text,
          isIncome: isIncome,
          isExpense: isExpense,
          iconCodePoint: iconCodePoint,
          iconFontFamily: 'MaterialIcons',
        ),
      );
    }
  }
}
