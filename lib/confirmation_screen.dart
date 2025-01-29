// ConfirmationScreen.dart
import 'package:flutter/material.dart';
import 'my_services_page.dart'; // Import MyServicesPage

class ConfirmationScreen extends StatelessWidget {
  final String userId;

  const ConfirmationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue, // Background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),

              // Confirmation Title
              const Text(
                'Request Submitted!',
                style: TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Confirmation Message
              const Text(
                'Please wait for the caregiver to approve your request and then either send you a meeting link or a location for a physical consultation.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Confirmation Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to My Services Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyServicesPage(userId: userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 40),
                ),
                child: const Text(
                  'GOT IT!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
