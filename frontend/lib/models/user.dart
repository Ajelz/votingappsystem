class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phoneNumber;
  final String role;
  final String avatarUrl;
  final bool banned;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.avatarUrl,
    required this.banned,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
      banned: json['banned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'role': role,
      'avatar_url': avatarUrl,
      'banned': banned,
    };
  }
}
