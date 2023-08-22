import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'profile_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late List<User> users;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      users = await ApiService().getUsers();
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index].username +
                      (users[index].role == 'admin' ? ' (admin)' : '')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(user: users[index]),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Ban User') {
                        try {
                          await ApiService().banUser(users[index].username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User has been banned!')),
                          );
                          _loadUsers();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      } else if (value == 'Unban User') {
                        try {
                          await ApiService().unbanUser(users[index].username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User has been unbanned!')),
                          );
                          _loadUsers();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      } else if (value == 'Upgrade to Admin') {
                        try {
                          await ApiService()
                              .upgradeToAdmin(users[index].username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User upgraded to Admin!')),
                          );
                          _loadUsers();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      } else if (value == 'Remove Admin Access') {
                        try {
                          await ApiService()
                              .removeAdminAccess(users[index].username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Admin access removed from user!')),
                          );
                          _loadUsers();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value:
                              users[index].banned ? 'Unban User' : 'Ban User',
                          child: Text(
                              users[index].banned ? 'Unban User' : 'Ban User'),
                        ),
                        if (users[index].role != 'admin')
                          const PopupMenuItem<String>(
                            value: 'Upgrade to Admin',
                            child: Text('Upgrade to Admin'),
                          )
                        else
                          const PopupMenuItem<String>(
                            value: 'Remove Admin Access',
                            child: Text('Remove Admin Access'),
                          ),
                      ];
                    },
                  ),
                );
              },
            ),
    );
  }
}
