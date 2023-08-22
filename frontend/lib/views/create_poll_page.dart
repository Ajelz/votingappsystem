import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class CreatePollPage extends StatefulWidget {
  final User user;

  CreatePollPage({required this.user});

  @override
  _CreatePollPageState createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  final _formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [];

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Poll'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            TextFormField(
              controller: questionController,
              decoration: const InputDecoration(
                hintText: 'Enter poll question',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            for (var controller in optionControllers)
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter option',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            TextButton(
              onPressed: () {
                optionControllers.add(TextEditingController());
                setState(() {});
              },
              child: Text('Add Option'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      var question = questionController.text;
                      var options = optionControllers
                          .map((controller) => controller.text)
                          .toList();
                      bool isSuccess =
                          await ApiService().createPoll(question, options);
                      if (isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Poll created successfully'),
                        ));
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        throw Exception('Failed to create poll');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')));
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
