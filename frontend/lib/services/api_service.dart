import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/admin.dart';
import 'package:frontend/models/vote.dart';
import 'package:frontend/models/option.dart';
import 'package:frontend/models/poll.dart';

class ApiService {
  final String _apiUrl = 'http://10.0.2.2:3000/';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User?> registerUser(
    String firstName,
    String lastName,
    String email,
    String username,
    String phoneNumber,
    String password,
  ) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse(_apiUrl + 'user/register'),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'username': username,
          'phone': phoneNumber,
          'password': password,
        }),
        headers: headers,
      );

      if (response.statusCode == 201) {
        await saveToken(jsonDecode(response.body)['token']);
        return User.fromJson(jsonDecode(response.body)['user']);
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Unknown error';
        throw Exception('Error from server: $message');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('ClientException: ${e.message}');
      } else {
        throw Exception('Unexpected error: $e');
      }
    }
  }

  Future<User?> loginUser(String email, String password) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse(_apiUrl + 'user/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await saveToken(jsonDecode(response.body)['token']);
        return User.fromJson(jsonDecode(response.body)['user']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      print('Exception during login: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  Future<Admin?> registerAdmin(String username, String password) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/register'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: headers,
    );
    if (response.statusCode == 201) {
      await saveToken(jsonDecode(response.body)['token']);
      return Admin.fromJson(jsonDecode(response.body)['admin']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Admin?> loginAdmin(String username, String password) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: headers,
    );
    if (response.statusCode == 200) {
      await saveToken(jsonDecode(response.body)['token']);
      return Admin.fromJson(jsonDecode(response.body)['admin']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Poll>> getPolls() async {
    final String? token = await getToken();
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(
      Uri.parse(_apiUrl + 'polls/fetch'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> polls = jsonDecode(response.body)['polls'];
      return polls.map((poll) => Poll.fromJson(poll)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> castVote(int pollId, int optionId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final requestUrl = _apiUrl + 'user/$pollId/vote';
    print('Sending request to: $requestUrl');
    print('Headers: $headers');
    print('Body: ${jsonEncode({'optionId': optionId})}');

    final response = await http.post(
      Uri.parse(requestUrl),
      body: jsonEncode({'optionId': optionId}),
      headers: headers,
    );

    print('Received response with status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<bool> createPoll(String question, List<String> options) async {
    final String? token = await getToken();

    if (token == null) {
      return false;
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/polls'),
      body: jsonEncode({
        'question': question,
        'options': options.map((option) => {'description': option}).toList(),
      }),
      headers: headers,
    );

    print('Server Response: ${response.statusCode} ${response.body}');

    if (response.statusCode != 200) {
      return false;
    }

    return true;
  }

  Future<void> updatePoll(int pollId, String newTitle) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse(_apiUrl + 'admin/polls/$pollId'),
      body: jsonEncode({'title': newTitle}),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> deactivatePoll(int pollId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse(_apiUrl + 'admin/polls/$pollId/deactivate'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> activatePoll(int pollId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse(_apiUrl + 'admin/polls/$pollId/activate'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> deletePoll(int pollId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse(_apiUrl + 'admin/polls/$pollId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Option>> getPollOptions(int pollId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(_apiUrl + 'polls/$pollId/options'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> options = jsonDecode(response.body)['options'];
      return options.map((option) => Option.fromJson(option)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Vote>> getUserVotes(int userId) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse(_apiUrl + 'user/votes'),
        headers: headers,
      );
      print('Response status code: ${response.statusCode}'); // Debugging line
      print('Response body: ${response.body}'); // Debugging line
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['user_votes'] == null) {
          print('user_votes is null'); // Debugging line
          throw Exception('User votes are not found in response');
        }
        final List<dynamic> votes = body['user_votes'];
        return votes.map((vote) => Vote.fromJson(vote)).toList();
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print('Error getting user votes: $errorMessage'); // Debugging line
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Exception in getUserVotes: $e'); // Debugging line
      throw Exception(e.toString());
    }
  }

  Future<List<Poll>> fetchAllPolls() async {
    try {
      final String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(_apiUrl + 'user/fetch'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic>? pollsJson = jsonDecode(response.body)['polls'];
        if (pollsJson == null) {
          throw Exception('Polls is null');
        }

        print('Polls JSON: $pollsJson');

        return pollsJson.map((json) => Poll.fromJson(json)).toList();
      } else {
        print('Error: status code ${response.statusCode}');
        print('Response body: ${response.body}');
        String? errorMessage = jsonDecode(response.body)['message'];
        if (errorMessage == null) {
          errorMessage = 'Server error with no message';
        }
        throw Exception(errorMessage);
      }
    } catch (e, stacktrace) {
      print('Exception during fetchUserPolls: $e');
      print('Stack trace: $stacktrace');
      rethrow;
    }
  }

  Future<void> upgradeToAdmin(String username) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/upgrade'),
      body: jsonEncode({'username': username}),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> banUser(String username) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/ban'),
      body: jsonEncode({'username': username}),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> unbanUser(String username) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/unban'),
      body: jsonEncode({'username': username}),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> removeAdminAccess(String username) async {
    final String? token = await getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(_apiUrl + 'admin/removeAdmin'),
      body: jsonEncode({'username': username}),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(_apiUrl + 'user/users'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users from API');
    }
  }
}
