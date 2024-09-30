// Import necessary packages for Flutter, Firebase authentication, Firestore database, and icons.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

import '../screens/optionscreen.dart';
import 'navigationmenu.dart';

// Define a stateless widget for the navigation drawer.
class Navdrawer extends StatelessWidget {
  // Controller for managing navigation state.
  final NavigationController controller;

  // Constructor with a required controller parameter.
  const Navdrawer({super.key, required this.controller});

  // Function to handle user sign out.
  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out the user using Firebase authentication.
      await FirebaseAuth.instance.signOut();
      
      // Show a snackbar message indicating successful logout.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for 2 seconds before navigating to the options screen.
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Optionscreen()), 
      );
    } catch (e) {
      // Print error message if sign out fails.
      print("Error signing out: $e");
    }
  }

  // Function to fetch user data from Firestore.
  Future<DocumentSnapshot> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get user document from Firestore using the user's UID.
      return FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    } else {
      // Throw an exception if the user is not logged in.
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Use FutureBuilder to fetch and display user data.
          FutureBuilder<DocumentSnapshot>(
            future: _fetchUserData(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading state in the UserAccountsDrawerHeader.
                return UserAccountsDrawerHeader(
                  accountName: const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset('assets/pfpholder.jpg'),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 225, 0),
                  ),
                );
              } else if (snapshot.hasError) {
                // Show error state in the UserAccountsDrawerHeader.
                return UserAccountsDrawerHeader(
                  accountName: const Text(
                    'Error',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: const Text(
                    'Error',
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset('assets/pfpholder.jpg'),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 225, 0),
                  ),
                );
              } else if (snapshot.hasData) {
                // Show user data in the UserAccountsDrawerHeader.
                var data = snapshot.data!.data() as Map<String, dynamic>;
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    data['Name'] ?? 'No Name',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(
                    data['UserEmail'] ?? 'No Email',
                    style: const TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset('assets/pfpholder.jpg'),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 225, 0),
                  ),
                );
              } else {
                // Show default state if no user data is found.
                return UserAccountsDrawerHeader(
                  accountName: const Text(
                    'No User',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: const Text(
                    'No Email',
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset('assets/pfpholder.jpg'),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 225, 0),
                  ),
                );
              }
            },
          ),
          // List tile for 'My Account' with navigation handling.
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
              controller.selectedIndex.value = 3; 
              Navigator.pop(context); 
            },
          ),
          // List tile for 'Settings' (functionality not implemented).
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
          // List tile for 'Card' (functionality not implemented).
          ListTile(
            leading: const Icon(
              Iconsax.card,
              color: Colors.black,
            ),
            title: const Text(
              'Card',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {},
          ),
          // List tile for 'Logout' with sign out functionality.
          ListTile(
            leading: const Icon(
              Iconsax.logout,
              color: Colors.black,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
  // This concludes the navigation drawer widget, providing various options such as 
  // viewing the account, settings, card details, and logging out. The drawer also 
  // dynamically displays user information fetched from Firestore and handles user 
  // sign-out functionality.

