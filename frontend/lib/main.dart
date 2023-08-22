import 'package:flutter/material.dart';
import 'package:frontend/views/login_page.dart';
import 'package:frontend/views/user_page.dart';
import 'package:frontend/views/vote_page.dart';
import 'package:frontend/views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/user': (context) => const UserPage(),
      },
    );
  }
}
