import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  List<Booking> _activeBookings = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadActiveBookings();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadActiveBookings() {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    setState(() {
      _activeBookings = bookingProvider.getUpcomingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getCurrentLocation();
              _loadActiveBookings();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(40.7128, -74.0060),
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.doctor2homeprovider',
                    ),
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _activeBookings.map((booking) {
                        final patientLocation = _parseLocation(booking.patientLocation);
                        if (patientLocation == null) return null;
                        
                        return Marker(
                          point: patientLocation,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showBookingDetails(booking),
                            child: Container(
                              decoration: BoxDecoration(
                                color: booking.status == BookingStatus.accepted 
                                    ? Colors.green 
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      }).where((marker) => marker != null).cast<Marker>().toList(),
                    ),
                    PolylineLayer(
                      polylines: _activeBookings.map((booking) {
                        final patientLocation = _parseLocation(booking.patientLocation);
                        if (patientLocation == null || _currentLocation == null) return null;
                        
                        return Polyline(
                          points: [_currentLocation!, patientLocation],
                          strokeWidth: 3.0,
                          color: booking.status == BookingStatus.accepted 
                              ? Colors.green.withOpacity(0.7)
                              : Colors.orange.withOpacity(0.7),
                        );
                      }).where((polyline) => polyline != null).cast<Polyline>().toList(),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Bookings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_activeBookings.isEmpty)
                          const Text(
                            'No active bookings',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ..._activeBookings.take(3).map((booking) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: booking.status == BookingStatus.accepted 
                                            ? Colors.green 
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${booking.patientName} - ${booking.service}',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${booking.scheduledDate.hour}:${booking.scheduledDate.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  LatLng? _parseLocation(Map<String, dynamic>? locationData) {
    if (locationData == null) return null;
    
    final latitude = locationData['latitude'] as double?;
    final longitude = locationData['longitude'] as double?;
    
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    
    return null;
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: booking.status.color.withOpacity(0.1),
                  child: Icon(
                    booking.status == BookingStatus.accepted 
                        ? Icons.check_circle 
                        : Icons.pending,
                    color: booking.status.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking.service,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${booking.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Time', '${booking.scheduledDate.hour}:${booking.scheduledDate.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Address', booking.address),
            if (booking.patientPhone.isNotEmpty)
              _buildDetailRow('Phone', booking.patientPhone),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _buildDetailRow('Notes', booking.notes!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to booking details
                      context.go('/home/bookings/${booking.id}');
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to patient location
                      final patientLocation = _parseLocation(booking.patientLocation);
                      if (patientLocation != null) {
                        _mapController.move(patientLocation, 16.0);
                      }
                    },
                    child: const Text('Navigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
