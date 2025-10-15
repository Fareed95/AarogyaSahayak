import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HospitalFinderMaps extends StatefulWidget {
  const HospitalFinderMaps({Key? key}) : super(key: key);

  @override
  State<HospitalFinderMaps> createState() => _HospitalFinderMapsState();
}

class _HospitalFinderMapsState extends State<HospitalFinderMaps> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = const LatLng(28.6139, 77.2090); // Default to Delhi

  Marker? _currentMarker;
  Marker? _destinationMarker;
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _routeDistance;
  String? _routeDuration;
  List<HospitalPlace> _nearbyHospitals = [];
  bool _showHospitalsPanel = false;
  String _locationStatus = 'Getting your location...';

  final String _apiKey = "AIzaSyBjGnUOS3z31gzKMEIviEPgJ-NW82llM9o"; // Replace with your actual API key

  // Hospital categories
  final List<Map<String, dynamic>> _hospitalCategories = [
    {
      'icon': Icons.local_hospital,
      'name': 'All Hospitals',
      'keyword': 'hospital'
    },
    {
      'icon': Icons.emergency,
      'name': 'Emergency',
      'keyword': 'emergency hospital'
    },
    {
      'icon': Icons.family_restroom,
      'name': 'Children',
      'keyword': 'children hospital'
    },
    {
      'icon': Icons.heart_broken,
      'name': 'Cardiac',
      'keyword': 'cardiac hospital'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Delay slightly to ensure map is loaded
    await Future.delayed(const Duration(milliseconds: 500));
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Checking location permissions...';
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services are disabled. Please enable them.';
        });
        _showError('Location services are disabled');
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = 'Requesting location permission...';
        });

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permission denied';
          });
          _showError('Location permission is required to find nearby hospitals');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permission permanently denied';
        });
        _showError('Location permission is permanently denied. Please enable it in app settings.');
        return;
      }

      setState(() {
        _locationStatus = 'Getting your current location...';
      });

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentMarker = Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'You are here'
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
        _locationStatus = 'Location found!';
      });

      // Move camera to current location
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );

      // Get nearby hospitals
      await _getNearbyHospitals(_currentLocation!);

    } catch (e) {
      print('Location error: $e');
      setState(() {
        _locationStatus = 'Failed to get location: $e';
      });
      _showError('Unable to get current location: $e');

      // Fallback: Use default location and show hospitals there
      await _useDefaultLocation();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _useDefaultLocation() async {
    setState(() {
      _currentLocation = _initialPosition;
      _currentMarker = Marker(
        markerId: const MarkerId('current'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(
            title: 'Default Location',
            snippet: 'Using default location'
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _locationStatus = 'Using default location';
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 12),
    );

    await _getNearbyHospitals(_currentLocation!);
  }

  Future<void> _getNearbyHospitals(LatLng location, {String? keyword}) async {
    setState(() => _isLoading = true);

    try {
      String query = keyword ?? 'hospital';

      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?'
              'query=$query'
              '&location=${location.latitude},${location.longitude}'
              '&radius=5000'
              '&key=$_apiKey'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _nearbyHospitals = (data['results'] as List)
                .take(12)
                .map((place) => HospitalPlace.fromJson(place))
                .toList();
            _showHospitalsPanel = true;
          });
        } else {
          print('Places API error: ${data['status']}');
          _showError('No hospitals found nearby. Status: ${data['status']}');
        }
      } else {
        _showError('Failed to load hospitals: ${response.statusCode}');
      }
    } catch (e) {
      print('Hospitals search error: $e');
      _showError('Error searching for hospitals: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchSpecificHospital(String keyword) async {
    if (_currentLocation == null) return;
    await _getNearbyHospitals(_currentLocation!, keyword: keyword);
  }

  Future<void> _setDestination(LatLng destination, String name) async {
    setState(() {
      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(title: name, snippet: 'Hospital'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    if (_currentLocation != null) {
      await _getRouteDirections(_currentLocation!, destination);
    }

    await _fitMapToRoute();
    setState(() => _showHospitalsPanel = false);
  }

  Future<void> _getRouteDirections(LatLng origin, LatLng destination) async {
    setState(() => _isLoading = true);

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final points = _decodePolyline(route['overview_polyline']['points']);

          final leg = route['legs'][0];
          final distance = leg['distance']['text'];
          final duration = leg['duration']['text'];

          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: Colors.red.shade600,
                width: 6,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            _routeDistance = distance;
            _routeDuration = duration;
          });
        } else {
          _showError('Route not found: ${data['status']}');
        }
      } else {
        _showError('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Route calculation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> _fitMapToRoute() async {
    if (_currentLocation != null && _destinationMarker != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentLocation!.latitude < _destinationMarker!.position.latitude
              ? _currentLocation!.latitude
              : _destinationMarker!.position.latitude,
          _currentLocation!.longitude < _destinationMarker!.position.longitude
              ? _currentLocation!.longitude
              : _destinationMarker!.position.longitude,
        ),
        northeast: LatLng(
          _currentLocation!.latitude > _destinationMarker!.position.latitude
              ? _currentLocation!.latitude
              : _destinationMarker!.position.latitude,
          _currentLocation!.longitude > _destinationMarker!.position.longitude
              ? _currentLocation!.longitude
              : _destinationMarker!.position.longitude,
        ),
      );

      await _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _destinationMarker = null;
      _polylines = {};
      _routeDistance = null;
      _routeDuration = null;
      _showHospitalsPanel = true;
    });
  }

  Widget _buildRouteInfo() {
    if (_routeDistance == null || _routeDuration == null) return Container();

    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(Icons.directions_car, _routeDistance!, 'Distance'),
            _buildInfoItem(Icons.access_time, _routeDuration!, 'Travel Time'),
            _buildInfoItem(Icons.local_hospital, 'Hospital', 'Destination'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.red.shade600, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red.shade700
            )),
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12
            )),
      ],
    );
  }

  Widget _buildHospitalsPanel() {
    if (!_showHospitalsPanel) return Container();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Nearby Hospitals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _getNearbyHospitals(_currentLocation ?? _initialPosition),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showHospitalsPanel = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _nearbyHospitals.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _nearbyHospitals.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final hospital = _nearbyHospitals[index];
                  return _buildHospitalCard(hospital);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hospitals found nearby',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _getNearbyHospitals(_currentLocation ?? _initialPosition),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(HospitalPlace hospital) {
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _setDestination(
            LatLng(hospital.geometry.location.lat, hospital.geometry.location.lng),
            hospital.name,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hospital.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hospital.vicinity != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    hospital.vicinity!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (hospital.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(hospital.rating.toString(), style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HOSPITAL',
                          style: TextStyle(color: Colors.red.shade800, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _setDestination(
                    LatLng(hospital.geometry.location.lat, hospital.geometry.location.lng),
                    hospital.name,
                  ),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _hospitalCategories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final category = _hospitalCategories[index];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category['name']),
                avatar: Icon(category['icon'], size: 18, color: Colors.red),
                onSelected: (_) => _searchSpecificHospital(category['keyword']),
                backgroundColor: Colors.white,
                selectedColor: Colors.red.shade100,
                elevation: 2,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {};
    if (_currentMarker != null) markers.add(_currentMarker!);
    if (_destinationMarker != null) markers.add(_destinationMarker!);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: Colors.red.shade600),
                  title: Text('Find hospitals near you...', style: TextStyle(color: Colors.grey.shade600)),
                  trailing: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                  onTap: () => _searchSpecificHospital('hospital'),
                ),
              ),
            ),
          ),

          // Location Status
          if (_isLoading)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _locationStatus,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Route Information
          if (_routeDistance != null) _buildRouteInfo(),

          // Category Chips
          if (_currentLocation != null) _buildCategoryChips(),

          // Hospitals Panel
          _buildHospitalsPanel(),

          // Loading Indicator
          if (_isLoading && _locationStatus.contains('hospitals'))
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Clear Route Button
          if (_destinationMarker != null)
            Positioned(
              bottom: _showHospitalsPanel ? 300 : 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _clearRoute,
                backgroundColor: Colors.red,
                child: const Icon(Icons.clear),
                mini: true,
              ),
            ),

          // Emergency Button
          Positioned(
            bottom: _showHospitalsPanel ? 300 : 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _searchSpecificHospital('emergency hospital'),
              backgroundColor: Colors.red,
              child: const Icon(Icons.emergency),
              mini: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Hospital Place model class
class HospitalPlace {
  final String name;
  final String? vicinity;
  final double? rating;
  final Geometry geometry;

  HospitalPlace({
    required this.name,
    this.vicinity,
    this.rating,
    required this.geometry,
  });

  factory HospitalPlace.fromJson(Map<String, dynamic> json) {
    return HospitalPlace(
      name: json['name'],
      vicinity: json['formatted_address'] ?? json['vicinity'],
      rating: json['rating']?.toDouble(),
      geometry: Geometry.fromJson(json['geometry']),
    );
  }
}

class Geometry {
  final Location location;

  Geometry({required this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }
}