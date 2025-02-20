import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String usersKey = "users";  // Key to store multiple users
  static const String loggedInUserKey = "loggedInUser"; // Key for active session
  static const String isLoggedInKey = "isLoggedIn"; // Key for login status
  static const String userNameKey = "userName"; // Key for storing user name
  static const String userEmailKey = "userEmail"; // Key for storing user email

  /// **Sign Up a New User**
  static Future<bool> signUp(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve existing users or initialize an empty map
    String? usersData = prefs.getString(usersKey);
    Map<String, Map<String, String>> users = usersData != null
        ? Map<String, Map<String, String>>.from(json.decode(usersData))
        : {};

    // Check if user already exists
    if (users.containsKey(email)) {
      return false; // User already exists
    }

    // Add new user
    users[email] = {"name": name, "email": email, "password": password};
    await prefs.setString(usersKey, json.encode(users));

    return true;
  }

  /// **Sign In an Existing User**
  static Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve stored users
    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return false; // No users exist

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    // Validate user
    if (users.containsKey(email) && users[email]!['password'] == password) {
      // Save the logged-in user session
      await prefs.setString(loggedInUserKey, json.encode(users[email]));
      await prefs.setBool(isLoggedInKey, true); // ✅ Store login state
      await saveUserDetails(users[email]!['name']!, email); // ✅ Save name & email
      return true;
    }

    return false; // Invalid credentials
  }

  /// **Save User Details (Name & Email)**
  static Future<void> saveUserDetails(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, name);
    await prefs.setString(userEmailKey, email);
  }

  /// **Get Current Logged-in User's Data**
  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(loggedInUserKey);

    return userData != null ? Map<String, String>.from(json.decode(userData)) : null;
  }

  /// **Sign Out**
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loggedInUserKey); // Remove current user session
    await prefs.setBool(isLoggedInKey, false); // ✅ Ensure user is logged out
    await prefs.remove(userNameKey); // ✅ Remove stored name
    await prefs.remove(userEmailKey); // ✅ Remove stored email
  }

  /// **Check Login Status**
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  /// **Get User Name**
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  /// **Get User Email**
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }
}
