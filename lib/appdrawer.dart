import 'package:flutter/material.dart';
import 'package:karoseva/book_service.dart';
import 'package:karoseva/offer_service_page.dart';
import '/profile_page.dart';
import '/my_services_page.dart';

class AppDrawer extends StatelessWidget {
  final String userId;

  const AppDrawer({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Center(
              child: Image.asset(
              'assets/images/logo.png',
              height: 60,
            ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Book A Service'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookServicePage(userId: userId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Services'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyServicesPage(userId: userId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Offer A Service'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfferServicesPage(userId: userId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
              );
            },
          ),
        ],
      ),
    );
  }
}
