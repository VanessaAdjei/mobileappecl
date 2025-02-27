import 'package:eclapp/pages/prescription.dart';
import 'package:flutter/material.dart';

class ClickableImageRow extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/prescription.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to the Prescription page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrescriptionUploadPage()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              width: 420, // Adjust width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageUrls[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
