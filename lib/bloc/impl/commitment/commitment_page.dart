import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/components/forms/commitment_detail_form.dart';
import 'package:wise_spends/components/forms/commitment_form.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/templates/th_logged_in_main_template_default.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class CommitmentPage extends StatefulWidget {
  static const String routeName = AppRouter.commitmentPageRoute;

  const CommitmentPage({super.key});

  @override
  State<CommitmentPage> createState() => _CommitmentPageState();
}

class _CommitmentPageState extends State<CommitmentPage> {
  final GlobalKey<ThLoggedInMainTemplateDefaultState> _templateKey = 
      GlobalKey<ThLoggedInMainTemplateDefaultState>();

  @override
  Widget build(BuildContext context) {
    CommitmentBloc bloc = CommitmentBloc();
    return IThLoggedInMainTemplate(
      key: _templateKey,
      pageRoute: AppRouter.commitmentPageRoute,
      screen: BlocProvider(
        create: (_) => bloc..add(const LoadCommitmentsEvent()),
        child: BlocConsumer(
          listener: (context, state) {
            if (state is CommitmentStateSuccess) {
              // Call updateAppBar when distribution succeeds
              _templateKey.currentState?.updateAppBar();
              
              // Add a small delay before navigating back to show success message
              Timer(const Duration(milliseconds: 1500), () {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  bloc.add(const LoadCommitmentsEvent());
                }
              });
            }
          },
          builder: (context, state) {
            final double screenHeight = MediaQuery.of(context).size.height;
            if (state is CommitmentStateCommitmentDetailFormLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.1, child: Container()),
                  Center(
                    child: SizedBox(
                      height: screenHeight * .7,
                      child: CommitmentDetailForm(
                        commitmentDetailVO: state.commitmentDetailVO,
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
                            IThBackButtonRound(
                              onTap: () =>
                                  bloc.add(const LoadCommitmentDetailEvent(null)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state is CommitmentStateCommitmentsLoaded) {
              final commitments = state.commitments;
              return Padding(
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
                                final commitment =
                                    commitments[index];

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
                                      borderRadius: BorderRadius.circular(12.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1),
                                          Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.3),
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
                                                padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: Text(
                                                  'From: ${commitment.referredSavingVO?.savingName ?? 'N/A'}',
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () => bloc.add(
                                                      LoadCommitmentDetailEvent(
                                                        commitment.commitmentId,
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
                                                                  commitment.commitmentId!,
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
              );
            }

            if (state is CommitmentStateCommitmentFormLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.1, child: Container()),
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
                            IThBackButtonRound(
                              onTap: () =>
                                  bloc.add(const LoadCommitmentsEvent()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state is CommitmentStateLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is CommitmentStateError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
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
                        onPressed: () => bloc.add(const LoadCommitmentsEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is InLoadCommitmentDetailListState) {
              List<ListTilesOneVO> commitmentListTilesOneVOList = [];

              for (
                int index = 0;
                index < state.commitmentDetailVOList.length;
                index++
              ) {
                commitmentListTilesOneVOList.add(
                  ListTilesOneVO(
                    index: index,
                    title:
                        state.commitmentDetailVOList[index].description ?? '-',
                    icon: const Icon(
                      Icons.task,
                      color: Color.fromARGB(255, 67, 18, 160),
                    ),
                    subtitleWidget: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings: ${state.commitmentDetailVOList[index].referredSavingVO?.savingName ?? '-'}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Total: RM ${(state.commitmentDetailVOList[index].amount ?? .0).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    onTap: () async =>
                        BlocProvider.of<CommitmentBloc>(context).add(
                          EditCommitmentDetailEvent(
                            toBeEdited: state.commitmentDetailVOList[index],
                          ),
                        ),
                    onLongPressed: () async {
                      showDeleteDialog(
                        context: context,
                        onDelete: () async {
                          BlocProvider.of<CommitmentBloc>(context).add(
                            DeleteCommitmentDetailEvent(
                              toBeDeleted: state.commitmentDetailVOList[index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.8,
                      child: IThListTilesOne(
                        items: commitmentListTilesOneVOList,
                        emptyListMessage: 'No Commitment Detail Available...',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IThBackButtonRound(
                          onTap: () => bloc.add(OnLoadListCommitmentEvent()),
                        ),
                        IThPlusButtonRound(
                          onTap: () => bloc.add(
                            OnViewAddCommitmentDetailFormEvent(
                              state.commitmentId,
                              state.commitmentDetailVOList,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
      showBottomNavBar: false,
      bloc: bloc,
    );
  }
}
