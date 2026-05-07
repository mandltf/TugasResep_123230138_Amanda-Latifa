import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    String? existingPassword = prefs.getString('user_$username');
    if (existingPassword != null) {
      return false; 
    }
    
    await prefs.setString('user_$username', password);
    return true;
  }
  
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    String? savedPassword = prefs.getString('user_$username');
    
    if (savedPassword != null && savedPassword == password) {
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      return true;
    }
    return false;
  }
  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
  
  static Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
}