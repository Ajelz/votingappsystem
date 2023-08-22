import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/vote.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/views/create_poll_page.dart';
import 'package:frontend/views/login_page.dart';
import 'package:frontend/views/my_votes_page.dart';
import 'package:frontend/views/poll_list.dart';
import 'package:frontend/views/profile_page.dart';
import 'package:frontend/views/admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatelessWidget {
  final User user;
  final List<int> votedPollIds;
  final Function(int pollId) onVoteCast;

  HomeTab({
    required this.user,
    required this.votedPollIds,
    required this.onVoteCast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Logout') {
                _logout(context);
              } else if (result == 'Create a Poll') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreatePollPage(user: user)),
                );
              } else if (result == 'Admin Panel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
              if (user.role == 'admin') ...[
                const PopupMenuItem<String>(
                  value: 'Create a Poll',
                  child: Text('Create a Poll'),
                ),
                const PopupMenuItem<String>(
                  value: 'Admin Panel',
                  child: Text('Admin Panel'),
                ),
              ]
            ],
          ),
        ],
      ),
      body: PollList(
        votedPollIds: votedPollIds,
        onVoteCast: onVoteCast,
        role: user.role,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  List<int> votedPollIds = [];

  Future<void> _fetchVotedPollIds() async {
    if (widget.user.id != null) {
      try {
        List<Vote> votes = await ApiService().getUserVotes(widget.user.id!);
        setState(() {
          votedPollIds = votes.map((vote) => vote.poll.id).toList();
        });
      } catch (e) {
        print("Exception in getUserVotes: $e");
      }
    }
  }

  void refreshPollsAndUpdateVotedPollIds(int pollId) {
    _fetchVotedPollIds();
    setState(() {
      votedPollIds.add(pollId);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchVotedPollIds();
  }

  @override
  Widget build(BuildContext context) {
    final _pages = [
      MyVotesPage(user: widget.user),
      HomeTab(
          user: widget.user,
          votedPollIds: votedPollIds,
          onVoteCast: refreshPollsAndUpdateVotedPollIds),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Votes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
