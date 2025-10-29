import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/saving/impl/saving_repository.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_state.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SavingsBloc(SavingRepository())..add(LoadSavingsListEvent()),
      child: BlocConsumer<SavingsBloc, SavingsState>(
        listener: (context, state) {
          if (state is SavingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SavingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          Map<ActionButtonEnum, VoidCallback?> floatingActionButtonMap = {};
          if (!(state is SavingsFormLoaded ||
              state is SavingTransactionFormLoaded)) {
            floatingActionButtonMap[ActionButtonEnum.addNewSaving] = () {
              context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
            };
          }
          BlocProvider.of<ActionButtonBloc>(context).add(
            OnUpdateActionButtonEvent(
              context: context,
              actionButtonMap: floatingActionButtonMap,
            ),
          );

          if (state is SavingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SavingsListLoaded) {
            return _buildSavingsList(context, state.savingsList);
          } else if (state is SavingsFormLoaded) {
            return _buildSavingsForm(
              context,
              isEditing: state.isEditing,
              saving: state.saving,
              moneyStorageList: state.moneyStorageOptions,
            );
          } else if (state is SavingTransactionFormLoaded) {
            // For transaction form, we'll show a placeholder for now
            // Since we don't have the full transaction implementation
            return _buildTransactionForm(context, state.savingId);
          } else if (state is SavingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SavingsBloc>().add(LoadSavingsListEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSavingsList(
    BuildContext context,
    List<ListSavingVO> savingsList,
  ) {
    // Group savings by type
    final Map<SavingTableType, List<ListSavingVO>> savingGroupMap = {
      for (var t in SavingTableType.values) t: [],
    };

    for (final saving in savingsList) {
      final type = SavingTableType.findByValue(saving.saving.type);
      if (type != null) savingGroupMap[type]?.add(saving);
    }

    // If there are no savings, show empty state
    if (savingsList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'No savings yet',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Add your first savings account to get started',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, build scrollable list
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Savings',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...savingGroupMap.entries
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => _buildSavingGroup(context, entry)),
          const SizedBox(height: 88.0), // Add extra space for the FAB
        ],
      ),
    );
  }

  Widget _buildSavingGroup(
    BuildContext context,
    MapEntry<SavingTableType, List<ListSavingVO>> entry,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              entry.key.label,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          ...entry.value.map((saving) => _buildSavingCard(context, saving)),
        ],
      ),
    );
  }

  Widget _buildSavingCard(BuildContext context, ListSavingVO saving) {
    final isMinus = saving.saving.currentAmount < 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 25,
            child: const Icon(Icons.money, color: Colors.white),
          ),
          title: Text(
            saving.saving.name ?? 'Unnamed Saving',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (saving.moneyStorage != null)
                  Text(
                    'From: ${saving.moneyStorage!.shortName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                const SizedBox(height: 4.0),
                Text(
                  '${isMinus ? '- ' : ''}RM ${saving.saving.currentAmount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: isMinus ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          trailing: _buildPopupMenu(context, saving),
          onTap: () => context.read<SavingsBloc>().add(
            LoadEditSavingsEvent(saving.saving.id),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ListSavingVO saving) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
      onSelected: (String result) async {
        switch (result) {
          case 'edit':
            context.read<SavingsBloc>().add(
              LoadEditSavingsEvent(saving.saving.id),
            );
            break;
          case 'transaction':
            context.read<SavingsBloc>().add(
              LoadSavingTransactionEvent(savingId: saving.saving.id),
            );
            break;
          case 'delete':
            showDeleteDialog(
              context: context,
              onDelete: () async {
                context.read<SavingsBloc>().add(
                  _DeleteSavingEvent(saving.saving.id),
                );
              },
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsForm(
    BuildContext context, {
    required bool isEditing,
    ListSavingVO? saving,
    required List<SvngMoneyStorage> moneyStorageList,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: saving?.saving.name ?? '',
    );
    final initialAmountController = TextEditingController(
      text: saving?.saving.currentAmount.toString() ?? '',
    );
    final goalAmountController = TextEditingController(
      text: saving?.saving.goal.toString() ?? '',
    );

    String selectedSavingType =
        saving?.saving.type ?? SavingTableType.saving.value;
    String? selectedMoneyStorageId = saving?.moneyStorage?.id;

    bool isHasGoal = saving?.saving.isHasGoal ?? false;

    List<DropdownMenuItem<String>> moneyStorageItems = [];

    // Default item
    moneyStorageItems.add(
      const DropdownMenuItem<String>(
        value: '',
        child: Text('No Money Storage'),
      ),
    );

    for (var storage in moneyStorageList) {
      moneyStorageItems.add(
        DropdownMenuItem<String>(
          value: storage.id,
          child: Text(storage.shortName),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Text(
              isEditing ? 'Edit Saving' : 'Add New Saving',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: initialAmountController,
              decoration: const InputDecoration(
                labelText: 'Initial Amount (RM)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Has Goal?'),
                      value: isHasGoal,
                      onChanged: (value) {
                        setState(() {
                          isHasGoal = value;
                        });
                      },
                    ),
                    if (isHasGoal)
                      TextFormField(
                        controller: goalAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Amount (RM)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (isHasGoal) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a goal amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Dropdown for saving type
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                initialValue: selectedSavingType,
                decoration: const InputDecoration(
                  labelText: 'Saving Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: SavingTableType.values.map((type) {
                  return DropdownMenuItem<String>(
                    value: type.value,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedSavingType = newValue;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown for money storage
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                initialValue: selectedMoneyStorageId,
                decoration: const InputDecoration(
                  labelText: 'Money Storage',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: moneyStorageItems,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedMoneyStorageId = newValue;
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to list
                      context.read<SavingsBloc>().add(LoadSavingsListEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final initialAmount = double.parse(
                          initialAmountController.text,
                        );
                        final goalAmount =
                            isHasGoal && goalAmountController.text.isNotEmpty
                            ? double.parse(goalAmountController.text)
                            : 0.0;

                        if (isEditing && saving != null) {
                          context.read<SavingsBloc>().add(
                            UpdateSavingsEvent(
                              id: saving.saving.id,
                              name: nameController.text,
                              initialAmount: initialAmount,
                              isHasGoal: isHasGoal,
                              goalAmount: goalAmount,
                              moneyStorageId: selectedMoneyStorageId ?? '',
                              savingType: selectedSavingType,
                            ),
                          );
                        } else {
                          // For now, using empty string for money storage ID
                          // In a real implementation, we'd need to fetch available money storage options
                          context.read<SavingsBloc>().add(
                            AddSavingsEvent(
                              name: nameController.text,
                              initialAmount: initialAmount,
                              isHasGoal: isHasGoal,
                              goalAmount: goalAmount,
                              moneyStorageId:
                                  selectedMoneyStorageId ??
                                  '', // Would need to implement selection
                              savingType: selectedSavingType,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionForm(BuildContext context, String savingId) {
    return const Center(child: Text('Transaction form coming soon'));
  }
}

// Helper event for deletion that's not exposed publicly
class _DeleteSavingEvent extends SavingsEvent {
  final String id;

  const _DeleteSavingEvent(this.id);

  @override
  List<Object> get props => [id];
}
