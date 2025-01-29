import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_service_page.dart';
import 'edit_service_page.dart';
import 'my_service_requests_page.dart';

class OfferServicesPage extends StatefulWidget {
  final String userId;

  const OfferServicesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OfferServicesPageState createState() => _OfferServicesPageState();
}

class _OfferServicesPageState extends State<OfferServicesPage> {
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = _fetchUserName(widget.userId);
  }

  Future<String> _fetchUserName(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('patients').doc(userId).get();
    return doc.data()?['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('Caregiver Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: _userNameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Error fetching user name. Please try again later.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final userName = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png', // Replace with your logo path
                              height: 50,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Want to offer a service?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'We encourage all licensed medical users to offer services on KaroSeva.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Offer a Service Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateServicePage(
                            userId: widget.userId,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: const Text(
                      'OFFER A SERVICE',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Your Services Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // List of Services
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('services')
                      .where('offeredBy', isEqualTo: userName) // Filter by offeredBy
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: const [
                              Text(
                                'No services offered yet.',
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Start by clicking "OFFER A SERVICE" to add one.',
                                style: TextStyle(fontSize: 14, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final services = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            title: Text(
                              service['name'] ?? 'Unknown Service',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text('Requests: ${service['requestCount'] ?? 0}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.teal),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditServicePage(
                                          serviceId: service.id,
                                          serviceData:
                                              service.data() as Map<String, dynamic>,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
  icon: const Icon(Icons.arrow_forward, color: Colors.teal),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyServiceRequestsPage(
          serviceId: service.id,  // Pass serviceId if required
          userId: widget.userId,  // Pass userId correctly
        ),
      ),
    );
  },
),

                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
