import 'dart:io';
import 'package:eclapp/pages/purchases.dart';
import 'package:eclapp/pages/settings.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cart.dart';
import 'auth_service.dart';
import 'categorylist.dart';
import 'homepage.dart';
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
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StoreSelectionPage()));
        break;
    }
  }

  String _userName = "User";
  String _userEmail = "No email available";
  String? _profileImagePath;


  @override
  void initState() {
    super.initState();
    _loadUserData();

  }


  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(AuthService.userNameKey);
    String? email = prefs.getString(AuthService.userEmailKey);
    String? savedImagePath = prefs.getString('profile_image_path');

    setState(() {
      _userName = name ?? "User";
      _userEmail = email ?? "No email available";
      _profileImagePath = savedImagePath;
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


  File? _profileImage;
  final ImagePicker _picker = ImagePicker();




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade600,
          title: Image.asset('assets/images/png.png', height: 50),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => _navigateTo(const Cart()),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green.shade700,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          elevation: 8.0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_city_sharp),
              label: 'Stores',
            ),
          ],
        ),
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
                    image: _profileImagePath != null
                        ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _profileImagePath == null ? const Icon(Icons.person, size: 45, color: Colors.green) : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.green[800])),
                    const SizedBox(height: 6),
                    Text(_userEmail, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[600]), // Slightly larger arrow
            ],
          ),
        ),
      ),
    );
  }


}


