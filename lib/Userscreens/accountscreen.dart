import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jutcapp/screens/optionscreen.dart';

class Accountscreen extends StatefulWidget {
  const Accountscreen({Key? key}) : super(key: key);

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name'];
        });
      }
    }
  }

  // Function to handle logout
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged out'),
          duration: Duration(seconds: 2),
        ),
       );
      // Navigate to your login screen after logout
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Optionscreen()), // Direct reference to the options screen
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Passenger',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  titleTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  title: const Center(child: Text('Contact Support')),
                                  content: const Text(
                                      'If you would like to edit your profile image, Please contact support.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      )),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Add your action logic here
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: const Text('OK', style: TextStyle(color: Colors.black),),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/pfpholder.jpg'),
                              ),
                            ),
                          ),
                        ),
                      ]),
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
                      title: const Text('Card'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Add your card logic here
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
              onPressed: _signOut, // Call _signOut function to logout
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
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
