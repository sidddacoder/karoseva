import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfilePage extends StatefulWidget {
  final String userId;

  const CreateProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  File? _imageFile;

  /// Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Save the profile image and update Firestore
  Future<void> _saveProfileToFirestore() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      // Save the file locally
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${widget.userId}.jpg';
      final localPath = '${appDir.path}/$fileName';

      await _imageFile!.copy(localPath);

      // Update the user profile in Firestore
      await FirebaseFirestore.instance.collection('patients').doc(widget.userId).update({
        'profileImage': localPath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      // Navigate to the Services page with userId
      Navigator.pushNamed(
        context,
        '/services',
        arguments: {'userId': widget.userId}, // Pass userId as Map
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        title: const Text('Signup - Create Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Add a Profile Picture\nSo that everyone can get to know you!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile == null
                    ? const Center(
                        child: Text(
                          'Choose Photo',
                          style: TextStyle(color: Colors.teal),
                        ),
                      )
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              onPressed: _saveProfileToFirestore,
              child: const Text('CREATE PROFILE'),
            ),
          ],
        ),
      ),
    );
  }
}
