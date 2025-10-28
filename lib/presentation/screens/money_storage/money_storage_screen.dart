import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_event.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_state.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';

class MoneyStorageScreen extends StatelessWidget {
  const MoneyStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoneyStorageBloc(
        MoneyStorageRepository(),
      )..add(LoadMoneyStorageListEvent()),
      child: BlocConsumer<MoneyStorageBloc, MoneyStorageState>(
        listener: (context, state) {
          if (state is MoneyStorageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MoneyStorageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MoneyStorageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MoneyStorageListLoaded) {
            return _buildMoneyStorageList(context, state.moneyStorageList);
          } else if (state is MoneyStorageFormLoaded) {
            return _buildMoneyStorageForm(
              context,
              isEditing: state.isEditing,
              moneyStorage: state.moneyStorage,
            );
          } else if (state is MoneyStorageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MoneyStorageBloc>().add(LoadMoneyStorageListEvent());
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

  Widget _buildMoneyStorageList(BuildContext context, List<MoneyStorageVO> moneyStorageList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Money Storage',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: moneyStorageList.isNotEmpty
                ? ListView.builder(
                    itemCount: moneyStorageList.length,
                    itemBuilder: (context, index) {
                      final storage = moneyStorageList[index];
                      bool isMinus = storage.amount < 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
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
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                              ),
                              child: const Icon(
                                Icons.account_balance,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              storage.moneyStorage.shortName,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storage.moneyStorage.longName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${isMinus ? '- ' : ''}RM ${storage.amount.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: isMinus ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  context.read<MoneyStorageBloc>().add(
                                    LoadEditMoneyStorageEvent(storage.moneyStorage.id),
                                  );
                                }
                                if (result == 'delete') {
                                  showDeleteDialog(
                                    context: context,
                                    onDelete: () {
                                      context.read<MoneyStorageBloc>().add(
                                        DeleteMoneyStorageEvent(storage.moneyStorage.id),
                                      );
                                    },
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
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
                            ),
                            onTap: () => context.read<MoneyStorageBloc>().add(
                              LoadEditMoneyStorageEvent(storage.moneyStorage.id),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'No money storage yet',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Add your first money storage to get started',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () => context.read<MoneyStorageBloc>().add(LoadAddMoneyStorageEvent()),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStorageForm(
    BuildContext context, {
    required bool isEditing,
    MoneyStorageVO? moneyStorage,
  }) {
    final formKey = GlobalKey<FormState>();
    final shortNameController = TextEditingController(
      text: moneyStorage?.moneyStorage.shortName ?? '',
    );
    final longNameController = TextEditingController(
      text: moneyStorage?.moneyStorage.longName ?? '',
    );
    final amountController = TextEditingController(
      text: moneyStorage?.amount.toString() ?? '',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Text(
              isEditing ? 'Edit Money Storage' : 'Add New Money Storage',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: shortNameController,
              decoration: const InputDecoration(
                labelText: 'Short Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a short name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: longNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to list
                      context.read<MoneyStorageBloc>().add(LoadMoneyStorageListEvent());
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
                        final amount = double.parse(amountController.text);
                        if (isEditing && moneyStorage != null) {
                          context.read<MoneyStorageBloc>().add(
                            UpdateMoneyStorageEvent(
                              id: moneyStorage.moneyStorage.id,
                              shortName: shortNameController.text,
                              longName: longNameController.text,
                              amount: amount,
                            ),
                          );
                        } else {
                          context.read<MoneyStorageBloc>().add(
                            AddMoneyStorageEvent(
                              shortName: shortNameController.text,
                              longName: longNameController.text,
                              amount: amount,
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
}