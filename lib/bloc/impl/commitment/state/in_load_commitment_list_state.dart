import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/add_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/delete_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/edit_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_detail_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/start_distribute_commitment_event.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class InLoadCommitmentListState extends IState<InLoadCommitmentListState> {
  final List<CommitmentVO> commitmentVOList;

  const InLoadCommitmentListState(
      {required this.commitmentVOList, required super.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Commitments',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: commitmentVOList.isNotEmpty
                ? ListView.builder(
                    itemCount: commitmentVOList.length,
                    itemBuilder: (context, index) {
                      final commitment = commitmentVOList[index];
                      
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
                          child: ExpansionTile(
                            title: Text(
                              commitment.name ?? 'Unnamed Commitment',
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
                                color: Theme.of(context).primaryColor,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (commitment.description != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          'Description: ${commitment.description}',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'From: ${commitment.referredSavingVO?.savingName ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => BlocProvider.of<CommitmentBloc>(context).add(
                                              LoadListCommitmentDetailEvent(commitment)),
                                          icon: const Icon(Icons.list, size: 18),
                                          label: const Text('Details'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => showConfirmDialog(
                                            context: context,
                                            message: "Distribute Commitment?",
                                            onConfirm: () async {
                                              BlocProvider.of<CommitmentBloc>(context).add(
                                                  StartDistributeCommitmentEvent(commitment));
                                            },
                                          ),
                                          icon: const Icon(Icons.start_rounded, size: 18),
                                          label: const Text('Distribute'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => BlocProvider.of<CommitmentBloc>(context)
                                              .add(EditCommitmentEvent(toBeEdited: commitment)),
                                          icon: const Icon(Icons.edit),
                                          tooltip: 'Edit',
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDeleteDialog(
                                              context: context,
                                              onDelete: () async {
                                                BlocProvider.of<CommitmentBloc>(context)
                                                    .add(DeleteCommitmentEvent(
                                                  toBeDeleted: commitment,
                                                ));
                                              },
                                            );
                                          },
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Delete',
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
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.savingsPageRoute,
                  ),
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.arrow_back),
                ),
                FloatingActionButton(
                  onPressed: () => BlocProvider.of<CommitmentBloc>(context)
                      .add(AddCommitmentEvent()),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  @override
  InLoadCommitmentListState getNewVersion() => InLoadCommitmentListState(
      commitmentVOList: commitmentVOList, version: version + 1);

  @override
  InLoadCommitmentListState getStateCopy() => InLoadCommitmentListState(
      commitmentVOList: commitmentVOList, version: version);
}
