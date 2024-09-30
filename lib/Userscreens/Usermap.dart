// Import necessary packages for the app
import 'package:flutter/cupertino.dart'; // Import for Cupertino styled widgets
import 'package:flutter/material.dart'; // Import for Material design widgets
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import for Google Maps integration
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore database
import 'package:geolocator/geolocator.dart'; // Import for Geolocation
import 'dart:async'; // Import for async programming
import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'package:uuid/uuid.dart'; // Import for generating unique IDs

// Usermap StatefulWidget to manage the state of the Usermap screen
class Usermap extends StatefulWidget {
  final String routeName; // Route name passed to the widget
  const Usermap({super.key, required this.routeName});

  @override
  _UsermapState createState() => _UsermapState(); // Create the state for the widget
}

// State class for Usermap
class _UsermapState extends State<Usermap> {
  final Completer<GoogleMapController> _controller = Completer(); // Controller to manage Google Map
  final Set<Polyline> _polylines = {}; // Set to store map polylines
  final List<LatLng> _routePoints = []; // List to store route points
  final Set<Marker> _markers = {}; // Set to store map markers
  final bool _isOnline = false; // Flag to check if the user is online
  late StreamSubscription<Position> _positionStream; // Stream subscription for position updates
  final TextEditingController _destinationController = TextEditingController(); // Controller for destination input
  final List<dynamic> _searchResults = []; // List to store search results
  final String _sessionToken = const Uuid().v4(); // Unique session token for API requests

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get the current location when the widget is initialized
  }

  // Function to get the current location of the user
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentPos = LatLng(position.latitude, position.longitude);
    setState(() {
      // Add a marker for the current position
      _markers.add(Marker(
        markerId: const MarkerId('currentPos'),
        position: currentPos,
        infoWindow: const InfoWindow(title: "Driver's Location"),
      ));
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(currentPos)); // Move the camera to the current position
  }

  // Function to start tracking the user's location
  void _startTracking() {
    _positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        // Update the marker for the current position
        _markers.removeWhere((marker) => marker.markerId == const MarkerId('currentPos'));
        _markers.add(Marker(
          markerId: const MarkerId('currentPos'),
          position: newPosition,
          infoWindow: const InfoWindow(title: "Driver's Location"),
        ));
        if (_isOnline) {
          // Update Firestore with the new location if the user is online
          FirebaseFirestore.instance.collection('drivers').doc(FirebaseAuth.instance.currentUser?.uid).set({
            'location': GeoPoint(position.latitude, position.longitude),
            'isOnline': _isOnline,
          });
        }
      });
    });
  }

  // Function to show a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to add a point to the route
  void _addRoutePoint(LatLng point) {
    setState(() {
      _routePoints.add(point); // Add the point to the route
      _polylines.add(Polyline(polylineId: const PolylineId('route'), points: _routePoints, color: Colors.blue)); // Update the polyline
    });
  }

  // Function to get the latitude and longitude of a place using its place ID
  Future<LatLng> _getPlaceLatLng(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=APIKEY';
    http.Response response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      var location = jsonDecode(response.body)['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      _showSnackBar('Failed to load place details');
      return const LatLng(0, 0);
    }
  }

  // UI Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of the scaffold
      
      appBar: AppBar(
        backgroundColor: Colors.amber, // Background color of the app bar
        title: Text(widget.routeName, 
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true, // Center the title
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller); // Complete the map controller
                },
                initialCameraPosition: const CameraPosition(target: LatLng(18.1096, -77.2975), zoom: 10), // Initial camera position
                markers: _markers, // Set of markers to be displayed
                polylines: _polylines, // Set of polylines to be displayed
                onTap: _addRoutePoint, // Add route point on map tap
              ),
            ),
          ),
          const SizedBox(height: 50,), // Sized box for spacing
          Card(
            elevation: 20,
            color: const Color.fromARGB(255, 244, 244, 244), // Card background color
            child: Container(
              width: 500,
              height: 150,
              padding: const EdgeInsets.all(10), // Padding inside the container
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bus is Online',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Icon(Icons.online_prediction, color: Colors.green,) // Icon to indicate online status
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Text(
                            'Arrival Time:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                          Text(
                            '34 mins',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Text(
                            'Kilometres: ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 104, 104, 104),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text(
                            '64',
                            style: TextStyle(
                              color: Color.fromARGB(255, 104, 104, 104),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStream.cancel(); // Cancel the position stream when the widget is disposed
    super.dispose();
  }
}
