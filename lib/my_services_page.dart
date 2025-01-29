import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appdrawer.dart';
import 'reschedule_page.dart';

class MyServicesPage extends StatelessWidget {
  final String userId;

  const MyServicesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('My Services'),
      ),
      drawer: AppDrawer(userId: userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_requests')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Scheduled Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You have not requested any services yet.',
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                  ],
                ),
              );
            }

            final services = snapshot.data!.docs;

            return ListView(
              children:
                  services.map((service) => _buildServiceCard(context, service)).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, QueryDocumentSnapshot service) {
    final String requestedAt = (service['requestedAt'] as Timestamp?)
            ?.toDate()
            .toLocal()
            .toString()
            .split(' ')[0] ??
        'Unknown Date';

    final String status = service['status'] ?? 'Pending';

final Map<String, dynamic>? serviceData = service.data() as Map<String, dynamic>?;

final String? rescheduleComment = serviceData != null && 
        serviceData.containsKey('rescheduleComment')
    ? serviceData['rescheduleComment']
    : null;

final String? rescheduleDate = serviceData != null && 
        serviceData.containsKey('newProposedDate') &&
        serviceData['newProposedDate'] is Timestamp
    ? (serviceData['newProposedDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
    : null;


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.calendar_today, color: Colors.white),
        ),
        title: Text(
          service['serviceName'] ?? 'Unknown Service',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requested At: $requestedAt'),
            Text('Status: $status'),
            if (status == 'rescheduled' && rescheduleDate != null) ...[
              Text('Rescheduled Date: $rescheduleDate'),
              if (rescheduleComment != null) Text('Comment: $rescheduleComment'),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'rescheduled')
              ElevatedButton(
                onPressed: () {
                  _acceptReschedule(
                      context, service.id, service['newProposedDate'] as Timestamp?);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Accept'),
              ),
            if (status == 'rescheduled') const SizedBox(width: 8),
            if (status == 'rescheduled')
              ElevatedButton(
                onPressed: () {
                  _denyReschedule(context, service.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Deny'),
              ),
            if (status == 'booked' || status == 'pending')
              IconButton(
                icon: const Icon(Icons.schedule, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReschedulePage(
                        requestId: service.id,
                        userId: service['userId'], // Retrieve userId
                        serviceId: service['serviceId'], // Retrieve serviceId
                        serviceName: service['serviceName'], // Retrieve serviceName
                        currentDate: (service['requestedAt'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .split(' ')[0], // Convert Timestamp to String
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptReschedule(
      BuildContext context, String requestId, Timestamp? newDate) async {
    try {
      await FirebaseFirestore.instance.collection('service_requests').doc(requestId).update({
        'status': 'booked',
        'requestedAt': newDate, // Update to the rescheduled date
        'rescheduleComment': FieldValue.delete(), // Clear comment
        'newProposedDate': FieldValue.delete(), // Clear new date
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting reschedule: $e')),
      );
    }
  }

  Future<void> _denyReschedule(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('service_requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule denied successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error denying reschedule: $e')),
      );
    }
  }
}
