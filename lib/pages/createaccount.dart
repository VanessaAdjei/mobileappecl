import 'dart:convert';
import 'package:eclapp/pages/completeregistration.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cart.dart';
import 'auth_service.dart';
import 'otp.dart';

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
  final TextEditingController phoneNumberController = TextEditingController();

  late Future<Image> _logoImage;

  @override
  void initState() {
    super.initState();
    // _logoImage = _loadLogo();
  }

  // Future<void> _simulateLoading() async {
  //   await Future.delayed(Duration(seconds: 1));
  // }


  void _signUp(String name, String email, String password, String confirmPassword, String phoneNumber) async {
    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve stored users
    String? storedUsersJson = prefs.getString('users');
    Map<String, dynamic> users = storedUsersJson != null ? jsonDecode(storedUsersJson) : {};

    // Check if user exists
    if (users.containsKey(email)) {
      _showError("User already exists");
      return;
    }

    // Save user details
    users[email] = {
      "name": name,
      "password": password,
      "phoneNumber": phoneNumber
    };

    await prefs.setString('users', jsonEncode(users));

    // Generate OTP
    String otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    await prefs.setString('otp_$email', otp);

    // Simulating OTP sending
    print("OTP sent to $email: $otp");

    // Clear input fields
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneNumberController.clear();

    // Navigate to OTP verification screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpVerificationScreen(email: email, otp: otp)),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child:Image.asset(
                        'assets/images/png.png',
                        height: 200,
                        width: 200,
                )

              ),
              const Center(
                child: Text(
                  'Welcome to the Enerst Chemist App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.green),
                ),
              ),
              const Center(
                child: Text(
                  'Sign up to shop our products seamlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Your name', Icons.person_outline, nameController),
              const SizedBox(height: 20),
              _buildTextField('Enter your email', Icons.email_outlined, emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField('Enter your number', Icons.phone, phoneNumberController, keyboardType: TextInputType.number),
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
                    String confirmPassword = confirmPasswordController.text.trim();
                    String phoneNumber = phoneNumberController.text.trim();

                    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && phoneNumber.isNotEmpty) {
                      _signUp(name, email, password, confirmPassword, phoneNumber);
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
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    String confirmPassword = confirmPasswordController.text.trim();
                    String phoneNumber = phoneNumberController.text.trim();

                    bool success = await AuthService.signUp(name, email, password, phoneNumber);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Sign-up successful! Redirecting..."))
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Cart()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Email already exists. Please sign in."))
                        );
                      }
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
