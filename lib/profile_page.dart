import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  int servicesBookedCount = 0;
  int servicesOfferedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchServiceCounts();
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _fetchServiceCounts() async {
    try {
      // Fetch counts for services booked and offered
      final bookedSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final offeredSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('createdBy', isEqualTo: widget.userId)
          .get();

      setState(() {
        servicesBookedCount = bookedSnapshot.size;
        servicesOfferedCount = offeredSnapshot.size;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching service counts: $e')),
      );
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userId: widget.userId),
      ),
    ).then((_) {
      // Refresh the user data after editing the profile
      _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header with Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData?['profileImage'] != null
                        ? NetworkImage(userData!['profileImage'])
                        : null,
                    child: userData?['profileImage'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                    backgroundColor: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Services Booked', servicesBookedCount),
                      _buildStatCard('Services Offered', servicesOfferedCount),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 10),
                  _buildInterestedServices(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: const Text('EDIT'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: const Text('LOG OUT'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestedServices() {
    final List<String> services = userData?['interestedServices'] ?? [];
    return Column(
      children: services.map((service) {
        return ListTile(
          title: Text(service),
          subtitle: const Text('Available Classes: Service count'),
        );
      }).toList(),
    );
  }
}
