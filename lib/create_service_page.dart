import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateServicePage extends StatefulWidget {
  final String userId;
  final String userName; // Add userName parameter

  const CreateServicePage({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _CreateServicePageState createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceDescriptionController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  String? selectedServiceType; // For dropdown selection

  Future<void> _submitService() async {
    final String serviceName = serviceNameController.text.trim();
    final String serviceDescription = serviceDescriptionController.text.trim();
    final String experience = experienceController.text.trim();

    if (selectedServiceType == null ||
        serviceName.isEmpty ||
        serviceDescription.isEmpty ||
        experience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      // Add the service details to Firestore
      await FirebaseFirestore.instance.collection('services').add({
        'type': selectedServiceType, // Store the selected service type
        'name': serviceName,
        'description': serviceDescription,
        'experience': experience,
        'offeredBy': widget.userName, // Assign userName to "offeredBy"
        'userId': widget.userId, // Link to the caregiver's userId
        'requestCount': 0, // Initialize with zero requests
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service created successfully!')),
      );

      Navigator.pop(context); // Navigate back to previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating service: $e')),
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
        title: const Text('Your Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown for Service Type
              DropdownButtonFormField<String>(
                value: selectedServiceType,
                items: [
                  'Physical Therapy',
                  'Health Checkup',
                  'Counseling',
                  'Lab Testing',
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Service Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedServiceType = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Service Name Field
              TextField(
                controller: serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              TextField(
                controller: serviceDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Service Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Experience Field
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'How many years of experience do you have?',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                ),
                child: const Text('REQUEST CREATION OF SERVICE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
