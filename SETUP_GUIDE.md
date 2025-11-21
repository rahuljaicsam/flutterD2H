# Setup Guide for Doctor2Home Provider App

## Current Issue
There's a PowerShell configuration issue preventing Flutter from running properly. Here are several solutions to get the app running:

## Solution 1: Fix PowerShell (Recommended)

1. **Install/Repair PowerShell**:
   - Download and install PowerShell 7+ from Microsoft
   - Or run Windows PowerShell as Administrator and repair

2. **Set Environment Variables**:
   ```cmd
   set PATH=%PATH%;C:\Windows\System32\WindowsPowerShell\v1.0
   ```

3. **Run Flutter**:
   ```cmd
   cd c:\Users\Dell\Documents\doctor2homeprovider
   flutter pub get
   flutter run
   ```

## Solution 2: Use Command Prompt Directly

1. **Open Command Prompt as Administrator**

2. **Navigate to project**:
   ```cmd
   cd c:\Users\Dell\Documents\doctor2homeprovider
   ```

3. **Set Flutter path**:
   ```cmd
   set PATH=%PATH%;c:\Users\Dell\Documents\flutter_windows_3.35.1-stable\flutter\bin
   ```

4. **Run commands**:
   ```cmd
   flutter doctor
   flutter pub get
   flutter run
   ```

## Solution 3: Use Flutter Studio (IDE)

1. **Download Flutter-compatible IDE**:
   - Android Studio with Flutter plugin
   - VS Code with Flutter extension
   - IntelliJ IDEA with Flutter plugin

2. **Open project**:
   - Open `c:\Users\Dell\Documents\doctor2homeprovider`
   - Let IDE detect Flutter SDK
   - Run from IDE

## Solution 4: Web Demo (Immediate)

I've created a web demo that shows the app's UI and functionality:

1. **Open the demo**:
   - Double-click `web_demo.html`
   - Or open in browser: `file:///c:/Users/Dell/Documents/doctor2homeprovider/web_demo.html`

2. **Features demonstrated**:
   - Dashboard with provider info
   - Booking cards with accept/decline
   - Statistics display
   - Bottom navigation
   - Interactive elements

## Prerequisites Checklist

### ✅ Required Software:
- [ ] Flutter SDK (installed at `c:\Users\Dell/Documents/flutter_windows_3.35.1-stable/`)
- [ ] PowerShell (Windows built-in, but may need repair)
- [ ] Android Studio or VS Code (for development)
- [ ] Git (for version control)

### ✅ Firebase Setup:
- [ ] Create Firebase project at https://console.firebase.google.com
- [ ] Enable Authentication, Firestore, Cloud Messaging, Storage
- [ ] Download `google-services.json` for Android
- [ ] Download `GoogleService-Info.plist` for iOS
- [ ] Update `firebase_options.dart` with your config

### ✅ Platform Setup:
- [ ] Android SDK and emulator
- [ ] iOS simulator (Mac only)
- [ ] Chrome for web testing

## Quick Start Commands

Once PowerShell is fixed:

```cmd
# Navigate to project
cd c:\Users\Dell\Documents\doctor2homeprovider

# Get dependencies
flutter pub get

# Check environment
flutter doctor

# Run on available device
flutter run

# Or run on specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop
flutter run -d android         # Android emulator
```

## Troubleshooting

### Issue: "PowerShell executable not found"
**Solution**: Install PowerShell 7+ or repair Windows PowerShell

### Issue: "No connected devices"
**Solution**: 
- Start Android emulator: `flutter emulators --launch <emulator_name>`
- Or enable web: `flutter config --enable-web`
- Or enable desktop: `flutter config --enable-windows-desktop`

### Issue: "Firebase not configured"
**Solution**: 
- Create Firebase project
- Add config files
- Update `firebase_options.dart`

### Issue: "Missing dependencies"
**Solution**: 
```cmd
flutter clean
flutter pub get
```

## App Features Running

When successfully started, the app includes:

### 🏠 **Dashboard**
- Provider profile with verification status
- Statistics (pending, today, upcoming bookings)
- Recent bookings with quick actions
- Navigation to all features

### 📅 **Booking Management**
- Real-time booking notifications
- Accept/decline with reasons
- Detailed booking information
- Status tracking (pending → accepted → in progress → completed)

### 💰 **Wallet**
- Total earnings dashboard
- Transaction history
- Monthly earnings charts
- Payment status tracking

### 🗺️ **Live Map**
- OpenStreetMap integration
- Real-time location tracking
- Patient location markers
- Route planning

### 👤 **Profile**
- Professional information
- License verification display
- Profile picture upload
- Account management

## Development Tips

1. **Hot Reload**: Use `r` key in terminal for hot reload during development
2. **Debug Mode**: Use `flutter run --debug` for debugging
3. **Release Mode**: Use `flutter run --release` for performance testing
4. **Testing**: Use `flutter test` to run unit tests

## Next Steps

1. Fix PowerShell issue using Solution 1 or 2
2. Set up Firebase project
3. Run `flutter pub get`
4. Start development with `flutter run`

The web demo (`web_demo.html`) gives you an immediate preview of the app's interface and functionality while you resolve the Flutter setup issues.
