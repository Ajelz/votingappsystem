import 'package:flutter/material.dart';
import 'package:frontend/models/option.dart';
import 'package:frontend/models/poll.dart';
import 'package:frontend/services/api_service.dart';

class EditPollPage extends StatefulWidget {
  final Poll poll;
  final Option votedOption;

  EditPollPage({required this.poll, required this.votedOption});

  @override
  _EditPollPageState createState() => _EditPollPageState();
}

class _EditPollPageState extends State<EditPollPage> {
  late Option selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.votedOption;
  }

  Future<void> _updateVote() async {
    try {
      await ApiService().castVote(widget.poll.id, selectedOption.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating vote. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Poll'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.poll.question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...widget.poll.options.map((option) {
              return ListTile(
                title: Text(option.text),
                leading: Radio<Option>(
                  value: option,
                  groupValue: selectedOption,
                  onChanged: (Option? value) {
                    setState(() {
                      selectedOption = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    selectedOption = option;
                  });
                },
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _updateVote,
                child: Text('Update Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
