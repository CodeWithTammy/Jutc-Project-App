// Importing necessary packages for Flutter app and Firebase authentication
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jutcapp/Utils/drivernavmenu.dart';

import '../screens/optionscreen.dart';

// Stateless widget for the DriverDrawer
class DriverDrawer extends StatelessWidget {
  final DriverNavigationController controller;

  // Constructor to initialize the DriverDrawer with a controller
  const DriverDrawer({super.key, required this.controller});

  // Function to sign out the user
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to the options screen after a short delay to show the Snackbar
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Optionscreen()), // Navigate to the options screen
      );
    } catch (e) {
      print("Error signing out: $e"); // Print error message if sign out fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // UserAccountsDrawerHeader to display user's account information
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Driver Id: 20205621',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text(
              'Route: 17A',
              style: TextStyle(color: Colors.black),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/pfpholder.jpg'), // Placeholder image for profile picture
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
          ),
          // List tile for "My Account" option
          ListTile(
            leading: const Icon(
              Iconsax.user,
              color: Colors.black,
            ),
            title: const Text(
              'My Account',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              controller.selectedIndex.value = 1; // Update the selected index
              Navigator.pop(context); // Close the drawer
            },
          ),
          // List tile for "Settings" option
          ListTile(
            leading: const Icon(
              Iconsax.setting,
              color: Colors.black,
            ),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {},
          ),
          // List tile for "History" option
          ListTile(
            leading: const Icon(
              Iconsax.archive_1,
              color: Colors.black,
            ),
            title: const Text(
              'History',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {},
          ),
          // List tile for "Logout" option
          ListTile(
            leading: const Icon(
              Iconsax.logout,
              color: Colors.black,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Optionscreen()), // Navigate to the options screen
            ),
          ),
        ],
      ),
    );
  }
}
