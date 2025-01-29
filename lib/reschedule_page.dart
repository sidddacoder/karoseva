import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReschedulePage extends StatefulWidget {
  final String requestId; // Unique request ID
  final String userId;
  final String serviceId;
  final String serviceName;
  final String currentDate;

  const ReschedulePage({
    Key? key,
    required this.requestId, // Include requestId in the constructor
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.currentDate,
  }) : super(key: key);

  @override
  _ReschedulePageState createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime? _selectedDate;

  // Function to select a new date
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

  // Function to update the Firestore document
  Future<void> _updateRequest() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new date!')),
      );
      return;
    }

    try {
      // Update the specific request in Firestore
      await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(widget.requestId)
          .update({
        'status': 'pending', // Mark the request as pending
        'requestedAt': _selectedDate, // Update to the newly selected date
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service rescheduled successfully!')),
      );

      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Reschedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Reschedule Service: ${widget.serviceName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Date: ${widget.currentDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
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
                          ? 'Select a new date'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              child: const Text('UPDATE REQUEST'),
            ),
          ],
        ),
      ),
    );
  }
}
