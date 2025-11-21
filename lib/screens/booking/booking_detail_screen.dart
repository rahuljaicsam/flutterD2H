import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/wallet_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Booking? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final booking = await bookingProvider.getBookingById(widget.bookingId);
    
    setState(() {
      _booking = booking;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(
          child: Text('Booking not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (_booking!.status == BookingStatus.accepted)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startBooking,
            ),
          if (_booking!.status == BookingStatus.inProgress)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _completeBooking,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildPatientInfo(),
            const SizedBox(height: 20),
            _buildServiceInfo(),
            const SizedBox(height: 20),
            _buildScheduleInfo(),
            const SizedBox(height: 20),
            _buildLocationInfo(),
            const SizedBox(height: 20),
            if (_booking!.notes != null && _booking!.notes!.isNotEmpty)
              _buildNotesSection(),
            if (_booking!.status == BookingStatus.accepted ||
                _booking!.status == BookingStatus.inProgress)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _booking!.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _booking!.status.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _booking!.status.color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                _booking!.status.displayName,
                style: TextStyle(
                  color: _booking!.status.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${_booking!.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return _buildInfoCard(
      'Patient Information',
      Icons.person,
      [
        _buildInfoRow('Name', _booking!.patientName),
        _buildInfoRow('Phone', _booking!.patientPhone, isPhone: true),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return _buildInfoCard(
      'Service Information',
      Icons.medical_services,
      [
        _buildInfoRow('Service', _booking!.service),
        _buildInfoRow('Provider Type', _booking!.providerType.displayName),
      ],
    );
  }

  Widget _buildScheduleInfo() {
    return _buildInfoCard(
      'Schedule Information',
      Icons.schedule,
      [
        _buildInfoRow(
          'Date',
          '${_booking!.scheduledDate.day}/${_booking!.scheduledDate.month}/${_booking!.scheduledDate.year}',
        ),
        _buildInfoRow(
          'Time',
          '${_booking!.scheduledDate.hour.toString().padLeft(2, '0')}:${_booking!.scheduledDate.minute.toString().padLeft(2, '0')}',
        ),
        _buildInfoRow(
          'Booked On',
          '${_booking!.createdAt.day}/${_booking!.createdAt.month}/${_booking!.createdAt.year}',
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _buildInfoCard(
      'Location',
      Icons.location_on,
      [
        _buildInfoRow('Address', _booking!.address),
        _buildInfoRow('Map', 'View on map', isMap: true),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Text(
            _booking!.notes!,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPhone = false, bool isMap = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isPhone
                ? GestureDetector(
                    onTap: () => _launchPhone(value),
                    child: Row(
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.phone, size: 16, color: Color(0xFF4A90E2)),
                      ],
                    ),
                  )
                : isMap
                    ? GestureDetector(
                        onTap: () => _launchMap(),
                        child: Row(
                          children: [
                            Text(
                              value,
                              style: const TextStyle(
                                color: Color(0xFF4A90E2),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.map, size: 16, color: Color(0xFF4A90E2)),
                          ],
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (_booking!.status == BookingStatus.accepted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startBooking,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Visit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (_booking!.status == BookingStatus.inProgress)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _completeBooking,
              icon: const Icon(Icons.check),
              label: const Text('Complete Visit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (_booking!.status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.accepted:
        return Icons.check_circle;
      case BookingStatus.declined:
        return Icons.cancel;
      case BookingStatus.inProgress:
        return Icons.play_arrow;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchMap() async {
    final Uri mapUri = Uri(
      scheme: 'https',
      host: 'www.openstreetmap.org',
      path: '/search',
      queryParameters: {'query': _booking!.address},
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    }
  }

  Future<void> _startBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.startBooking(_booking!.id);
    
    if (success) {
      await _loadBookingDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit started!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.errorMessage ?? 'Failed to start visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    final success = await bookingProvider.completeBooking(_booking!.id);
    
    if (success) {
      await walletProvider.addPaymentFromBooking(_booking!);
      await _loadBookingDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit completed! Payment added to wallet.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.errorMessage ?? 'Failed to complete visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
