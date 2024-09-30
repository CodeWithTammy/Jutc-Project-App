// Importing necessary packages for Flutter app, Google Maps, Firebase, and other functionalities
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jutcapp/driver/driverdrawer.dart';
import 'package:uuid/uuid.dart';

import '../Utils/drivernavmenu.dart';

// Stateful widget for the DriverMapScreen
class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  _DriverMapScreenState createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  // Initialize controller for navigation and other necessary variables
  final controller = Get.put(DriverNavigationController());
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];
  final Set<Marker> _markers = {};
  bool _isOnline = false;
  late StreamSubscription<Position> _positionStream;
  TextEditingController _destinationController = TextEditingController();
  List<dynamic> _searchResults = [];
  String _sessionToken = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    // Get current location when the widget is initialized
    _getCurrentLocation();
  }

  // Function to get the current location of the driver
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentPos = LatLng(position.latitude, position.longitude);
    setState(() {
      // Add marker for the current position
      _markers.add(Marker(
        markerId: const MarkerId('currentPos'),
        position: currentPos,
        infoWindow: const InfoWindow(title: "Driver's Location"),
      ));
    });
    // Move the camera to the current position on the map
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(currentPos));
  }

  // Function to start tracking the driver's position
  void _startTracking() {
    _positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        // Update marker for the current position
        _markers.removeWhere((marker) => marker.markerId == const MarkerId('currentPos'));
        _markers.add(Marker(
          markerId: const MarkerId('currentPos'),
          position: newPosition,
          infoWindow: const InfoWindow(title: "Driver's Location"),
        ));
        if (_isOnline) {
          // Update the driver's location in Firestore
          FirebaseFirestore.instance.collection('drivers').doc(FirebaseAuth.instance.currentUser?.uid).set({
            'location': GeoPoint(position.latitude, position.longitude),
            'isOnline': _isOnline,
          });
        }
      });
    });
  }

  // Function to toggle the online status of the driver
  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline) {
        // Start tracking and show online status message
        _startTracking();
        _showSnackBar('You are now online');
      } else {
        // Stop tracking and show offline status message
        _positionStream.cancel();
        setState(() {
          _markers.clear();
          _showSnackBar('You are now offline');
        });
        FirebaseFirestore.instance.collection('drivers').doc(FirebaseAuth.instance.currentUser?.uid).update({
          'isOnline': false,
        });
      }
    });
  }

  // Function to show a SnackBar with a message
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
      _routePoints.add(point);
      _polylines.add(Polyline(polylineId: const PolylineId('route'), points: _routePoints, color: Colors.blue));
    });
  }

  // Function to calculate the route between the current position and a destination
  Future<void> _calculateRoute(LatLng destination) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng origin = LatLng(position.latitude, position.longitude);

    // API call to Google Directions API
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=YOUR_API_KEY';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String encodedPoints = data['routes'][0]['overview_polyline']['points'];
      List<LatLng> polylinePoints = _decodePolyline(encodedPoints);

      setState(() {
        _routePoints.clear();
        _polylines.clear();
        _routePoints.addAll(polylinePoints);
        _polylines.add(Polyline(polylineId: const PolylineId('route'), points: _routePoints, color: Colors.blue));
      });
    } else {
      _showSnackBar('Failed to load route');
    }
  }

  // Function to decode polyline points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  // Function to search for places using the Google Places API
  Future<void> _searchPlaces(String input) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=YOUR_API_KEY&sessiontoken=$_sessionToken';
    http.Response response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = jsonDecode(response.body)['predictions'];
      });
    } else {
      _showSnackBar('Failed to load places');
    }
  }

  // Function to get the latitude and longitude of a place using the Google Places API
  Future<LatLng> _getPlaceLatLng(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=YOUR_API_KEY';
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
      drawer: DriverDrawer(controller: controller),
      
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('JUTC Driver', 
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.toggle_on : Icons.toggle_off),
            onPressed: _toggleOnlineStatus,
            color: Colors.white,
            iconSize: 50,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPlaces(_destinationController.text);
                  },
                ),
              ),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index]['description']),
                    onTap: () async {
                      LatLng destination = await _getPlaceLatLng(_searchResults[index]['place_id']);
                      _calculateRoute(destination);
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  );
                },
              ),
            ),
          if (_searchResults.isEmpty)
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                initialCameraPosition: const CameraPosition(target: LatLng(18.1096, -77.2975), zoom: 10),
                markers: _markers,
                polylines: _polylines,
                onTap: _addRoutePoint,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }
}
