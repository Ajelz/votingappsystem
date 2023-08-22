import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/vote.dart';
import 'package:frontend/services/api_service.dart';
import 'edit_poll.dart';

class MyVotesPage extends StatefulWidget {
  final User user;

  MyVotesPage({required this.user});

  @override
  _MyVotesPageState createState() => _MyVotesPageState();
}

class _MyVotesPageState extends State<MyVotesPage> {
  final apiService = ApiService();
  Future<List<Vote>>? _votesFuture;

  @override
  void initState() {
    super.initState();
    _refreshVotes();
  }

  Future<void> _refreshVotes() async {
    if (widget.user.id != null) {
      try {
        setState(() {
          _votesFuture = apiService.getUserVotes(widget.user.id!);
        });
      } catch (e) {
        print("Exception in getUserVotes: $e");
        setState(() {
          _votesFuture = Future.error('Failed to load votes');
        });
      }
    } else {
      throw Exception('User id is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Votes'),
      ),
      body: FutureBuilder<List<Vote>>(
        future: _votesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load votes. Please try again.'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshVotes,
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  ...snapshot.data!.map((vote) {
                    return ListTile(
                      title: Text(vote.poll.question),
                      subtitle: Text('Voted: ${vote.selectedOption.text}'),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPollPage(
                              poll: vote.poll,
                              votedOption: vote.selectedOption,
                            ),
                          ),
                        );
                        if (result != null && result) {
                          _refreshVotes();
                        }
                      },
                    );
                  }).toList(),
                  if (snapshot.data == null || snapshot.data!.isEmpty)
                    Center(child: Text('No votes found.')),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
