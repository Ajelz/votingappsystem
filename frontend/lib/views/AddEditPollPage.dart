import 'package:flutter/material.dart';
import 'package:frontend/models/poll.dart';
import 'package:frontend/services/api_service.dart';

class AddEditPollPage extends StatefulWidget {
  final Poll? poll;

  AddEditPollPage({Key? key, this.poll}) : super(key: key);

  @override
  _AddEditPollPageState createState() => _AddEditPollPageState();
}

class _AddEditPollPageState extends State<AddEditPollPage> {
  late ApiService apiService;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _titleController = TextEditingController(text: widget.poll?.question ?? '');
    _optionControllers = List.generate(
        widget.poll?.options.length ?? 2,
        (index) => TextEditingController(
            text: widget.poll != null ? widget.poll!.options[index].text : ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poll == null ? 'Add Poll' : 'Edit Poll'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Enter poll title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              ..._optionControllers.map((controller) => TextFormField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter option text'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  )),
              ElevatedButton(
                onPressed: _addOption,
                child: Text('Add option'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _save,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      List<String> options =
          _optionControllers.map((controller) => controller.text).toList();

      if (widget.poll == null) {
        apiService.createPoll(_titleController.text, options);
      } else {
        apiService.updatePoll(widget.poll!.id, _titleController.text);
      }

      Navigator.of(context).pop('update');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _optionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
