import 'dart:convert';
import 'dart:convert';
import 'package:eclapp/pages/completeregistration.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _termsAgreed = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  late Future<Image> _logoImage;

  @override
  void initState() {
    super.initState();
    _logoImage = _loadLogo();
  }

  Future<Image> _loadLogo() async {
    await Future.delayed(Duration(seconds: 2));
    return Image.asset('assets/images/png.png');
  }



  void _signUp(String name, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve stored users
    Map<String, dynamic> users = prefs.containsKey('users')
        ? jsonDecode(prefs.getString('users')!) as Map<String, dynamic>
        : {};

    if (users.containsKey(email)) {
      _showError("User already exists");
      return;
    }

    users[email] = {"password": password, "name": name};
    await prefs.setString('users', jsonEncode(users));


    // Save user session details
    await AuthService.saveUserDetails(name, email);

    // Navigate to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FutureBuilder<Image>(
                  future: _logoImage, // Lazy loading the image
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Placeholder until the image is loaded
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading logo');
                    }
                    return snapshot.data!;
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Welcome to the Enerst Chemist App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.green), // Green text
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Sign up to manage appointments,\nclients, and services seamlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Your name', Icons.person_outline, nameController),
              const SizedBox(height: 20),
              _buildTextField('Enter your email', Icons.email_outlined, emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildPasswordField('Enter your password', Icons.lock_outline, passwordController, _passwordVisible, () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              }),
              const SizedBox(height: 20),
              _buildPasswordField('Confirm your password', Icons.lock_outline, confirmPasswordController, _confirmPasswordVisible, () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              }),
              const SizedBox(height: 10),
              const Text(
                'At least 8 characters\nAt least 1 number\nBoth upper and lower case letters',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _termsAgreed,
                    onChanged: (value) {
                      setState(() {
                        _termsAgreed = value!;
                      });
                    },
                    activeColor: Colors.green, // Green checkbox
                  ),
                  Expanded(
                    child: const Text(
                      'By agreeing to the terms and conditions, you are\nentering into a legally binding contract with the service provider.',
                      softWrap: true,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _termsAgreed
                      ? () {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                      _signUp(name, email, password);
                    } else {
                      _showError("All fields are required");
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green button
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(),
                      ),
                    );
                  },
                  child: const Text('Already Have an account? Login', style: TextStyle(color: Colors.green)), // Green text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green), // Green icon
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green), // Green border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade700), // Darker green focused border
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, IconData icon, TextEditingController controller, bool isVisible, VoidCallback onPressed) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green), // Green icon
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.green), // Green icon
          onPressed: onPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green), // Green border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade700), // Darker green focused border
        ),
      ),
    );
  }
}
