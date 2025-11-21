# Doctor2Home Provider App

A Flutter mobile application for healthcare providers (doctors, nurses, and physiotherapists) to manage home referral bookings, track earnings, and provide real-time location services.

## Features

### 🔐 Authentication & Profile
- **Secure Registration**: Provider signup with license verification
- **Profile Management**: Update personal and professional information
- **License Verification**: Medical license verification status display
- **Profile Pictures**: Upload and manage provider profile images

### 📅 Booking Management
- **Real-time Notifications**: Instant alerts for new booking requests
- **Accept/Decline Bookings**: Quick action buttons for booking management
- **Booking Details**: Comprehensive view of patient information and service details
- **Booking Status Tracking**: Pending, Accepted, In Progress, Completed status
- **Booking History**: Complete history of all bookings with filters

### 💰 Wallet & Earnings
- **Earnings Dashboard**: Total earnings, available balance, and pending payments
- **Transaction History**: Detailed view of all payments and transactions
- **Monthly Analytics**: Visual representation of monthly earnings
- **Payment Status**: Track pending and completed payments

### 🗺️ Live Map Integration
- **OpenStreetMap Integration**: Real-time location tracking
- **Navigation Support**: Navigate to patient locations
- **Active Bookings Display**: Visual representation of active bookings on map
- **Route Planning**: Show routes to patient addresses

### 🔔 Notification System
- **Push Notifications**: Firebase Cloud Messaging integration
- **Booking Alerts**: Real-time notifications for new bookings
- **Payment Notifications**: Alerts for completed payments
- **Local Notifications**: In-app notification management

## Tech Stack

- **Flutter**: Cross-platform mobile development
- **Firebase**: Authentication, Firestore database, Cloud Messaging, Storage
- **OpenStreetMap**: Map integration with flutter_map
- **Provider**: State management
- **Go Router**: Navigation and routing
- **Local Notifications**: Native notification support

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd doctor2homeprovider
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, Cloud Messaging, and Storage
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Update `firebase_options.dart` with your Firebase configuration

4. **Platform Configuration**

   **Android:**
   - Update `android/app/src/main/AndroidManifest.xml` with your package name
   - Ensure all permissions are properly configured

   **iOS:**
   - Update `ios/Runner/Info.plist` with your bundle identifier
   - Configure location and camera permissions

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app/
│   └── app.dart                 # Main app configuration and routing
├── models/
│   ├── booking_model.dart       # Booking data model
│   └── provider_model.dart     # Healthcare provider data model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── booking_provider.dart    # Booking management state
│   └── wallet_provider.dart     # Wallet and earnings state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Login screen
│   │   └── register_screen.dart # Registration screen
│   ├── booking/
│   │   ├── booking_card.dart    # Booking card widget
│   │   ├── booking_detail_screen.dart # Booking details
│   │   └── booking_list_screen.dart   # Bookings list
│   ├── home/
│   │   └── home_screen.dart     # Dashboard/home screen
│   ├── map/
│   │   └── live_map_screen.dart # Live map view
│   ├── profile/
│   │   └── profile_screen.dart  # Profile management
│   ├── wallet/
│   │   └── wallet_screen.dart   # Wallet and earnings
│   └── splash_screen.dart       # Splash screen
├── services/
│   └── notification_service.dart # Notification management
├── widgets/
│   └── bottom_nav_bar.dart      # Bottom navigation
├── main.dart                    # App entry point
└── firebase_options.dart        # Firebase configuration
```

## Key Features Implementation

### Authentication Flow
1. **Registration**: Collect provider details, license information, and specialization
2. **Email Verification**: Firebase email verification for account activation
3. **License Verification**: Admin verification process for medical licenses
4. **Secure Login**: Firebase Authentication with email/password

### Booking System
1. **Real-time Updates**: Firestore listeners for instant booking notifications
2. **Status Management**: Comprehensive booking status tracking
3. **Location Services**: GPS integration for navigation
4. **Communication**: Direct patient contact through phone integration

### Wallet System
1. **Payment Processing**: Automatic payment addition upon booking completion
2. **Earnings Tracking**: Real-time earnings calculation and display
3. **Transaction History**: Complete payment history with status tracking
4. **Analytics**: Monthly earnings visualization

### Map Integration
1. **OpenStreetMap**: Free and open-source map tiles
2. **Real-time Location**: GPS tracking for provider location
3. **Route Planning**: Visual route display to patient locations
4. **Booking Markers**: Visual representation of active bookings

## Configuration

### Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project settings:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-android-api-key',
  appId: 'your-android-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  // ... other configurations
);
```

### Map Configuration
The app uses OpenStreetMap tiles by default. No additional API keys required.

### Notification Configuration
Ensure proper Firebase Cloud Messaging setup for push notifications.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team.

## Future Enhancements

- **Video Consultation**: Integration for virtual appointments
- **Multi-language Support**: Localization for different languages
- **Advanced Analytics**: Detailed provider performance metrics
- **Integration APIs**: Healthcare system integration
- **Offline Mode**: Support for offline functionality
- **Chat System**: In-app messaging with patients
