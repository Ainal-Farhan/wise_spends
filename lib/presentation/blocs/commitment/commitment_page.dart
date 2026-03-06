import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/shared/components/forms/commitment_detail_form.dart';
import 'package:wise_spends/shared/components/forms/commitment_form.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class CommitmentPage extends StatefulWidget {
  static const String routeName = AppRoutes.commitment;

  const CommitmentPage({super.key});

  @override
  State<CommitmentPage> createState() => _CommitmentPageState();
}

class _CommitmentPageState extends State<CommitmentPage> {
  late final CommitmentBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CommitmentBloc();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: AppRoutes.commitment,
      screen: BlocProvider.value(
        value: bloc..add(const LoadCommitmentsEvent()),
        child: BlocConsumer<CommitmentBloc, CommitmentState>(
          listener: (context, state) {
            if (state is CommitmentStateSuccess) {
              showSnackBarMessage(context, state.message);
              Timer(const Duration(milliseconds: 500), () {
                bloc.add(state.nextEvent);
              });
            }
          },
          builder: (context, state) {
            final double screenHeight = MediaQuery.of(context).size.height;

            Widget bounded(Widget child) => SizedBox.expand(child: child);

            // ---------------------------------------------------------------------------
            // FAB map — updated to use new state/event names
            // ---------------------------------------------------------------------------
            Map<ActionButtonEnum, VoidCallback?> floatingActionButtonMap = {};

            if (state is CommitmentStateCommitmentsLoaded) {
              floatingActionButtonMap[ActionButtonEnum.displayCommitment] =
                  () => bloc.add(const LoadCommitmentFormEvent());
            } else if (state is CommitmentStateDetailScreenReady) {
              // "Add detail" opens the detail form by loading form data.
              // We use LoadCommitmentFormEvent with no commitmentVO so only
              // the savings list is fetched, then CommitmentDetailForm handles
              // the rest. If you have a dedicated detail-form event, swap it here.
              floatingActionButtonMap[ActionButtonEnum.addCommitmentDetail] =
                  () => bloc.add(LoadDetailScreenEvent(state.commitmentId));
              floatingActionButtonMap[ActionButtonEnum.backToCommitments] =
                  () => bloc.add(const LoadCommitmentsEvent());
            } else if (state is CommitmentStateCommitmentFormLoaded) {
              floatingActionButtonMap[ActionButtonEnum.backButton] = () =>
                  bloc.add(const LoadCommitmentsEvent());
            }

            BlocProvider.of<ActionButtonBloc>(context).add(
              OnUpdateActionButtonEvent(
                context: context,
                actionButtonMap: floatingActionButtonMap,
              ),
            );

            // ---------------------------------------------------------------------------
            // Loading
            // ---------------------------------------------------------------------------
            if (state is CommitmentStateLoading) {
              return bounded(const Center(child: CircularProgressIndicator()));
            }

            // ---------------------------------------------------------------------------
            // Error
            // ---------------------------------------------------------------------------
            if (state is CommitmentStateError) {
              return bounded(
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () =>
                              bloc.add(const LoadCommitmentsEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // ---------------------------------------------------------------------------
            // Commitment list
            // ---------------------------------------------------------------------------
            if (state is CommitmentStateCommitmentsLoaded) {
              final commitments = state.commitments;
              return bounded(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          'Your Commitments',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: commitments.isNotEmpty
                            ? ListView.builder(
                                itemCount: commitments.length,
                                itemBuilder: (context, index) {
                                  final commitment = commitments[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.1),
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.3),
                                          ],
                                        ),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          commitment.name ??
                                              'Unnamed Commitment',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          child: const Icon(
                                            Icons.task,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'RM ${(commitment.totalAmount ?? .0).toStringAsFixed(2)} • ${commitment.commitmentDetailVOList.length} items',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (commitment.description !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Text(
                                                      'Description: ${commitment.description}',
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Text(
                                                    'From: ${commitment.referredSavingVO?.savingName ?? 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      ElevatedButton.icon(
                                                        // Updated: LoadDetailScreenEvent replaces LoadCommitmentDetailEvent
                                                        onPressed: () => bloc.add(
                                                          LoadDetailScreenEvent(
                                                            commitment
                                                                .commitmentId!,
                                                          ),
                                                        ),
                                                        icon: const Icon(
                                                          Icons.list,
                                                          size: 18,
                                                        ),
                                                        label: const Text(
                                                          'Details',
                                                        ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                      ElevatedButton.icon(
                                                        onPressed: () => showConfirmDialog(
                                                          context: context,
                                                          message:
                                                              'Distribute Commitment?',
                                                          onConfirm: () async {
                                                            bloc.add(
                                                              StartDistributeCommitmentEvent(
                                                                commitment,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        icon: const Icon(
                                                          Icons.start_rounded,
                                                          size: 18,
                                                        ),
                                                        label: const Text(
                                                          'Distribute',
                                                        ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () => bloc.add(
                                                          EditCommitmentEvent(
                                                            commitment,
                                                          ),
                                                        ),
                                                        icon: const Icon(
                                                          Icons.edit,
                                                        ),
                                                        tooltip: 'Edit',
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showDeleteDialog(
                                                            context: context,
                                                            onDelete: () async {
                                                              BlocProvider.of<
                                                                    CommitmentBloc
                                                                  >(context)
                                                                  .add(
                                                                    DeleteCommitmentEvent(
                                                                      commitment
                                                                          .commitmentId!,
                                                                    ),
                                                                  );
                                                            },
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        tooltip: 'Delete',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
                                        Icons.assignment_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'No commitments yet',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      const Text(
                                        'Create your first commitment to start tracking goals',
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
                    ],
                  ),
                ),
              );
            }

            // ---------------------------------------------------------------------------
            // Add / edit commitment form
            // ---------------------------------------------------------------------------
            if (state is CommitmentStateCommitmentFormLoaded) {
              return bounded(
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: SizedBox(
                          height: screenHeight * .7,
                          child: CommitmentForm(
                            commitmentVO: state.commitmentVO,
                            savingVOList: state.savingVOList,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ---------------------------------------------------------------------------
            // Detail screen — replaces old CommitmentStateCommitmentDetailLoaded
            // and CommitmentStateCommitmentDetailFormLoaded.
            //
            // CommitmentStateDetailScreenReady carries BOTH the detail list AND
            // the savings list, so the detail form can be shown inline here without
            // needing a second state type.
            // ---------------------------------------------------------------------------
            if (state is CommitmentStateDetailScreenReady) {
              final commitmentDetails = state.commitmentDetails;
              return bounded(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          'Commitment Details',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: commitmentDetails.isNotEmpty
                            ? ListView.builder(
                                itemCount: commitmentDetails.length,
                                itemBuilder: (context, index) {
                                  final detail = commitmentDetails[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.1),
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.3),
                                          ],
                                        ),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          detail.description ??
                                              'Unnamed Detail',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          child: const Icon(
                                            Icons.task,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'RM ${(detail.amount ?? .0).toStringAsFixed(2)} • From: ${detail.referredSavingVO?.savingName ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Text(
                                                    'Amount: RM ${(detail.amount ?? .0).toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Text(
                                                    'From: ${detail.referredSavingVO?.savingName ?? 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                if (detail.description !=
                                                        null &&
                                                    detail
                                                        .description!
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Text(
                                                      'Description: ${detail.description}',
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      // Edit: show the detail form inline using CommitmentDetailForm.
                                                      // state.savingVOList is already loaded — no extra event needed.
                                                      IconButton(
                                                        onPressed: () =>
                                                            _showEditDetailForm(
                                                              context,
                                                              state,
                                                              detail,
                                                              screenHeight,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.edit,
                                                        ),
                                                        tooltip: 'Edit',
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          showDeleteDialog(
                                                            context: context,
                                                            onDelete: () async {
                                                              BlocProvider.of<CommitmentBloc>(
                                                                context,
                                                              ).add(
                                                                DeleteCommitmentDetailEvent(
                                                                  detail
                                                                      .commitmentDetailId!,
                                                                  commitmentId:
                                                                      state
                                                                          .commitmentId,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        tooltip: 'Delete',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
                                        Icons.task_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'No commitment details yet',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      const Text(
                                        'Add details to track your commitment progress',
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
                    ],
                  ),
                ),
              );
            }

            return bounded(const Center(child: CircularProgressIndicator()));
          },
        ),
      ),
      showBottomNavBar: true,
      bloc: bloc,
    );
  }

  /// Shows the commitment detail edit form in a bottom sheet, using the savings
  /// list already present in [state] — no extra event or state transition needed.
  void _showEditDetailForm(
    BuildContext context,
    CommitmentStateDetailScreenReady state,
    dynamic detail,
    double screenHeight,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: CommitmentDetailForm(
                  commitmentDetailVO: detail,
                  savingVOList: state.savingVOList,
                  commitmentId: state.commitmentId,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
