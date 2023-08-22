import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<String> _votes = ['Vote 1', 'Vote 2', 'Vote 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: ListView.builder(
        itemCount: _votes.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_votes[index]),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
