import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import 'booking_card.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BookingStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(
                bookingProvider.pendingBookings,
                bookingProvider.isLoading,
                'No pending bookings',
              ),
              _buildBookingsList(
                bookingProvider.getUpcomingBookings(),
                bookingProvider.isLoading,
                'No upcoming bookings',
              ),
              _buildBookingsList(
                bookingProvider.getBookingsByStatus(BookingStatus.completed) +
                    bookingProvider
                        .getBookingsByStatus(BookingStatus.cancelled) +
                    bookingProvider.getBookingsByStatus(BookingStatus.declined),
                bookingProvider.isLoading,
                'No booking history',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(
      List<Booking> bookings, bool isLoading, String emptyMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final bookingProvider =
            Provider.of<BookingProvider>(context, listen: false);
        await bookingProvider.refreshBookings();
        return;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                context.go('/home/bookings/${booking.id}');
              },
              child: BookingCard(booking: booking),
            ),
          );
        },
      ),
    );
  }
}
