import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'ProductModel.dart';

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

  List<Product> products = [];
  List<Product> filteredProducts = [];

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }


  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://eclcommerce.ernestchemists.com.gh/api/get-all-products'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'];

        final products = dataList.map<Product>((item) {
          final productData = item['product'] as Map<String, dynamic>;
          return Product(
            id: productData['id'] ?? 0,
            name: productData['name'] ?? 'No name',
            description: productData['description'] ?? '',
            urlName: productData['url_name'] ?? '',
            status: productData['status'] ?? '',
            price: (item['price'] ?? 0).toString(),
            thumbnail: productData['thumbnail'] ?? '',
            quantity: productData['quantity'] ?? '',
            category: productData['category'] ?? '',
          );
        }).toList();

        return products;
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }


  static Future<Product> fetchProductDetails(String urlName) async {
    try {
      final response = await http.get(
        Uri.parse('https://eclcommerce.ernestchemists.com.gh/api/product-details/$urlName'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final productData = data['product'];

        return Product(
          id: productData['id'] ?? 0,
          name: productData['name'] ?? 'No name',
          description: productData['description'] ?? '',
          urlName: productData['url_name'] ?? '',
          status: productData['status'] ?? '',
          category: productData['category'] ?? '',
          price: (productData['price'] ?? 0).toDouble(),
          thumbnail: productData['thumbnail'] ?? '',
          quantity: productData['qty_in_stock'] ?? 0,
        );
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Could not load product');
    }
  }


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
        print("API Raw Response: ${response.body}");

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

  static Future<String?> getBearerToken() async {
    final token = await secureStorage.read(key: authTokenKey);
    return token != null ? 'Bearer $token' : null;
  }


  // Sign in a  user
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      debugPrint("Attempting login with email: $email");


      var response = await _attemptLogin(email, password);


      if (response.statusCode != 200) {
        debugPrint("Trying with hashed password...");
        response = await _attemptLogin(email, hashPassword(password));
      }

      final responseData = jsonDecode(response.body);
      debugPrint("API Response: ${response.statusCode} - $responseData");

      if (response.statusCode == 200) {
        final token = responseData['access_token'] as String?;
        if (token == null) {
          return {'success': false, 'message': 'No access token received'};
        }

        await secureStorage.write(key: authTokenKey, value: token);
        final user = responseData['user'] as Map<String, dynamic>;
        await _storeUserData(user);

        return {
          'success': true,
          'token': 'Bearer $token',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Login failed (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  static Future<http.Response> _attemptLogin(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<void> _storeUserData(Map<String, dynamic> user) async {
    await secureStorage.write(key: 'user_id', value: user['id'].toString());
    await secureStorage.write(key: 'user_name', value: user['name']);
    await secureStorage.write(key: 'user_email', value: user['email']);
    if (user['phone'] != null) {
      await secureStorage.write(key: 'user_phone', value: user['phone']);
    }
  }

  // Add this method to your existing AuthService
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getBearerToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token ?? '',
    };
  }



   Future<void> saveUserDetails(String name, String email, String phone) async {
    await secureStorage.write(key: 'userName', value: name);
    await secureStorage.write(key: 'userEmail', value: email);
    await secureStorage.write(key: 'userPhone', value: phone);
  }




   Future<String?> getUserName() async {
    try {
      String? userName = await secureStorage.read(key: userNameKey);
      print("Retrieved User Name: $userName");

      return userName?.isNotEmpty == true ? userName : "User";
    } catch (e) {
      print("Error retrieving user name: $e");
      return "User";
    }
  }






   Future<void> saveProfileImage(String imagePath) async {
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


