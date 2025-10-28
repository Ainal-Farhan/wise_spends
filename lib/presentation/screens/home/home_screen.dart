import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/home_repository.dart';
import 'package:wise_spends/presentation/blocs/home/home_bloc.dart';
import 'package:wise_spends/presentation/blocs/home/home_event.dart';
import 'package:wise_spends/presentation/blocs/home/home_state.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(HomeRepository())..add(LoadHomeDataEvent()),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            // Clear all input & return to home after success
            context.read<HomeBloc>().add(LoadHomeDataEvent());
          } else if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return _buildHomeContent(context, state);
          } else if (state is TransactionFormLoaded) {
            return _buildTransactionForm(context, state);
          } else if (state is HomeError) {
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
                      context.read<HomeBloc>().add(LoadHomeDataEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Home Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(LoadTransactionFormEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Make Transaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Daily Usage
          if (state.dailyUsageSavings.isNotEmpty) ...[
            const Text(
              'Daily Usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...state.dailyUsageSavings.map((s) => _buildSavingCard(context, s)),
            const SizedBox(height: 24),
          ],

          // Credit
          if (state.creditSavings.isNotEmpty) ...[
            const Text(
              'Credit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...state.creditSavings.map((s) => _buildSavingCard(context, s)),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingCard(BuildContext context, ListSavingVO saving) {
    final isMinus = saving.saving.currentAmount < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 25,
          child: const Icon(Icons.account_balance_wallet, color: Colors.white),
        ),
        title: Text(
          saving.saving.name ?? 'Unnamed Saving',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (saving.moneyStorage != null)
              Text(
                'From: ${saving.moneyStorage!.shortName}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              '${isMinus ? '- ' : ''}RM ${saving.saving.currentAmount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isMinus ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        trailing: Text(
          SavingTableType.findByValue(saving.saving.type)?.label ?? 'Unknown',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionForm(
    BuildContext context,
    TransactionFormLoaded state,
  ) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    String transactionType = 'out';
    String? sourceSaving;
    String? destinationSaving;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type
                const Text(
                  'Transaction Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [
                    transactionType == 'in',
                    transactionType == 'out',
                    transactionType == 'transfer',
                  ],
                  onPressed: (index) {
                    setState(() {
                      switch (index) {
                        case 0:
                          transactionType = 'in';
                          break;
                        case 1:
                          transactionType = 'out';
                          break;
                        case 2:
                          transactionType = 'transfer';
                          break;
                      }
                      // Reset selection when switching type
                      sourceSaving = null;
                      destinationSaving = null;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('In'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Out'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Transfer'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Saving dropdowns
                if (transactionType != 'in') ...[
                  const Text(
                    'Source Saving',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: sourceSaving,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    isExpanded: true,
                    items: state.allSavings.map((saving) {
                      return DropdownMenuItem<String>(
                        value: saving.saving.id,
                        child: Text(
                          '${saving.saving.name ?? 'Unnamed'} '
                          '(RM ${saving.saving.currentAmount.toStringAsFixed(2)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => sourceSaving = v),
                  ),
                  const SizedBox(height: 16),
                ],

                if (transactionType != 'out') ...[
                  const Text(
                    'Destination Saving',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: destinationSaving,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    isExpanded: true,
                    items: state.allSavings
                        .where((s) => s.saving.id != sourceSaving)
                        .map((saving) {
                          return DropdownMenuItem<String>(
                            value: saving.saving.id,
                            child: Text(
                              saving.saving.name ?? 'Unnamed Saving',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (v) => setState(() => destinationSaving = v),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amount
                const Text(
                  'Amount (RM)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                // const SizedBox(height: 16),

                // // Reference
                // const Text(
                //   'Reference (Optional)',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                // ),
                // const SizedBox(height: 8),
                // TextFormField(
                //   controller: referenceController,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     prefixIcon: Icon(Icons.description),
                //   ),
                // ),
                const SizedBox(height: 32),

                // Submit / Cancel
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(LoadHomeDataEvent());
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
                          final amount = double.tryParse(amountController.text);
                          if ((transactionType == 'in' &&
                                  destinationSaving == null) ||
                              (transactionType == 'out' &&
                                  sourceSaving == null) ||
                              (transactionType == 'transfer' &&
                                  (sourceSaving == null ||
                                      destinationSaving == null))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select all required fields',
                                ),
                              ),
                            );
                            return;
                          }
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                              ),
                            );
                            return;
                          }

                          context.read<HomeBloc>().add(
                            MakeTransactionEvent(
                              sourceSavingId:
                                  sourceSaving ?? destinationSaving ?? '',
                              destinationSavingId: transactionType == 'transfer'
                                  ? destinationSaving
                                  : (transactionType == 'in'
                                        ? destinationSaving
                                        : null),
                              amount: amount,
                              transactionType: transactionType,
                              reference: referenceController.text,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
