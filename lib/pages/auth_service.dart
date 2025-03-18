import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://eclcommerce.ernestchemists.com.gh/api";
  static const String usersKey = "users";
  static const String loggedInUserKey = "loggedInUser";
  static const String isLoggedInKey = "isLoggedIn";
  static const String userNameKey = "userName";
  static const String userEmailKey = "userEmail";
  static const String userPhoneNumberKey = "userPhoneNumber";
  static const String authTokenKey = 'authToken';
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );



  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // static Future<void> clearAllUsers() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(usersKey);
  //   await prefs.remove(loggedInUserKey);
  //   await prefs.remove(isLoggedInKey);
  //   await prefs.remove(userNameKey);
  //   await prefs.remove(userEmailKey);
  //   await prefs.remove(userPhoneNumberKey);
  // }






  // Sign up  user
  static Future<bool> signUp(String name, String email, String password, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": hashPassword(password),
          "phone": phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Signup failed: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Error during signup: $error");
      return false;
    }
  }



  // OTP
  static Future<bool> verifyOTP(String email, String otp) async {
    final url = Uri.parse('https://eclcommerce.ernestchemists.com.gh/api/otp-verification');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        print("OTP Verified Successfully!");
        return true;
      } else {
        print("OTP Verification Failed: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Error during OTP verification: $error");
      return false;
    }
  }


  // Sign in a  user
  static Future<bool> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );

      print("API Response Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("Login Failed: ${response.body}");
        return false;
      }

      // Decode response safely
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print("Error decoding JSON response: $e");
        return false;
      }

      // Validate access token
      if (!responseData.containsKey('access_token')) {
        print("Login Failed: No access token found");
        return false;
      }

      String authToken = responseData['access_token'];
      Map<String, dynamic>? user = responseData['user'];

      if (user == null) {
        print("Login Failed: User data missing");
        return false;
      }

      String userName = user['name']?.toString() ?? "User";
      String userEmail = user['email'] ?? "No email available";
      String userPhone = user['phone'] ?? "No phone available";

      // Securely store authentication token
      try {
        await secureStorage.write(key: authTokenKey, value: authToken);
      } catch (e) {
        print("Error storing auth token: $e");
        return false;
      }

      // Store user details
      await saveUserDetails(userName, userEmail, userPhone);

      // Debug: Confirm stored data
      print("✅ Sign-In Successful!");
      print("👤 Name: $userName");
      print("📧 Email: $userEmail");

      return true;
    } catch (e) {
      print("AuthService Error during sign-in: $e");
      return false;
    }
  }


  static Future<void> saveUserDetails(String name, String email, String phone) async {
    await secureStorage.write(key: 'userName', value: name);
    await secureStorage.write(key: 'userEmail', value: email);
    await secureStorage.write(key: 'userPhone', value: phone);
  }




  static Future<String?> getUserName() async {
    try {
      String? userName = await secureStorage.read(key: userNameKey);
      print("Retrieved User Name: $userName");

      return userName?.isNotEmpty == true ? userName : "User";
    } catch (e) {
      print("Error retrieving user name: $e");
      return "User";
    }
  }






  static Future<void> saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image');
  }



  static Future<Map<String, String>?> getCurrentUser() async {
    try {
      String? email = await secureStorage.read(key: loggedInUserKey);
      if (email == null) {
        print("No logged-in user found.");
        return null;
      }

      String? usersData = await secureStorage.read(key: usersKey);
      if (usersData == null) {
        print("No users data found.");
        return null;
      }

      Map<String, Map<String, String>> users =
      Map<String, Map<String, String>>.from(json.decode(usersData));

      print("Current User: ${users[email]}");
      return users[email];
    } catch (e) {
      print("Error retrieving user: $e");
      return null;
    }
  }



  static Future<void> signOut() async {
    try {
      await secureStorage.delete(key: loggedInUserKey);
      await secureStorage.delete(key: userNameKey);
      await secureStorage.delete(key: userEmailKey);
      await secureStorage.delete(key: userPhoneNumberKey);

      print("User successfully signed out.");
    } catch (e) {
      print("Error during sign-out: $e");
    }
  }



  static Future<bool> isLoggedIn() async {
    try {
      String? authToken = await secureStorage.read(key: authTokenKey);
      print("🔍 Checking login status... Token: $authToken");

      if (authToken == null || authToken.isEmpty) {
        print("Invalid or missing token.");
        await logout();
        return false;
      }

      print("✅ Token is valid.");
      return true;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }



  static Future<void> saveToken(String token) async {
    await secureStorage.write(key: authTokenKey, value: token);
    print("Token saved: $token");
  }


  static bool isValidJwt(String token) {
    final parts = token.split('.');
    return parts.length == 3;
  }




  static Future<void> logout() async {
    await secureStorage.deleteAll();
    print("User logged out.");
  }

  /// Checks if a user is signed up based on email
  static Future<bool> isUserSignedUp(String email) async {
    try {
      String? usersData = await secureStorage.read(key: usersKey);
      if (usersData == null) return false;

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



  /// Retrieves the stored user email
  static Future<String?> getUserEmail() async {
    try {
      return await secureStorage.read(key: userEmailKey);
    } catch (e) {
      print("❌ Error retrieving user email: $e");
      return null;
    }
  }

  /// Retrieves the stored phone number
  static Future<String?> getUserPhoneNumber() async {
    try {
      return await secureStorage.read(key: userPhoneNumberKey);
    } catch (e) {
      print("❌ Error retrieving phone number: $e");
      return null;
    }
  }

  /// Debug method to print stored user data
  static Future<void> debugPrintUserData() async {
    try {
      String? usersData = await secureStorage.read(key: usersKey);
      print("DEBUG: Users Data: $usersData");
    } catch (e) {
      print("Error retrieving user data for debugging: $e");
    }
  }

  /// Validates if the given password matches the stored password
  static Future<bool> validateCurrentPassword(String password) async {
    try {
      String? userEmail = await secureStorage.read(key: loggedInUserKey);
      if (userEmail != null) {
        String? storedUserJson = await secureStorage.read(key: usersKey);
        if (storedUserJson != null) {
          Map<String, dynamic> users = jsonDecode(storedUserJson);

          if (users.containsKey(userEmail)) {
            String storedHash = users[userEmail]['password'];
            String inputHash = hashPassword(password);

            print("Entered Hashed Password: $inputHash");
            print("Stored Hashed Password: $storedHash");

            return storedHash == inputHash;
          }
        }
      }
      print("User not found or no password stored.");
      return false;
    } catch (e) {
      print("Error validating password: $e");
      return false;
    }
  }

  /// Updates the user's password
  static Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      if (!(await validateCurrentPassword(oldPassword))) {
        print("Old password does not match.");
        return false;
      }

      String? userEmail = await secureStorage.read(key: loggedInUserKey);
      if (userEmail != null) {
        String? storedUserJson = await secureStorage.read(key: usersKey);
        if (storedUserJson != null) {
          Map<String, dynamic> users = jsonDecode(storedUserJson);
          users[userEmail]['password'] = hashPassword(newPassword);

          await secureStorage.write(key: usersKey, value: jsonEncode(users));
          print("Password updated successfully for $userEmail");
          return true;
        }
      }

      print("Password update failed.");
      return false;
    } catch (e) {
      print("Error updating password: $e");
      return false;
    }
  }


  static Future<void> saveUserName(String username) async {
    await secureStorage.write(key: userNameKey, value: username);
    print("Username saved: $username");
  }







}


