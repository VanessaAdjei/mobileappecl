import 'package:eclapp/pages/addpayment.dart';
import 'package:eclapp/pages/changepassword.dart';
import 'package:eclapp/pages/privacypolicy.dart';
import 'package:eclapp/pages/profilescreen.dart';
import 'package:eclapp/pages/tandc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CartItems.dart';
import 'aboutus.dart';
import 'cart.dart';
import 'loggedout.dart';
import 'notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required void Function(bool value) toggleDarkMode}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false; // Track the dark mode status

  // Toggle the dark mode
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: SizedBox(
          height: 75, // Your desired height
          width: 150, // Your desired width
          child: Image.asset('assets/images/png.png'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const Cart(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile_image.png'),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'jdoe@gmail.com',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Account Settings Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildSettingOption(context, "Edit profile", Icons.edit, ProfileScreen()),
                    _buildSettingOption(context, "Change password", Icons.key, ChangePasswordPage()),
                    _buildSettingOption(context, "Add a payment method", Icons.payment, AddPaymentPage()),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // General Settings Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align the children to the start (left)
                  mainAxisAlignment: MainAxisAlignment.start, // Align the children at the start (top)
                  children: [
                    Text(
                      'General',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Align the 'Push notifications' option to the start (left) with a little spacing
                    Align(
                      alignment: Alignment.centerLeft, // Align this item to the left
                      child: _buildSettingOption(
                        context,
                        "Push notifications",
                        Icons.notifications,
                        NotificationsScreen(),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.centerLeft, // Align this item to the left
                    //   child: _buildDarkModeToggle(),
                    // ),
                  ],
                ),
              ),


              SizedBox(height: 20),
              // More Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildSettingOption(context, "About us", Icons.info_outline, AboutUsScreen()),
                    _buildSettingOption(context, "Privacy policy", Icons.lock_outline, PrivacyPolicyScreen()),
                    _buildSettingOption(context, "Terms and conditions", Icons.description, TermsAndConditionsScreen()),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Logout Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: _buildSettingOption(context, "Logout", Icons.logout, LoggedOutScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return ListTile(
      leading: Icon(Icons.brightness_4),
      title: Text("Dark Mode"),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: _toggleDarkMode, 
      ),
    );
  }


  Widget _buildSettingOption(BuildContext context, String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}




