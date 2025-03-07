import 'dart:io';
import 'package:eclapp/pages/purchases.dart';
import 'package:eclapp/pages/settings.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cart.dart';
import 'auth_service.dart';
import 'bottomnav.dart';
import 'notifications.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String _userName = "User";
  String _userEmail = "No email available";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[400],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[700],

              ),
              child:          IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Cart(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileOption(Icons.notifications_outlined, "Notifications", () => _navigateTo(NotificationsScreen())),
              _buildProfileOption(Icons.shopping_bag_outlined, "Purchases", () => _navigateTo(PurchaseScreen())),
              _buildProfileOption(Icons.settings_outlined, "Settings", () => _navigateTo(SettingsScreen(toggleDarkMode: (bool value) {}))),
            _buildProfileOption(Icons.logout, "Logout", () {
              AuthService.signOut().then((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
              });
            }

        ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
            GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100,
                image: _profileImage != null
                    ? DecorationImage(
                  image: FileImage(_profileImage!),
                  fit: BoxFit.cover,
                )
                    : (_profileImagePath != null && File(_profileImagePath!).existsSync())
                    ? DecorationImage(
                  image: FileImage(File(_profileImagePath!)),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/150"),
                  fit: BoxFit.cover,
                ),
              ),

              child: _profileImage == null && _profileImagePath == null
                  ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    ));
  }



  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row( 
            children: [
              Icon(icon, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, // Larger font size
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }


}


