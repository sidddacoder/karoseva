import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reschedule_confirmation_page.dart';

class RescheduleRequestPage extends StatefulWidget {
  final String requestId;
  final String requestedBy;
  final String serviceName;
  final DateTime currentDate;
  final String serviceId;
  final String userId; // Added userId for navigation to confirmation page

  const RescheduleRequestPage({
    Key? key,
    required this.requestId,
    required this.requestedBy,
    required this.serviceName,
    required this.currentDate,
    required this.serviceId,
    required this.userId, // Ensure userId is passed
  }) : super(key: key);

  @override
  _ReschedulePageRequestState createState() => _ReschedulePageRequestState();
}

class _ReschedulePageRequestState extends State<RescheduleRequestPage> {
  final TextEditingController _commentController = TextEditingController();
  DateTime? _newDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _newDate) {
      setState(() {
        _newDate = picked;
      });
    }
  }

  Future<void> _submitReschedule() async {
    if (_newDate == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(widget.requestId)
          .update({
        'status': 'rescheduled',
        'rescheduleComment': _commentController.text.trim(),
        'newProposedDate': _newDate,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RescheduleConfirmationPage(
            userId: widget.userId, // Pass userId
            serviceId: widget.serviceId, // Pass serviceId
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rescheduling request: $e')),
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
        title: const Text('Reschedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Details
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  title: Text(
                    widget.requestedBy,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service: ${widget.serviceName}'),
                      Text('Current Date: ${widget.currentDate.toLocal()}'.split(' ')[0]),
                    ],
                  ),
                ),
              ),

              // Reschedule Comment
              const Text('Reschedule Comment'),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Enter reschedule comment...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date Picker
              const Text('New Proposed Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _newDate == null
                            ? 'Pick a new date'
                            : '${_newDate!.toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.teal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  ),
                  child: const Text('UPDATE REQUEST'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
