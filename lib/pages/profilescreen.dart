import 'package:eclapp/pages/changepassword.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingFullName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhoneNumber = false;

  String _fullName = "John Doe";
  String _email = "jdoe@gmail.com";
  String _phoneNumber = "0244000000";

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: _fullName);
    _emailController = TextEditingController(text: _email);
    _phoneNumberController = TextEditingController(text: _phoneNumber);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    }
  }

  void _toggleEditingFullName() {
    setState(() {
      if (_isEditingFullName) {
        _fullName = _fullNameController.text;
      }
      _isEditingFullName = !_isEditingFullName;
    });
  }

  void _toggleEditingEmail() {
    setState(() {
      if (_isEditingEmail) {
        _email = _emailController.text;
      }
      _isEditingEmail = !_isEditingEmail;
    });
  }

  void _toggleEditingPhoneNumber() {
    setState(() {
      if (_isEditingPhoneNumber) {
        _phoneNumber = _phoneNumberController.text;
      }
      _isEditingPhoneNumber = !_isEditingPhoneNumber;
    });
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(),
      ),
    );
  }


  void _deleteAccount() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform delete account logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted successfully.")),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildEditableField("Full Name", _fullName, _fullNameController, _isEditingFullName, _toggleEditingFullName),
            const SizedBox(height: 20),
            _buildEditableField("Email", _email, _emailController, _isEditingEmail, _toggleEditingEmail),
            const SizedBox(height: 20),
            _buildEditableField("Phone Number", _phoneNumber, _phoneNumberController, _isEditingPhoneNumber, _toggleEditingPhoneNumber),
            const SizedBox(height: 40),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Change Password", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label, String value, TextEditingController controller, bool isEditing, VoidCallback onEditPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: isEditing
                ? TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(border: InputBorder.none),
              onSubmitted: (_) => onEditPressed(),
            )
                : Text(value, style: const TextStyle(color: Colors.black)),
          ),
          IconButton(icon: const Icon(Icons.edit, color: Colors.black), onPressed: onEditPressed),
        ],
      ),
    );
  }
}
