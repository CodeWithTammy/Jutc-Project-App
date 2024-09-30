// Import necessary packages for Flutter app, Firebase authentication, Firestore, and icons
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../screens/optionscreen.dart';

// Driveraccountscreen widget that maintains state
class Driveraccountscreen extends StatefulWidget {
  const Driveraccountscreen({super.key});

  @override
  State<Driveraccountscreen> createState() => _DriveraccountscreenState();
}

// State class for Driveraccountscreen
class _DriveraccountscreenState extends State<Driveraccountscreen> {
  String userName = 'Driver Id: 20205621';  // Default user name
  String routeNumber = '17A';  // Default route number

  @override
  void initState() {
    super.initState();
    fetchUserData();  // Fetch user data when the widget is initialized
  }

  // Function to fetch user data from Firestore
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;  // Get the current user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['DriverId'];  // Update userName with fetched data
          routeNumber = userDoc['route'];  // Update routeNumber with fetched data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;  // Get screen width
    final screenHeight = MediaQuery.of(context).size.height;  // Get screen height

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Card(
                elevation: 20,
                color: const Color.fromARGB(255, 44, 44, 44),
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.2,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Route: $routeNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/pfpholder.jpg')),  // Placeholder image
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 20,
              color: const Color.fromARGB(255, 44, 44, 44),
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.42,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Settings'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Add your settings logic here
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 20,
                      thickness: 1,
                    ),
                    ListTile(
                      title: const Text('Contact Support'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Add your contact support logic here
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 20,
                      thickness: 1,
                    ),
                    ListTile(
                      title: const Text('History'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Add your history logic here
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 20,
                      thickness: 1,
                    ),
                    ListTile(
                      title: const Text('Theme'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Add your theme logic here
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const Optionscreen()),  // Navigate to options screen
                );
              },
              child: Container(
                width: screenWidth * 0.5,
                child: const Center(
                  child: Text('Logout'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 221, 0),
                foregroundColor: Colors.black,
                elevation: 10,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
