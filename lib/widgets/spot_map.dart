import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SpotMapPage extends StatefulWidget {
  const SpotMapPage({super.key});

  @override
  State<SpotMapPage> createState() => _SpotMapPageState();
}

class _SpotMapPageState extends State<SpotMapPage> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _locationPermissionGranted = false;

  final List<Map<String, dynamic>> _spotLocations = [
    {
      "name": "Auditorium",
      "position": const LatLng(24.924111187420493, 91.83271025646836),
    },
    {
      "name": "Central Field",
      "position": const LatLng(24.92324787292172, 91.83490979812855),
    },
    {
      "name": "Mini Auditorium",
      "position": const LatLng(24.920561565205666, 91.83302401287621),
    },
    {
      "name": "Basketball Ground",
      "position": const LatLng(24.92288479657054, 91.83299783473528),
    },
    {
      "name": "Handball Ground",
      "position": const LatLng(24.9198249075342, 91.83234025407775),
    },
  ];

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
                'Location permissions are denied. Please enable them in settings.')),
      );
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    await _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = latLng;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    for (var spot in _spotLocations) {
      markers.add(Marker(
        markerId: MarkerId(spot['name']),
        position: spot['position'],
        infoWindow: InfoWindow(title: spot['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    if (_userLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('MyLocation'),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Location & Spots",
            style: TextStyle(fontFamily: 'Urbanist')),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(24.921587, 91.831177),
          zoom: 16,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          if (_userLocation != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_userLocation!, 16),
            );
          }
        },
        markers: _buildMarkers(),
        myLocationEnabled: _locationPermissionGranted,
        myLocationButtonEnabled: _locationPermissionGranted,
        compassEnabled: true,
      ),
    );
  }
}
