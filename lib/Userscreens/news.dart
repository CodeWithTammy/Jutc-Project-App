// Import necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Define a StatefulWidget named News
class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

// Define the state for the News widget
class _NewsState extends State<News> {
  // Reference to the 'News' collection in Firestore
  final CollectionReference newsData = FirebaseFirestore.instance.collection('News');
  String searchQuery = ''; // String to store the search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white

      // AppBar configuration
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 225, 0),
        centerTitle: true,
        title: const Text(
          'JUTC News Release',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      // Body configuration
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase(); // Update search query state
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search by headlines',
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // StreamBuilder to fetch and display news data from Firestore
            StreamBuilder(
              stream: newsData.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  // Filter documents based on the search query
                  final filteredDocs = streamSnapshot.data!.docs.where((doc) {
                    return doc['headline'].toString().toLowerCase().contains(searchQuery);
                  }).toList();

                  // Display message if no news found
                  if (filteredDocs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/notfound.png', // Path to 'not found' image
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No news found',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Display list of news articles
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = filteredDocs[index];
                      return Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Card(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              elevation: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                              // GestureDetector to handle news card tap
                              child: GestureDetector(
                                onTap: () {
                                  // Launch the URL of the news article
                                  launchUrl(Uri.parse(documentSnapshot['url']));
                                },
                                child: SizedBox(
                                  height: 430,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Display the news image
                                      Container(
                                        height: 220,
                                        width: 400,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(documentSnapshot['img']),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 350,
                                        child: Column(
                                          children: [
                                            // Display the news headline
                                            Text(
                                              documentSnapshot['headline'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Display a brief paragraph of the news
                                            Text(
                                              documentSnapshot['para'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromARGB(255, 112, 112, 112),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Text prompting the user to click to read more
                                            const Text(
                                              'Click to read more',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontStyle: FontStyle.italic,
                                                color: Color.fromARGB(255, 143, 143, 143),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      );
                    },
                  );
                }
                // Show loading indicator while waiting for data
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
