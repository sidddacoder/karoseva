import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'reschedule_request_page.dart';
import 'offer_service_page.dart'; // Import OfferServicesPage
import 'appdrawer.dart'; // Ensure AppDrawer is imported

class MyServiceRequestsPage extends StatelessWidget {
  final String userId;
  final String serviceId; // Add serviceId as a required parameter

  const MyServiceRequestsPage({
    Key? key,
    required this.userId,
    required this.serviceId, // Ensure serviceId is passed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.greenAccent.shade100,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: const Text('My Service Requests'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to OfferServicesPage with userId
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OfferServicesPage(userId: userId),
                ),
              );
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'New Requests'),
              Tab(text: 'Rescheduled'),
              Tab(text: 'Booked'),
            ],
          ),
        ),
        drawer: AppDrawer(userId: userId), // Use AppDrawer with userId
        body: TabBarView(
          children: [
            _buildRequestList(context, 'pending'), // New Requests Tab
            _buildRequestList(context, 'rescheduled'), // Rescheduled Tab
            _buildRequestList(context, 'booked'), // Booked Tab
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('serviceId', isEqualTo: serviceId) // Use serviceId filter
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No requests found.'));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final String requestedBy = request['requestedBy'] ?? 'Unknown';
            final String serviceName = request['serviceName'] ?? 'Unknown Service';

            // Handle Dates Based on Status
            final DateTime? displayDate;
            if (status == 'rescheduled') {
              displayDate = request['newProposedDate'] != null
                  ? (request['newProposedDate'] as Timestamp).toDate()
                  : null;
            } else {
              displayDate = request['requestedAt'] != null
                  ? (request['requestedAt'] as Timestamp).toDate()
                  : null;
            }

            final String dateDisplay = displayDate != null
                ? DateFormat('MMMM dd, yyyy').format(displayDate)
                : 'Unknown Date';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  requestedBy,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  status == 'rescheduled'
                      ? 'Rescheduled to: $dateDisplay'
                      : 'Proposed: $dateDisplay',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'pending')
                      ElevatedButton(
                        onPressed: () {
                          _acceptRequest(context, request.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('ACCEPT'),
                      ),
                    if (status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.schedule, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RescheduleRequestPage(
                                requestId: request.id,
                                requestedBy: requestedBy,
                                serviceName: serviceName,
                                currentDate: displayDate!, // Pass the correct displayDate here
                                serviceId: serviceId, // Pass the correct serviceId
                                userId: userId, // Pass the userId as required
                              ),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _denyRequest(context, request.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(requestId)
          .update({'status': 'booked'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: $e')),
      );
    }
  }

  Future<void> _denyRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('service_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request denied successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error denying request: $e')),
      );
    }
  }
}
