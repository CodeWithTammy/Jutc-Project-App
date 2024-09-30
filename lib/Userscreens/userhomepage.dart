// Import necessary packages for Firebase, UI components, and other functionalities
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jutcapp/Userscreens/Usermap.dart';
import 'package:jutcapp/Utils/drawer.dart';

import '../Utils/navigationmenu.dart';

// Define the main class for the user homepage screen
class Userhomepage extends StatefulWidget {
  const Userhomepage({super.key});

  @override
  State<Userhomepage> createState() => _UserhomepageState();
}

class _UserhomepageState extends State<Userhomepage> {
  final controller = Get.put(NavigationController()); // Navigation controller
  final CollectionReference busRouteData =
      FirebaseFirestore.instance.collection('Busroutedata'); // Reference to Firestore collection
  String searchQuery = ''; // Variable to hold the search query
  String userName = 'User'; // Default user name

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch user name on initialization
  }

  // Function to fetch user name from Firestore
  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name']; // Update user name state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navdrawer(controller: controller), // Navigation drawer
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 225, 0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill, color: Colors.black),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        title: const Text(
          'JUTC',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),

      // Body
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Circle shape background image
                ClipPath(
                  clipper: OvalClipper(),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.darken),
                    child: Container(
                      height: 260,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/jutcbg.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Greeting text
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey $userName!',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 1), // Add some space between the texts
                      const Text(
                        'Where do you want to go?',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              'Portmore Bus Routes',
              style: TextStyle(
                fontSize: 21,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase(); // Update search query state
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search by route',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            StreamBuilder(
              stream: busRouteData.snapshots(), // Stream to listen to bus route data
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  final filteredDocs = streamSnapshot.data!.docs.where((doc) {
                    return doc['routename']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery) ||
                        doc['depart']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery) ||
                        doc['to']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery);
                  }).toList();

                  // Check if any routes match the search query
                  if (filteredDocs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/notfound.png', // Add your image asset path
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No routes found',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          filteredDocs[index];
                      return Material(
                        color: Colors.white,
                        child: Card(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Container(
                            padding: const EdgeInsets.all(8),

                            // Parent Column
                            child: Column(
                              children: [
                                // Row for the route text and button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Route text
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 1, right: 8),
                                              child: Text(
                                                documentSnapshot['routename'],
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 90),
                                            // Button to navigate to the route map
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 30),
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Iconsax.arrow_right_3,
                                                  color: Colors.white,
                                                ),
                                                iconAlignment:
                                                    IconAlignment.end,
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Usermap(
                                                                routeName:
                                                                    "#${documentSnapshot['routename']} BUS ROUTE",
                                                              )));
                                                },
                                                label: Text(
                                                  documentSnapshot['text'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Row for depart and to text
                                Row(
                                  children: [
                                    const SizedBox(height: 10),
                                    // Depart text
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 28, right: 20),
                                      child: Text(
                                        documentSnapshot['depart'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // To text
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 20),
                                      child: Text(
                                        documentSnapshot['to'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(), // Loading indicator
                );
              },
            ),
            // Text at the bottom of the page
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'You\'ve reached the end of the page.',
                style: TextStyle(
                  color: Color.fromARGB(255, 167, 167, 167),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Class to shape the oval clip for the background image
class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 150);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
