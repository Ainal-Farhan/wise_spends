import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/components/forms/commitment_detail_form.dart';
import 'package:wise_spends/components/forms/commitment_form.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/templates/th_logged_in_main_template.dart';
import 'package:wise_spends/constants/hero_tags.dart';

class CommitmentPage extends StatefulWidget {
  static const String routeName = AppRouter.commitmentPageRoute;

  const CommitmentPage({super.key});

  @override
  State<CommitmentPage> createState() => _CommitmentPageState();
}

class _CommitmentPageState extends State<CommitmentPage> {
  late final CommitmentBloc bloc;
  final List<FloatingActionButton> floatingActionButtons = [];

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
      pageRoute: AppRouter.commitmentPageRoute,
      screen: BlocProvider.value(
        value: bloc..add(const LoadCommitmentsEvent()),
        child: BlocConsumer<CommitmentBloc, CommitmentState>(
          listener: (context, state) {
            if (state is CommitmentStateSuccess) {
              showSnackBarMessage(context, state.message);

              // Add a small delay before navigating back to show success message
              Timer(const Duration(milliseconds: 1500), () {
                bloc.add(state.nextEvent);
              });
            }
          },
          builder: (context, state) {
            final double screenHeight = MediaQuery.of(context).size.height;

            // Helper to wrap content so it has bounded constraints inside the parent's Stack
            Widget bounded(Widget child) => SizedBox.expand(child: child);

            if (state is CommitmentStateCommitmentDetailFormLoaded) {
              return bounded(
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          height: screenHeight * .7,
                          child: CommitmentDetailForm(
                            commitmentDetailVO: state.commitmentDetailVO,
                            savingVOList: state.savingVOList,
                            commitmentId: state.commitmentId!,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ThBackButtonRound(
                                  onTap: () => bloc.add(
                                    LoadCommitmentDetailEvent(
                                      state.commitmentId,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CommitmentStateCommitmentsLoaded) {
              final commitments = state.commitments;
              return bounded(
                // Use Column with Expanded here — now it's safe because bounded provides constraints
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
                                                        onPressed: () => bloc.add(
                                                          LoadCommitmentDetailEvent(
                                                            commitment
                                                                .commitmentId,
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
                                                              "Distribute Commitment?",
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              heroTag: HeroTagConstants.displayCommitment,
                              onPressed: () => BlocProvider.of<CommitmentBloc>(
                                context,
                              ).add(const LoadCommitmentFormEvent()),
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CommitmentStateCommitmentFormLoaded) {
              return bounded(
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          height: screenHeight * .7,
                          child: CommitmentForm(
                            commitmentVO: state.commitmentVO,
                            savingVOList: state.savingVOList,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ThBackButtonRound(
                                  onTap: () =>
                                      bloc.add(const LoadCommitmentsEvent()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CommitmentStateLoading) {
              return bounded(const Center(child: CircularProgressIndicator()));
            }

            if (state is CommitmentStateError) {
              return bounded(
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: Colors.red),
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

            if (state is CommitmentStateCommitmentDetailLoaded) {
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
                                                      IconButton(
                                                        onPressed: () => bloc.add(
                                                          EditCommitmentDetailEvent(
                                                            commitmentDetailVO:
                                                                detail,
                                                            commitmentId: state
                                                                .commitmentId,
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              heroTag: HeroTagConstants.backToCommitments,
                              onPressed: () =>
                                  bloc.add(const LoadCommitmentsEvent()),
                              backgroundColor: Colors.grey,
                              child: const Icon(Icons.arrow_back),
                            ),
                            FloatingActionButton(
                              heroTag: HeroTagConstants.addCommitmentDetail,
                              onPressed: () => bloc.add(
                                LoadCommitmentDetailFormEvent(
                                  commitmentId: state.commitmentId,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.add),
                            ),
                          ],
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
      floatingActionButtons: [],
    );
  }
}
