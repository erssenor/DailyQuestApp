import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  final String username;
  final String password;

  // Starting level and XP
  int currXp = 0;
  int level = 1;

  User(this.username, this.password);

  void addXp(int xp) {
    currXp += xp;

    // Level up for every 100 XP per level, handling overflow XP
    while (currXp >= level * 100) {
      currXp -= level * 100;  // Carry forward overflow XP
      level++;
    }

    notifyListeners();
  }

  // Reading from JSON within a database
  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      json['username'] as String,
      json['password'] as String,
    );
    user.currXp = json['currXp'] as int? ?? 0;
    user.level = json['level'] as int? ?? 1;
    return user;
  }

  // Writing to JSON within a database
  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'currXp': currXp,
    'level': level
  };


  
}