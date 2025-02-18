import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.green.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( // Use const
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Green title
              ),
            ),
            const SizedBox(height: 24), // Increased spacing




            const Text( // Use const
              'We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and disclose information about you when you use our services.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5), // Added height for better readability
            ),
            const SizedBox(height: 16), // Consistent spacing
            const Text( // Use const
              'Data Collection: We collect personal information such as your name, email address, and payment details when you register with us or use our services.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5), // Added height
            ),
            const SizedBox(height: 16), // Consistent spacing
            const Text( // Use const
              'Data Use: The data we collect is used to provide you with our services, improve our offerings, and communicate with you.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5), // Added height
            ),
            const SizedBox(height: 16), // Consistent spacing
            const Text( // Use const
              'Third-Party Sharing: We do not share your personal information with third parties without your consent, except as required by law.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5), // Added height
            ),

            const SizedBox(height: 24), // Increased spacing
            // Add more sections as needed...
          ],
        ),
      ),
    );
  }
}
