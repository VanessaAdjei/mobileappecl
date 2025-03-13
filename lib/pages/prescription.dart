import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'Cart.dart';

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

  void _submitPrescription() async {
    if (_selectedImage != null) {
      _showConfirmationSnackbar("Prescription submitted successfully!");
      final String phoneNumber = "+233504518047";
      final String message = "Hello, I am submitting my prescription.";
      final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

      try {
        await launchUrl(whatsappUrl);
        _showConfirmationSnackbar("Opening WhatsApp...");
      } catch (e) {
        _showConfirmationSnackbar("Could not open WhatsApp.");
      }
    } else {
      _showConfirmationSnackbar("Please upload a prescription first.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Upload Your Prescription',
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
            child: IconButton(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUploadSection(),
              SizedBox(height: 5),
              if (_selectedImage != null) _buildSelectedImageSection(context),
              SizedBox(height: 10),
              if (_selectedImage != null) // Display Submit button only if an image is selected
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitPrescription,
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text("Submit Prescription"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.green.shade200,
                  ),
                ),
              SizedBox(height: 20),
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
  //
  // void _submitPrescription() {
  //   if (_selectedImage != null) {
  //     _showConfirmationSnackbar("Prescription submitted successfully!");
  //   } else {
  //     _showConfirmationSnackbar("Please upload a prescription first.");
  //   }
  // }


  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.upload, size: 24, color: Colors.green.shade700),
                SizedBox(width: 10),
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
            SizedBox(height: 20),

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
                  : Icon(Icons.image, size: 24),
              label: Text(
                "Choose from Gallery",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.green.shade200,
              ),
            ),

            SizedBox(height: 10),


            Text(
              "Supported formats: JPG, PNG",
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
              onPressed: _deleteImage,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text("Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 10), // Spacing
            ElevatedButton.icon(
              onPressed: _chooseFromGallery,
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