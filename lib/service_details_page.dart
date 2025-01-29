import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_booking_page.dart'; // Import the ServiceBookingPage

class ServiceDetailsPage extends StatelessWidget {
  final String userId;
  final String serviceId;
  final String serviceName;

  const ServiceDetailsPage({
    Key? key,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Service Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get()
            .then((doc) => doc.data() ?? {}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final serviceDetails = snapshot.data!;
          final String offeredBy = serviceDetails['offeredBy'] ?? 'Unknown';
          final String description =
              serviceDetails['description'] ?? 'No description available';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image Header
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(serviceDetails['imageUrl'] ??
                              'https://via.placeholder.com/150'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 160,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Space for the profile picture

                // Service Name
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Offered By
                Text(
                  'Offered By: $offeredBy',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // Service Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),

                // Request Service Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to ServiceBookingPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceBookingPage(
                          userId: userId,
                          serviceId: serviceId,
                          serviceName: serviceName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                  ),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('REQUEST SERVICE'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
