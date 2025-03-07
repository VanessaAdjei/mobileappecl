import 'dart:io';
import 'package:eclapp/pages/addpayment.dart';
import 'package:eclapp/pages/changepassword.dart';
import 'package:eclapp/pages/privacypolicy.dart';
import 'package:eclapp/pages/profilescreen.dart';
import 'package:eclapp/pages/tandc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'aboutus.dart';
import 'bottomnav.dart';
import 'cart.dart';
import 'loggedout.dart';
import 'notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.toggleDarkMode}) : super(key: key);
  final void Function(bool value) toggleDarkMode;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _userName = "User";
  String _userEmail = "No email available";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _loadProfileImage();
    // });
  }


  Future<void> _loadUserData() async {
    String? name = await AuthService.getUserName();
    String? email = await AuthService.getUserEmail();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image_path');

    setState(() {
      _userName = name ?? "User";
      _userEmail = email ?? "No email available";
      _profileImagePath = imagePath;
      if (_profileImagePath != null) {
        _profileImage = File(_profileImagePath!);
      }
    });
  }

  Future<void> _pickImage() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File savedImage = await _saveImageToLocalStorage(File(image.path));
        setState(() {
          _profileImage = savedImage;
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Please allow access from settings.")),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<File> _saveImageToLocalStorage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImagePath = "${directory.path}/profile_image.png";
    final File savedImage = await imageFile.copy(savedImagePath);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImagePath);
    return savedImage;
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.toggleDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : const NetworkImage("https://via.placeholder.com/150") as ImageProvider,
                      child: _profileImage == null ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildSettingsSection("Account Settings", [
                _buildSettingOption("Edit profile", Icons.edit, ProfileScreen()),
                _buildSettingOption("Change password", Icons.key, ChangePasswordPage()),
                _buildSettingOption("Add a payment method", Icons.payment, AddPaymentPage()),
              ]),
              SizedBox(height: 10),
              _buildSettingsSection("General", [
                _buildSettingOption("Push notifications", Icons.notifications, NotificationsScreen()),
                _buildDarkModeToggle(),
              ]),
              SizedBox(height: 10),
              _buildSettingsSection("More", [
                _buildSettingOption("About us", Icons.info_outline, AboutUsScreen()),
                _buildSettingOption("Privacy policy", Icons.lock_outline, PrivacyPolicyScreen()),
                _buildSettingOption("Terms and conditions", Icons.description, TermsAndConditionsScreen()),
              ]),
              SizedBox(height: 20),
              _buildSettingOption("Logout", Icons.logout, LoggedOutScreen()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> options) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...options,
        ],
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

  Widget _buildSettingOption(String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: GoogleFonts.poppins(fontSize: 16)),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
