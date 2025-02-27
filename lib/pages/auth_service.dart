import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static const String usersKey = "users";
  static const String loggedInUserKey = "loggedInUser";
  static const String isLoggedInKey = "isLoggedIn";
  static const String userNameKey = "userName";
  static const String userEmailKey = "userEmail";
  static const String userPhoneNumberKey = "userPhoneNumber";


  // **Hash password using SHA-256**
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }



  static Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(usersKey);
    await prefs.remove(loggedInUserKey);
    await prefs.remove(isLoggedInKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userPhoneNumberKey);
  }


  /// **Sign Up a New User and Automatically Sign In**
  static Future<bool> signUp(String name, String email, String password, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve existing users or initialize an empty map
    String? usersData = prefs.getString(usersKey);
    Map<String, Map<String, String>> users = usersData != null
        ? Map<String, Map<String, String>>.from(json.decode(usersData))
        : {};

    // Check if user already exists
    if (users.containsKey(email)) {
      return false;  // User already exists
    }

    // Hash the password before storing it
    String hashedPassword = hashPassword(password);

    // Add new user
    users[email] = {
      "name": name,
      "email": email,
      "password": hashedPassword,
      "phoneNumber": phoneNumber
    };
    await prefs.setString(usersKey, json.encode(users));

    // Automatically log in the user after successful sign-up
    await prefs.setString(loggedInUserKey, email);
    await prefs.setBool(isLoggedInKey, true);
    await saveUserDetails(name, email, phoneNumber);

    return true;
  }

  static Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve stored users
    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return false;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    String hashedPassword = hashPassword(password);

    // Validate user
    if (users.containsKey(email) && users[email]!['password'] == hashedPassword) {
      await prefs.setString(loggedInUserKey, email);
      await prefs.setBool(isLoggedInKey, true);
      String phoneNumber = users[email]!['phoneNumber'] ?? "";

      await saveUserDetails(users[email]!['name']!, email, phoneNumber);
      return true;
    }
    return false;
  }


  static Future<void> saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image');
  }

  static Future<void> saveUserDetails(String name, String email, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, name);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userPhoneNumberKey, phoneNumber);

    print("Saved Data -> Name: $name, Email: $email, Phone: $phoneNumber");
  }

  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(loggedInUserKey);
    if (email == null) return null;

    // Retrieve users data
    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return null;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    return users[email];
  }



  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loggedInUserKey);
    await prefs.setBool(isLoggedInKey, false);
    await prefs.remove(userNameKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userPhoneNumberKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool(isLoggedInKey) ?? false;
    String? loggedInUser = prefs.getString(loggedInUserKey);

    return loggedIn && loggedInUser != null;
  }



  static Future<bool> isUserSignedUp(String email) async {
    final prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString(usersKey);

    if (usersData == null) return false;

    try {
      // Decode as Map<String, Map<String, String>>
      Map<String, dynamic> rawUsers = json.decode(usersData);
      Map<String, Map<String, String>> users = rawUsers.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
      );

      // Ensure the user exists
      return users.containsKey(email);
    } catch (e) {
      print("Error decoding users data: $e");
      return false;
    }
  }




  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }


  static Future<String?> getUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(loggedInUserKey);
    if (email == null) return null;

    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return null;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    return users[email]?['phoneNumber']; // Fetch from stored users
  }


  static Future<void> debugPrintUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString(usersKey);
    print("DEBUG: Users Data: $usersData");
  }

}
