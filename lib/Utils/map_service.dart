import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jutcapp/constant/google_map_key.dart';
import 'package:jutcapp/model/drivermodel.dart';
import 'dart:typed_data';
import 'package:jutcapp/ui/driverinfowindow.dart';
import 'package:jutcapp/ui/drivercustomwindow.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jutcapp/Utils/code_generator.dart';
import 'package:jutcapp/images/images.dart';

class MapService {
  MapService._();

  static MapService? _instance;

  static MapService? get instance {
    _instance ??= MapService._();
    return _instance;
  }

  final String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";

  Duration duration = const Duration();

  ValueNotifier<LatLng?>? currentPosition = ValueNotifier<LatLng?>(null);
  ValueNotifier<Set<Marker>> markers = ValueNotifier<Set<Marker>>({});

  CustomInfoWindowController controller = CustomInfoWindowController();

  Set<Marker?> addMarker(
      String markerId, LatLng? position, BitmapDescriptor icon,
      {required String title,
      required DateTime time,
      required InfoWindowType type}) {
    if (position != null) {
      final marker = Marker(
          markerId: MarkerId(markerId),
          position: position,
          icon: icon,
          onTap: () {
            controller.addInfoWindow!(
              CustomWindow(
                  info: Drivermodel(
                name: title,
                position: position,
                type: type,
                time: duration,
              )),
              position,
            );
          });
      try {
        final markerPosition = markers.value
            .firstWhere((markers) => marker.markerId.value == markerId);
        markerPosition.copyWith(
            positionParam: LatLng(position.latitude, position.longitude));
        return markers.value;
      } catch (e) {
        markers.value.add(marker);
        return markers.value;
      }
    } else {
      return markers.value;
    }
  }

Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

   Future<double> getPositionBetweenKilometers(LatLng startLatLng, LatLng endLatLng) async {
    final meters = Geolocator.distanceBetween(
        startLatLng.latitude, startLatLng.longitude, endLatLng.latitude, endLatLng.longitude);
    return meters / 500;
  }

  Future<Placemark> getAddressFromCoordinate(LatLng position) async{
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.first;
  }

  Future<LatLng?> getCurrentPosition() async{
    final check = await requestAndCheckPermission();
        if (check) {
         Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
         currentPosition?.value = LatLng(position.latitude, position.longitude);

         final Placemark placemark = await getAddressFromCoordinate(LatLng(position.latitude, position.longitude));
         final Uint8List markerIcon =  await getBytesFromAsset(ImagesModel.pin, 50);
         final icon = BitmapDescriptor.fromBytes(markerIcon);
         addMarker(CodeGenerator.instance!.generateCode('m'), currentPosition!.value, 
         icon, title: '${placemark.street},${placemark.locality}',
          time: DateTime.now(), type: InfoWindowType.position);
          return currentPosition?.value;
  }else{
    return null;
  }

}

Future<bool> requestAndCheckPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final request = await Geolocator.requestPermission();
      if (request == LocationPermission.always) {
        return true;
      } else {
        return false;
      }
    } else if (permission == LocationPermission.always) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<PointLatLng>> getRouteCoordinates(LatLng? startLatLng, LatLng? endLatLng) async {
    markers.value.clear();

    var uri = Uri.parse(
        "$baseUrl?origin=${startLatLng?.latitude},${startLatLng?.longitude}&destination=${endLatLng?.latitude},${endLatLng?.longitude}&key=${GoogleMapKey.key}");
    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);
    final points = values['routes'][0]['overview_polyline']['points'];
    final legs = values['routes'][0]['legs'];
  
    if (legs != null) {
      final DateTime time = DateTime.fromMillisecondsSinceEpoch(values['routes'][0]['legs'][0]['duration']['value']);
      duration = DateTime.now().difference(time);
    }
    final name = await getAddressFromCoordinate(LatLng(endLatLng!.latitude, endLatLng.longitude));
    final polylines = PolylinePoints().decodePolyline(points);
    final Uint8List markerIcon = await getBytesFromAsset(ImagesModel.circlePin, 50);
    final icon = BitmapDescriptor.fromBytes(markerIcon);
    addMarker(CodeGenerator.instance!.generateCode('m'), endLatLng, icon, 
    title: '${name.street}, ${name.locality}', time: DateTime.now(), type: InfoWindowType.destination);
    return polylines;
  }

    Stream<void> listenToPositionChanges() async* {
    final check = await requestAndCheckPermission();
    if (check) {
      Stream<Position> position = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ));
    position.listen((position){
      try{
        final currentPositionMarker = markers.value.firstWhere((marker)=> marker.markerId.value =='m1');
        currentPositionMarker.copyWith(positionParam: LatLng(position.latitude,position.longitude));
      }catch(_){}
      currentPosition?.value = LatLng(position.latitude, position.longitude);
    });
    }
  }



}