import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({super.key});

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadLocation();
  }

  Future<void> _checkPermissionAndLoadLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission denied. Please enable it in settings.',
          ),
        ),
      );
      setState(() => _permissionGranted = false);
      return;
    }

    setState(() => _permissionGranted = true);
    await _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(position.latitude, position.longitude);
      setState(() => _currentLocation = loc);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(loc, 16),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    if (_currentLocation == null) return {};
    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(24.921587, 91.831177),
          zoom: 14,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: _permissionGranted,
        myLocationButtonEnabled: _permissionGranted,
        compassEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
          if (_currentLocation != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLocation!, 16),
            );
          }
        },
      ),
    );
  }
}
