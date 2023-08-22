import 'package:flutter/material.dart';
import 'package:frontend/models/option.dart';
import 'package:frontend/models/poll.dart';
import 'package:frontend/services/api_service.dart';

class VoteFunctionality extends StatefulWidget {
  final Poll poll;
  final void Function(int pollId) onVoteCast;
  final String role;

  VoteFunctionality(
      {required this.poll, required this.onVoteCast, required this.role});

  @override
  _VoteFunctionalityState createState() => _VoteFunctionalityState();
}

class _VoteFunctionalityState extends State<VoteFunctionality> {
  late Option selectedOption;
  bool hasVoted = false;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.poll.options[0];
  }

  Future<void> _castVote() async {
    try {
      await ApiService().castVote(widget.poll.id, selectedOption.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote cast successfully!')),
      );

      if (widget.role != 'admin') {
        setState(() {
          hasVoted = true;
        });
        widget.onVoteCast(widget.poll.id);
      } else {}
    } catch (e) {
      print('Error casting vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error casting vote. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = widget.poll.options
        .fold(0, (total, option) => total + (option.voteCount ?? 0));

    bool canVote = !hasVoted && widget.poll.status == 1;

    return Column(
      children: [
        ...widget.poll.options.map((option) {
          int percentage = totalVotes > 0
              ? ((option.voteCount ?? 0) / totalVotes * 100).toInt()
              : 0;
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(option.text),
                Text('${percentage.toString()}%'),
              ],
            ),
            leading: Radio<Option>(
              value: option,
              groupValue: selectedOption,
              onChanged: canVote
                  ? (Option? value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    }
                  : null,
            ),
            onTap: canVote
                ? () {
                    setState(() {
                      selectedOption = option;
                    });
                  }
                : null,
          );
        }).toList(),
        ElevatedButton(
          onPressed: canVote ? _castVote : null,
          child: Text('Cast Vote'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return null;
            }),
          ),
        ),
      ],
    );
  }
}
