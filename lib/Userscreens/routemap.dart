import 'dart:async'; // Importing dart:async package for Completer functionality

import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importing Google Maps package for map integration
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore package for database integration

// StatefulWidget to manage the state of the UserMapScreen
class UserMapScreen extends StatefulWidget {
  const UserMapScreen({super.key});

  @override
  _UserMapScreenState createState() => _UserMapScreenState();
}

// State class for UserMapScreen
class _UserMapScreenState extends State<UserMapScreen> {
  final Completer<GoogleMapController> _controller = Completer(); // Controller to manage Google Map
  final Set<Marker> _markers = {}; // Set to store map markers

  @override
  void initState() {
    super.initState();
    _listenToDriverUpdates(); // Initialize the listener for driver updates
  }

  // Function to listen to real-time updates from Firestore for driver locations
  void _listenToDriverUpdates() {
    FirebaseFirestore.instance.collection('drivers').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        GeoPoint geoPoint = doc['location']; // Getting driver's location
        LatLng driverPosition = LatLng(geoPoint.latitude, geoPoint.longitude); // Converting to LatLng
        bool isOnline = doc['isOnline']; // Checking if the driver is online
        setState(() {
          if (isOnline) {
            // Adding marker for online drivers
            _markers.add(Marker(markerId: MarkerId(doc.id), position: driverPosition));
          } else {
            // Removing marker for offline drivers
            _markers.removeWhere((marker) => marker.markerId.value == doc.id);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Map')), // AppBar with title
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller); // Completing the controller when map is created
        },
        initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 10), // Initial camera position
        markers: _markers, // Markers to be displayed on the map
      ),
    );
  }
}
