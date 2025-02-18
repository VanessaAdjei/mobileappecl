import 'package:eclapp/pages/completeregistration.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _termsAgreed = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late Future<Image> _logoImage;

  @override
  void initState() {
    super.initState();
    _logoImage = _loadLogo();
  }

  Future<Image> _loadLogo() async {
    await Future.delayed(Duration(seconds: 2));  // Simulate network or asset loading delay
    return Image.asset('assets/images/png.png');
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
              _buildTextField('Your name', Icons.person_outline, _nameController),
              const SizedBox(height: 20),
              _buildTextField('Enter your email', Icons.email_outlined, _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildPasswordField('Enter your password', Icons.lock_outline, _passwordController, _passwordVisible, () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              }),
              const SizedBox(height: 20),
              _buildPasswordField('Confirm your password', Icons.lock_outline, _confirmPasswordController, _confirmPasswordVisible, () {
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
                    _signUp();
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

  void _signUp() async {
    // Validate the inputs
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    // Store user information locally (using SharedPreferences)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_name', _nameController.text);
    prefs.setString('user_email', _emailController.text);
    prefs.setString('user_password', _passwordController.text);

    // Navigate to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
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
