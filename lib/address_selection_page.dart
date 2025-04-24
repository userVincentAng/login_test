import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AddressSelectionPage extends StatefulWidget {
  final Position? initialPosition;
  final Future<void> Function(LatLng, String) onAddressSelected;

  const AddressSelectionPage({
    super.key,
    this.initialPosition,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final String _apiKey = 'AIzaSyC8qxLFU-_pwQlCwGR-S_HBUB0dv792oiU';

  bool get _isWindows => !kIsWeb && Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&types=address'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _searchResults =
                List<Map<String, dynamic>>.from(data['predictions']);
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${result['place_id']}&key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final latLng = LatLng(location['lat'], location['lng']);
          final address = data['result']['formatted_address'];

          setState(() {
            _selectedLocation = latLng;
            _selectedAddress = address;
            _searchResults = [];
            _searchController.clear();
          });

          if (!_isWindows) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(latLng, 15),
            );
          }
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
  }

  Future<void> _initializeMap() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        Position position;
        if (widget.initialPosition != null) {
          position = widget.initialPosition!;
        } else {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _getAddressFromLatLng(_selectedLocation!);
      } else {
        setState(() {
          _errorMessage = 'Location permission is required';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          if (mounted) {
            setState(() {
              _selectedAddress = address;
            });
          }
        }
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_selectedLocation != null && !_isWindows) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _searchLocation,
                      ),
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (_searchResults.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(result['description'] ?? ''),
                              onTap: () => _selectSearchResult(result),
                            );
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: Stack(
                          children: [
                            if (_isWindows)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.map,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Map view is not available on Windows',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Selected Location:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedAddress.isEmpty
                                          ? 'No location selected'
                                          : _selectedAddress,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _selectedLocation!,
                                  zoom: 15,
                                ),
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                                onTap: (position) {
                                  setState(() {
                                    _selectedLocation = position;
                                  });
                                  _getAddressFromLatLng(position);
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                markers: _selectedLocation != null
                                    ? {
                                        Marker(
                                          markerId: const MarkerId(
                                              'selected_location'),
                                          position: _selectedLocation!,
                                        ),
                                      }
                                    : {},
                              ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: ElevatedButton(
                                onPressed: _selectedLocation != null
                                    ? () {
                                        widget.onAddressSelected(
                                            _selectedLocation!,
                                            _selectedAddress);
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: const Text('Select Location'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
