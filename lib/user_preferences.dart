import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserName(String username, String fullname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('fullname', fullname);
  }

  static Future<String?> getFullName(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == username) {
      return prefs.getString('fullname');
    }
    return null;
  }
}
