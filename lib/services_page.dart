import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_service.dart'; // Import the Book a Service page

class ServicesPage extends StatefulWidget {
  final String userId;

  const ServicesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> services = [];
  List<DocumentSnapshot> filteredServices = [];
  Map<String, bool> serviceSelections = {}; // Track selections locally

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      // Fetch all services from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        services = snapshot.docs;
        filteredServices = services;

        // Initialize local state for checkboxes
        for (var service in services) {
          final serviceData = service.data() as Map<String, dynamic>?; // Safe typecast
          serviceSelections[service.id] = serviceData?['selection'] ?? false;
        }
      });
    } catch (e) {
      // Handle Firestore fetch error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching services: $e')),
      );
    }
  }

  void _filterServices(String query) {
    final filtered = services.where((service) {
      final serviceData = service.data() as Map<String, dynamic>?; // Safe typecast
      final serviceName = (serviceData?['name'] ?? '').toString().toLowerCase();
      return serviceName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredServices = filtered;
    });
  }

  Future<void> _updateServiceSelection(String serviceId, bool isSelected) async {
    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .update({'selection': isSelected});

      // Update local state
      setState(() {
        serviceSelections[serviceId] = isSelected;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating selection: $e')),
      );
    }
  }

  void _navigateToBookServicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookServicePage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo.png', // Replace with your logo path
          height: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterServices,
            ),
            const SizedBox(height: 16),

            // Header Text
            const Text(
              'What Services Do You Typically Book',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Services List
            Expanded(
              child: filteredServices.isEmpty
                  ? const Center(child: Text('No services available'))
                  : ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        final serviceId = service.id;
                        final serviceData = service.data() as Map<String, dynamic>?; // Safe typecast
                        final isSelected = serviceSelections[serviceId] ?? false;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(Icons.miscellaneous_services),
                            title: Text(
                              serviceData?['name'] ?? 'Unknown Service',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Checkbox(
                              activeColor: Colors.purple,
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  _updateServiceSelection(serviceId, value);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // DONE Button
            ElevatedButton(
              onPressed: _navigateToBookServicePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
