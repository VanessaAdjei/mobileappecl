import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cart.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditinguserName = false;
  bool _isEditinguserEmail = false;
  bool _isEditingPhoneNumber = false;

  String _userName = "User";
  String _userEmail = "No email available";
  String _phoneNumber = "";
  String? _profileImagePath;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: _userName);
    _userEmailController = TextEditingController(text: _userEmail);
    _phoneNumberController = TextEditingController(text: _phoneNumber);
    _loadUserData();
    _loadProfileImage();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _pickImage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Please allow access from settings.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File savedImage = await _saveImageToLocalStorage(File(image.path));
      setState(() {
        _profileImage = savedImage;
        _profileImagePath = savedImage.path;
      });
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

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image_path');
    if (savedImagePath != null && await File(savedImagePath).exists()) {
      setState(() {
        _profileImage = File(savedImagePath);
        _profileImagePath = savedImagePath;
      });
    } else {
      print("Image file not found or path is null!");
    }
  }


  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(AuthService.userNameKey) ?? "User";
    String? email = prefs.getString(AuthService.userEmailKey) ?? "No email available";
    String? phoneNumber = prefs.getString(AuthService.userPhoneNumberKey) ?? "";
    setState(() {
      _userName = name;
      _userEmail = email;
      _phoneNumber = phoneNumber;
      _userNameController.text = _userName;
      _userEmailController.text = _userEmail;
      _phoneNumberController.text = _phoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
          CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildEditableField("Full Name", _userNameController, _isEditinguserName),
            const SizedBox(height: 20),
            _buildEditableField("Email", _userEmailController, _isEditinguserEmail),
            const SizedBox(height: 20),
            _buildEditableField("Phone Number", _phoneNumberController, _isEditingPhoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: !isEditing,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.green),
                onPressed: () async {
                  if (isEditing) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (label == "Full Name") {
                      _userName = controller.text;
                      await prefs.setString(AuthService.userNameKey, _userName);
                    } else if (label == "Email") {
                      _userEmail = controller.text;
                      await prefs.setString(AuthService.userEmailKey, _userEmail);
                    } else if (label == "Phone Number") {
                      _phoneNumber = controller.text;
                      await prefs.setString(AuthService.userPhoneNumberKey, _phoneNumber);
                    }
                  }
                  setState(() {
                    if (label == "Full Name") {
                      _isEditinguserName = !_isEditinguserName;
                    } else if (label == "Email") {
                      _isEditinguserEmail = !_isEditinguserEmail;
                    } else if (label == "Phone Number") {
                      _isEditingPhoneNumber = !_isEditingPhoneNumber;
                    }
                  });
                }
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
