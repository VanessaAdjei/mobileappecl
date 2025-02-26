import 'package:eclapp/pages/changepassword.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: _userName);
    _userEmailController = TextEditingController(text: _userEmail);
    _phoneNumberController = TextEditingController(text: _phoneNumber);
    _loadUserData();
    _loadProfileImage();
  }


  Future<void> _pickImage() async {
    var status = await Permission.storage.request();
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

    // Copy the selected image to local storage
    final File savedImage = await imageFile.copy(savedImagePath);

    // Save path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImagePath);

    return savedImage;
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image_path');

    if (savedImagePath != null && File(savedImagePath).existsSync()) {
      setState(() {
        _profileImage = File(savedImagePath);
        _profileImagePath = savedImagePath;
      });
    }
  }



  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? name = prefs.getString(AuthService.userNameKey) ?? "User";
    String? email = prefs.getString(AuthService.userEmailKey) ?? "No email available";
    String? phoneNumber = prefs.getString(AuthService.userPhoneNumberKey) ?? "No phone number available";

    setState(() {
      _userName = name;
      _userEmail = email;
      _phoneNumber = phoneNumber;
      _userNameController.text = _userName;
      _userEmailController.text = _userEmail;
      _phoneNumberController.text = _phoneNumber;
    });

    print("Loaded Data -> Name: $_userName, Email: $_userEmail, Phone: $_phoneNumber");
  }





  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  late TextEditingController _phoneNumberController;


  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   var status = await Permission.storage.request();
  //
  //   if (status.isGranted) {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //
  //     if (image != null) {
  //       setState(() {
  //         _profileImage = File(image.path);
  //       });
  //     }
  //   } else if (status.isDenied) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Permission denied. Please allow access from settings.")),
  //     );
  //   } else if (status.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }


  void _toggleEditinguserName() async {
    if (_isEditinguserName) {
      String updatedName = _userNameController.text;
      await AuthService.saveUserDetails(updatedName, _userEmail, _phoneNumber);

      setState(() {
        _userName = updatedName;
      });
    }

    setState(() {
      _isEditinguserName = !_isEditinguserName;
    });
  }





  void _toggleEditingEmail() async {
    if (_isEditinguserEmail) {
      String updatedEmail = _userEmailController.text;
      await AuthService.saveUserDetails(_userName, updatedEmail, _phoneNumber);

      setState(() {
        _userEmail = updatedEmail;
      });
    }

    setState(() {
      _isEditinguserEmail = !_isEditinguserEmail;
    });
  }


  void _toggleEditingPhoneNumber() async {
    if (_isEditingPhoneNumber) {
      String updatedPhone = _phoneNumberController.text;
      await AuthService.saveUserDetails(_userName, _userEmail, updatedPhone);

      setState(() {
        _phoneNumber = updatedPhone;
      });
    }

    setState(() {
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
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const NetworkImage("https://via.placeholder.com/150") as ImageProvider,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade100,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? const Icon(Icons.camera_alt, size: 20, color: Colors.green)
                            : null,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildEditableField("Full Name", _userName, _userNameController, _isEditinguserName, _toggleEditinguserName),
            const SizedBox(height: 20),
            _buildEditableField("Email", _userEmail, _userEmailController, _isEditinguserEmail, _toggleEditingEmail),
            const SizedBox(height: 20),
            _buildEditableField("Phone Number", _phoneNumber, _phoneNumberController, _isEditingPhoneNumber, _toggleEditingPhoneNumber),
            const SizedBox(height: 40),
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
