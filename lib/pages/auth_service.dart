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


  static Future<bool> signUp(String name, String email, String password, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString(usersKey);
    Map<String, Map<String, String>> users = usersData != null
        ? Map<String, Map<String, String>>.from(json.decode(usersData))
        : {};

    if (users.containsKey(email)) {
      return false;
    }

    String hashedPassword = hashPassword(password);

    users[email] = {
      "name": name,
      "email": email,
      "password": hashedPassword,
      "phoneNumber": phoneNumber
    };
    await prefs.setString(usersKey, json.encode(users));
    await prefs.setString(userPhoneNumberKey, phoneNumber);
    await prefs.setString(loggedInUserKey, email);
    await prefs.setBool(isLoggedInKey, true);
    await saveUserDetails(name, email, phoneNumber);

    return true;
  }

  static Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return false;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    String hashedPassword = hashPassword(password);

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
    await prefs.setString(userPhoneNumberKey, phoneNumber);

    print("Saved Data -> Name: $name, Email: $email, Phone: $phoneNumber");
  }

  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(loggedInUserKey);
    if (email == null) return null;

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
      Map<String, dynamic> rawUsers = json.decode(usersData);
      Map<String, Map<String, String>> users = rawUsers.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
      );

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

    print("DEBUG: Email -> $email, Users Data -> $usersData");


    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));
    return users[email]?['phoneNumber'];

  }


  static Future<void> debugPrintUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString(usersKey);
    print("DEBUG: Users Data: $usersData");
  }

  static Future<bool> validateCurrentPassword(String currentPassword) async {
    final prefs = await SharedPreferences.getInstance();
    String? loggedInUser = prefs.getString(loggedInUserKey);

    if (loggedInUser == null) return false;

    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return false;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    if (users.containsKey(loggedInUser)) {
      String hashedPassword = hashPassword(currentPassword);
      return users[loggedInUser]!['password'] == hashedPassword;
    }
    return false;
  }

  static Future<bool> updatePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    String? loggedInUser = prefs.getString(loggedInUserKey);

    if (loggedInUser == null) return false;

    String? usersData = prefs.getString(usersKey);
    if (usersData == null) return false;

    Map<String, Map<String, String>> users =
    Map<String, Map<String, String>>.from(json.decode(usersData));

    if (users.containsKey(loggedInUser)) {
      String hashedNewPassword = hashPassword(newPassword);
      users[loggedInUser]!['password'] = hashedNewPassword;
      await prefs.setString(usersKey, json.encode(users));
      return true;
    }
    return false;
  }


}
