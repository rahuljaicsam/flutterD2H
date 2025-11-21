import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/booking_list_screen.dart';
import '../screens/booking/booking_detail_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/map/live_map_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class Doctor2HomeProviderApp extends StatelessWidget {
  const Doctor2HomeProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
          title: 'Doctor2Home Provider',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black87,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          routerConfig: GoRouter(
            initialLocation: '/splash',
            redirect: (context, state) {
              final isAuthenticated = authProvider.isAuthenticated;
              final isAuthRoute = state.uri.toString().startsWith('/auth');
              final isSplashRoute = state.uri.toString() == '/splash';
              
              if (isSplashRoute) return null;
              if (!isAuthenticated && !isAuthRoute) return '/auth/login';
              if (isAuthenticated && isAuthRoute) return '/home';
              return null;
            },
            routes: [
              GoRoute(
                path: '/splash',
                builder: (context, state) => const SplashScreen(),
              ),
              GoRoute(
                path: '/auth',
                builder: (context, state) => const LoginScreen(),
                routes: [
                  GoRoute(
                    path: '/login',
                    builder: (context, state) => const LoginScreen(),
                  ),
                  GoRoute(
                    path: '/register',
                    builder: (context, state) => const RegisterScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const MainScreen(),
                routes: [
                  GoRoute(
                    path: '/bookings',
                    builder: (context, state) => const BookingListScreen(),
                    routes: [
                      GoRoute(
                        path: '/:bookingId',
                        builder: (context, state) => BookingDetailScreen(
                          bookingId: state.pathParameters['bookingId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/wallet',
                    builder: (context, state) => const WalletScreen(),
                  ),
                  GoRoute(
                    path: '/profile',
                    builder: (context, state) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: '/map',
                    builder: (context, state) => const LiveMapScreen(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const BookingListScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
