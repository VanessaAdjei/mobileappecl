import 'dart:convert';
import 'package:eclapp/pages/Cart.dart';
import 'package:flutter/material.dart';
import 'package:eclapp/pages/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createaccount.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _signIn(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersJson = prefs.getString('users');

      if (usersJson == null) {
        _showError("No users found");
        return;
      }

      Map<String, dynamic> users = jsonDecode(usersJson);

      // Print all users and passwords
      // users.forEach((key, value) {
      //   print("User: $key, Password: ${value['password']}");
      // });

      if (!users.containsKey(email) || users[email]["password"] != password) {
        _showError("Invalid email or password");
        return;
      }

      await prefs.setBool('isLoggedIn', true);
      await AuthService.saveUserDetails(users[email]["name"], email, users[email]["phone"] ?? "");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Cart()),
      );
    } catch (e) {
      _showError("An error occurred during sign-in.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 250),
                    Text(
                      "Let's Get You\nSigned In",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),  // <-- Added spacing
                    Card(
                      color: Colors.transparent,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.white70,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email, color: Colors.green),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                      if (formKey.currentState!.validate()) {
                                        _signIn(emailController.text, passwordController.text);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => {},
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Create an account',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}