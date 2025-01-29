import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirmation_screen.dart'; // Import the confirmation screen

class ServiceBookingPage extends StatefulWidget {
  final String userId;
  final String serviceId;
  final String serviceName;

  const ServiceBookingPage({
    Key? key,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
  }) : super(key: key);

  @override
  _ServiceBookingPageState createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  DateTime? _selectedDate;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      // Fetch the user's name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.userId)
          .get();

      setState(() {
        _userName = userDoc.data()?['name'] ?? 'Unknown';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user name: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for the service!')),
      );
      return;
    }

    try {
      final serviceRequests = FirebaseFirestore.instance.collection('service_requests');
      final services = FirebaseFirestore.instance.collection('services');

      // Save the service request to Firestore
      await serviceRequests.add({
        'userId': widget.userId,
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'requestedBy': _userName ?? 'Unknown', // Include user's name
        'status': 'pending',
        'requestedDate': _selectedDate,
        'requestedAt': Timestamp.now(),
      });

      // Increment requestCount in the services collection
      await services.doc(widget.serviceId).update({
        'requestCount': FieldValue.increment(1),
      });

      // Navigate to ConfirmationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(userId: widget.userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    }
  }

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
        title: const Text('Service Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Pick A Date For Your Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker Field
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select a date'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              child: const Text('SUBMIT REQUEST'),
            ),
          ],
        ),
      ),
    );
  }
}
