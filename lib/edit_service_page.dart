import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;

  const EditServicePage({
    Key? key,
    required this.serviceId,
    required this.serviceData,
  }) : super(key: key);

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceDescriptionController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    serviceNameController.text = widget.serviceData['name'] ?? '';
    serviceDescriptionController.text = widget.serviceData['description'] ?? '';
    experienceController.text = widget.serviceData['experience'] ?? '';
  }

  Future<void> _updateService() async {
    final String updatedName = serviceNameController.text.trim();
    final String updatedDescription = serviceDescriptionController.text.trim();
    final String updatedExperience = experienceController.text.trim();

    if (updatedName.isEmpty || updatedDescription.isEmpty || updatedExperience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      // Update Firestore document
      await FirebaseFirestore.instance.collection('services').doc(widget.serviceId).update({
        'name': updatedName,
        'description': updatedDescription,
        'experience': updatedExperience,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated successfully!')),
      );

      Navigator.pop(context); // Navigate back to previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating service: $e')),
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
        title: const Text('Edit Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Service Name Field
              TextField(
                controller: serviceNameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              const SizedBox(height: 20),

              // Description Field
              TextField(
                controller: serviceDescriptionController,
                decoration: const InputDecoration(labelText: 'Service Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Experience Field
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'How many years of experience do you have?',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _updateService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                ),
                child: const Text('UPDATE SERVICE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
