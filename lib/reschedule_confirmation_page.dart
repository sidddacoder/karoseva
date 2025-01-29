import 'package:flutter/material.dart';
import 'my_service_requests_page.dart';

class RescheduleConfirmationPage extends StatelessWidget {
  final String userId; // User ID to navigate back to MyServiceRequestsPage
  final String serviceId; // Service ID to navigate back to MyServiceRequestsPage

  const RescheduleConfirmationPage({
    Key? key,
    required this.userId, // Ensure userId is passed
    required this.serviceId, // Ensure serviceId is passed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top
            Image.asset(
              'assets/images/logo.png', // Replace with your logo path
              height: 100,
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Reschedule Sent!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            const Text(
              'Your comment and new proposed time\nhave been sent to the patient.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Button to return to MyServiceRequestsPage
            ElevatedButton(
              onPressed: () {
                // Navigate back to MyServiceRequestsPage and clear the navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyServiceRequestsPage(
                      userId: userId, // Pass the userId
                      serviceId: serviceId, // Pass the serviceId
                    ),
                  ),
                  (route) => false, // Remove all previous routes from the stack
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              child: const Text('GOT IT!'),
            ),
          ],
        ),
      ),
    );
  }
}
