import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PrescriptionUploadPage extends StatefulWidget {
  @override
  _PrescriptionUploadPageState createState() => _PrescriptionUploadPageState();
}

class _PrescriptionUploadPageState extends State<PrescriptionUploadPage> {
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  void _chooseFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        _showConfirmationSnackbar("Prescription uploaded successfully!");
      } else {
        _showConfirmationSnackbar("No image selected.");
      }
    } catch (e) {
      _showConfirmationSnackbar("Failed to upload image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmationSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 2,
            child: InteractiveViewer(
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Prescription", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView( // Make the page scrollable
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUploadSection(),
              SizedBox(height: 5),
              if (_selectedImage != null) _buildSelectedImageSection(context),
              SizedBox(height: 5),
              _buildRequirementsSection(),
              SizedBox(height: 5),
              _buildSamplePrescriptionSection(),
              SizedBox(height: 5),
              _buildWarningSection(),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4, // Slightly higher elevation for a modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title with an icon for better visual appeal
            Row(
              children: [
                Icon(Icons.upload, size: 24, color: Colors.green.shade700), // Icon for upload
                SizedBox(width: 10), // Spacing between icon and text
                Text(
                  "Upload Prescription",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Spacing between title and button

            // Upload Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _chooseFromGallery,
              icon: _isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(Icons.image, size: 24), // Larger icon size
              label: Text(
                "Choose from Gallery",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20), // More padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Slightly rounded corners
                ),
                elevation: 2, // Add elevation to the button
                shadowColor: Colors.green.shade200, // Subtle shadow
              ),
            ),

            SizedBox(height: 10), // Spacing below the button

            // Optional: Add a subtitle for additional information
            Text(
              "Supported formats: JPG, PNG, PDF (Max 10MB)",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImageSection(BuildContext context) {
    if (_selectedImage == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showFullImageDialog(context, _selectedImage!);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              height: 120, // Reduced size
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 10), // Spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _deleteImage, // Call the delete function
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text("Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 10), // Spacing
            ElevatedButton.icon(
              onPressed: _chooseFromGallery, // Function to pick a new image
              icon: Icon(Icons.image, color: Colors.white),
              label: Text("Choose New"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Function to delete the selected image
  void _deleteImage() {
    setState(() {
      _selectedImage = null; // Clear the selected image
    });
    _showConfirmationSnackbar("Image deleted successfully!");
  }

  void _showFullImageDialog(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9), // Dark background for focus
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Close on tap
          child: Container(
            color: Colors.transparent, // Remove any white backdrop
            child: Center(
              child: Image.file(
                imageFile,
                fit: BoxFit.contain, // Ensure proper scaling
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Prescription Requirements:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.green.shade600)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoChip("Doctor Details", Icons.person),
            _infoChip("Date of Prescription", Icons.date_range),
            _infoChip("Patient Details", Icons.account_circle),
            _infoChip("Medicine Details", Icons.medication),
            _infoChip("Max File Size: 10MB", Icons.upload_file),
          ],
        ),
      ],
    );
  }

  Widget _buildSamplePrescriptionSection() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Sample Prescription:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.green.shade600,
            ),
          ),
          SizedBox(height: 8), // Add spacing
          GestureDetector(
            onTap: () => _showImageDialog(context, "assets/images/prescriptionsample.png"),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/prescriptionsample.png",
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        Expanded(
          child: Text(
            "Our pharmacist will dispense medicines only if the prescription is valid & meets all government regulations.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.green.shade600),
      label: Text(label, style: TextStyle(fontSize: 14, color: Colors.green.shade800)),
      backgroundColor: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}