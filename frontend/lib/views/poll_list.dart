import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/poll.dart';
import 'dart:math';
import 'vote_functionality.dart';
import 'package:intl/intl.dart';

class PollList extends StatefulWidget {
  final List<int> votedPollIds;
  final Function(int pollId) onVoteCast;
  final String role;

  PollList(
      {required this.votedPollIds,
      required this.onVoteCast,
      required this.role});

  @override
  _PollListState createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late Future<List<Poll>> _pollsFuture;

  @override
  void initState() {
    super.initState();
    _pollsFuture = _fetchPolls();
  }

  Future<List<Poll>> _fetchPolls() async {
    return await ApiService().fetchAllPolls();
  }

  void refreshPolls() {
    setState(() {
      _pollsFuture = _fetchPolls();
    });
  }

  void onVoteCastAndRefresh(int pollId) {
    widget.onVoteCast(pollId);
    refreshPolls();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        refreshPolls();
      },
      child: FutureBuilder<List<Poll>>(
        future: _pollsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error during fetchUserPolls: ${snapshot.error}');
            print('Stack trace: ${snapshot.stackTrace}');
            return Text('Error: ${snapshot.error}');
          } else {
            final polls = snapshot.data!;
            if (widget.role != 'admin') {
              polls
                  .removeWhere((poll) => widget.votedPollIds.contains(poll.id));
            }
            return ListView.builder(
              itemCount: polls.length,
              itemBuilder: (context, index) {
                final poll = polls[index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.grey[(Random().nextInt(9) + 1) * 100],
                        ),
                        title: Text(poll.question),
                        subtitle: Text(
                          'Posted by ${poll.createdBy}\n'
                          'Status: ${poll.status == 1 ? "Active" : "Inactive"}\n'
                          'Created at: ${_formatDateTime(poll.createdAt)}',
                        ),
                        trailing: widget.role == 'admin'
                            ? PopupMenuButton<String>(
                                onSelected: (String result) {
                                  if (result == 'Delete Poll') {
                                    _deletePoll(context, poll.id);
                                  } else if (result == 'Toggle Activation') {
                                    _toggleActivation(context, poll);
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Delete Poll',
                                    child: Text('Delete Poll'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Toggle Activation',
                                    child: Text(poll.status == 1
                                        ? 'Deactivate Poll'
                                        : 'Activate Poll'),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      VoteFunctionality(
                          poll: poll,
                          onVoteCast: onVoteCastAndRefresh,
                          role: widget.role),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd, h:mm a').format(dateTime.toLocal());
  }

  Future<void> _deletePoll(BuildContext context, int pollId) async {
    try {
      await ApiService().deletePoll(pollId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poll deleted successfully')),
      );
      refreshPolls();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting poll: $e')),
      );
    }
  }

  Future<void> _toggleActivation(BuildContext context, Poll poll) async {
    try {
      if (poll.status == 1) {
        await ApiService().deactivatePoll(poll.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Poll deactivated successfully')),
        );
      } else {
        await ApiService().activatePoll(poll.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Poll activated successfully')),
        );
      }
      refreshPolls();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling poll activation: $e')),
      );
    }
  }
}
