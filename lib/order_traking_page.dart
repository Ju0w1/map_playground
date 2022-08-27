import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_playground/constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(-32.70212967082871, -57.627824293679964);
  static const LatLng destination =
      LatLng(-32.702973805017194, -57.62697671563423);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    } else {
      print("no points");
    }
  }

  @override
  void initState() {
    getPolyPoints();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mapeoide",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? Center(
              child: Text("Cargando..."),
            )
          : Center(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 14.5,
                ),
                polylines: {
                  Polyline(
                    polylineId: PolylineId("Route"),
                    points: polylineCoordinates,
                    color: primaryColor,
                  ),
                },
                markers: {
                  Marker(
                    markerId: MarkerId("Yo"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                  ),
                  Marker(
                    markerId: MarkerId("Casa"),
                    position: sourceLocation,
                  ),
                  Marker(
                    markerId: MarkerId("Liceo"),
                    position: destination,
                  ),
                },
              ),
            ),
    );
  }
}
