import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/category_enum.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/presentation/blocs/add_category_form/add_category_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/add_category_form/add_category_form_event.dart';
import 'package:wise_spends/presentation/blocs/add_category_form/add_category_form_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CategoryBloc(context.read<ICategoryRepository>()),
        ),
        BlocProvider(create: (_) => AddCategoryFormBloc()),
      ],
      child: const _AddCategoryScreenContent(),
    );
  }
}

// StatefulWidget kept only for _formKey and _nameController.
// All selection state (type, icon) lives in AddCategoryFormBloc.
class _AddCategoryScreenContent extends StatefulWidget {
  const _AddCategoryScreenContent();

  @override
  State<_AddCategoryScreenContent> createState() =>
      _AddCategoryScreenContentState();
}

class _AddCategoryScreenContentState extends State<_AddCategoryScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
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
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Category')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Category Name',
                  controller: _nameController,
                  hint: 'e.g., Food, Transport, Shopping',
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Category Type — driven by AddCategoryFormBloc, no setState
                Text('Category Type', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 12),
                BlocBuilder<AddCategoryFormBloc, AddCategoryFormState>(
                  builder: (context, formState) {
                    final selectedType = formState is AddCategoryFormReady
                        ? formState.type
                        : CategoryType.expense;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      // RadioGroup is valid in latest stable Flutter
                      child: RadioGroup<CategoryType>(
                        groupValue: selectedType,
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddCategoryFormBloc>().add(
                              AddCategoryChangeType(value),
                            );
                          }
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
                              subtitle: const Text(
                                'For both income and expense',
                              ),
                              value: CategoryType.both,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Icon Selection — driven by AddCategoryFormBloc, no setState
                Text('Select Icon', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 12),
                BlocBuilder<AddCategoryFormBloc, AddCategoryFormState>(
                  builder: (context, formState) {
                    final selectedCodePoint = formState is AddCategoryFormReady
                        ? formState.iconCodePoint
                        : 0xE8B0;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildIconOption(
                          context,
                          Icons.restaurant,
                          'Food',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.directions_car,
                          'Transport',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.shopping_bag,
                          'Shopping',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.home,
                          'Housing',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.medical_services,
                          'Healthcare',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.school,
                          'Education',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.flight,
                          'Travel',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.sports_gymnastics,
                          'Sports',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.movie,
                          'Entertainment',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.credit_card,
                          'Finance',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.phone_android,
                          'Electronics',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.pets,
                          'Pets',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.child_care,
                          'Childcare',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.cleaning_services,
                          'Services',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.local_gas_station,
                          'Fuel',
                          selectedCodePoint,
                        ),
                        _buildIconOption(
                          context,
                          Icons.checkroom,
                          'Clothing',
                          selectedCodePoint,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    final isLoading = state is CategoryLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: isLoading ? 'Adding...' : 'Add Category',
                        icon: Icons.add,
                        onPressed: isLoading
                            ? null
                            : () => _submitForm(context),
                        size: AppButtonSize.large,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(
    BuildContext context,
    IconData icon,
    String label,
    int selectedCodePoint,
  ) {
    final isSelected = icon.codePoint == selectedCodePoint;

    return GestureDetector(
      onTap: () {
        context.read<AddCategoryFormBloc>().add(
          AddCategorySelectIcon(icon.codePoint),
        );
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

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final formState = context.read<AddCategoryFormBloc>().state;
    final categoryType = formState is AddCategoryFormReady
        ? formState.type
        : CategoryType.expense;
    final iconCodePoint = formState is AddCategoryFormReady
        ? formState.iconCodePoint
        : Icons.category.codePoint;

    final isIncome =
        categoryType == CategoryType.income ||
        categoryType == CategoryType.both;
    final isExpense =
        categoryType == CategoryType.expense ||
        categoryType == CategoryType.both;

    context.read<CategoryBloc>().add(
      CreateCategoryEvent(
        name: _nameController.text.trim(),
        isIncome: isIncome,
        isExpense: isExpense,
        iconCodePoint: iconCodePoint.toString(),
        iconFontFamily: 'MaterialIcons',
      ),
    );
  }
}
