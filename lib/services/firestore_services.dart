import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a new patient to the Firestore database
  Future<void> addPatient(String name, String email, String password) async {
    try {
      await _firestore.collection('patients').add({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Patient added successfully.');
    } catch (e) {
      print('Error adding patient: $e');
    }
  }

  /// Validates login by checking email and password
  Future<bool> validatePatient(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('patients')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error validating patient: $e');
      return false;
    }
  }

  /// Fetches all patients for debugging
  Future<List<Map<String, dynamic>>> fetchPatients() async {
    try {
      final querySnapshot = await _firestore.collection('patients').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }
}
