import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/poll.dart';
import 'package:frontend/services/api_service.dart';

class VotePage extends StatefulWidget {
  final User user;
  final Poll poll;

  VotePage({required this.user, required this.poll});

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final apiService = ApiService();
  int? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              widget.poll.question,
              style: Theme.of(context).textTheme.headline4,
            ),
            for (var option in widget.poll.options)
              ListTile(
                title: Text(option.text),
                leading: Radio<int>(
                  value: option.id,
                  groupValue: _selectedOptionId,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedOptionId = value;
                    });
                  },
                ),
              ),
            ElevatedButton(
              onPressed: _selectedOptionId != null ? _submitVote : null,
              child: Text('Submit Vote'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVote() async {
    try {
      await apiService.castVote(
        widget.poll.id,
        _selectedOptionId!,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit vote: $e')),
      );
    }
  }
}
