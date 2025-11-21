import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../booking/booking_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              context.go('/home/map');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, BookingProvider>(
        builder: (context, authProvider, bookingProvider, child) {
          return RefreshIndicator(
          onRefresh: () async {
            await bookingProvider.refreshBookings();
          },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context, authProvider),
                  const SizedBox(height: 20),
                  _buildStatsCards(bookingProvider),
                  const SizedBox(height: 20),
                  _buildRecentBookings(context, bookingProvider),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: authProvider.provider?.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          authProvider.provider!.profileImageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.blue[600],
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      authProvider.provider?.name ?? 'Provider',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.provider?.type.displayName ?? 'Healthcare Provider',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (authProvider.provider?.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Rating',
                  '${authProvider.provider?.rating.toStringAsFixed(1) ?? '0.0'} ⭐',
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  '${authProvider.provider?.completedBookings ?? 0}',
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(BookingProvider bookingProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            'Pending',
            bookingProvider.pendingCount.toString(),
            Colors.orange,
            Icons.pending,
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            'Today',
            bookingProvider.todayCount.toString(),
            Colors.blue,
            Icons.today,
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            'Upcoming',
            bookingProvider.upcomingCount.toString(),
            Colors.green,
            Icons.upcoming,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context, BookingProvider bookingProvider) {
    final recentBookings = bookingProvider.pendingBookings.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/home/bookings');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        if (recentBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No pending bookings',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...recentBookings.map((booking) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookingCard(booking: booking),
              )),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Wallet',
                Icons.account_balance_wallet,
                Colors.green,
                () => context.go('/home/wallet'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Profile',
                Icons.person,
                Colors.blue,
                () => context.go('/home/profile'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Map',
                Icons.map,
                Colors.orange,
                () => context.go('/home/map'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('No new notifications'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
