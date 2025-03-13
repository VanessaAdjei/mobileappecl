import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl = "http://eclcommerce.test/api";

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


  // Sign up a new user
  static Future<bool> signUp(String name, String email, String password, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone_number": phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Successfully registered
      } else {
        print("Signup failed: ${response.body}");
        print(response.body);
        return false; // User already exists or another issue
      }
    } catch (error) {
      print("Error during signup: $error");
      return false;
    }
  }



  static Future<bool> signIn(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(usersKey);
    Map<String, dynamic> users = usersJson != null ? json.decode(usersJson) : {};

    email = email.trim().toLowerCase();
    String hashedPassword = hashPassword(password);
    print("Attempting Sign-In for Email: $email");

    if (!users.containsKey(email)) {
      print("Email not found.");
      return false;
    }

    if (users[email]["password"] != hashedPassword) {
      print("Incorrect password.");
      return false;
    }

    print("Sign-In Successful!");
    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(loggedInUserKey, email);
    return true;
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
    print("Logged-in User Email: $email"); // Debug log

    if (email != null) {
      String? usersData = prefs.getString(usersKey);
      print("Users Data: $usersData"); // Debug log

      if (usersData != null) {
        Map<String, Map<String, String>> users =
        Map<String, Map<String, String>>.from(json.decode(usersData));
        String? phoneNumber = users[email]?['phoneNumber'];
        print("Retrieved Phone Number: $phoneNumber"); // Debug log
        if (phoneNumber != null) {
          return phoneNumber;
        }
      }
    }
    return prefs.getString(userPhoneNumberKey);
  }

  static Future<void> debugPrintUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString(usersKey);
    print("DEBUG: Users Data: $usersData");
  }


  static Future<bool> validateCurrentPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString(loggedInUserKey);  // Updated key
    if (userEmail != null) {
      String? storedUserJson = prefs.getString(usersKey);
      if (storedUserJson != null) {
        Map<String, dynamic> users = Map<String, dynamic>.from(jsonDecode(storedUserJson));
        if (users.containsKey(userEmail)) {
          String storedHash = users[userEmail]['password'];
          String inputHash = hashPassword(password);
          print("Entered Hashed Password: $inputHash");
          print("Stored Hashed Password: $storedHash");
          return storedHash == inputHash;
        }
      }
    }
    return false;
  }

  static Future<bool> updatePassword(String oldPassword, String newPassword) async {
    if (!(await validateCurrentPassword(oldPassword))) {
      print("Old password does not match.");
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString(loggedInUserKey);

    if (userEmail != null) {
      String? storedUserJson = prefs.getString(usersKey);
      if (storedUserJson != null) {
        Map<String, dynamic> users = jsonDecode(storedUserJson);
        users[userEmail]['password'] = hashPassword(newPassword);
        await prefs.setString(usersKey, jsonEncode(users));
        print("Password updated for $userEmail");
        return true;
      }
    }

    print("Password update failed.");
    return false;
  }








}


