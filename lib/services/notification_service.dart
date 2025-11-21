import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await plugin.initialize(settings);

    await _requestPermissions();
    await _setupFirebaseMessaging();
  }

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'doctor2home_channel',
            'Doctor2Home Notifications',
            channelDescription: 'Notifications for new bookings and updates',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification clicked: ${message.messageId}');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doctor2home_channel',
      'Doctor2Home Notifications',
      channelDescription: 'Notifications for new bookings and updates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showBookingNotification({
    required String bookingId,
    required String patientName,
    required String service,
    required DateTime scheduledDate,
  }) async {
    final formattedDate = '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
    final formattedTime = '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'New Booking Request!',
      body: '$patientName needs $service on $formattedDate at $formattedTime',
      payload: 'booking:$bookingId',
    );
  }

  static Future<void> showBookingAcceptedNotification({
    required String bookingId,
    required String providerName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Booking Accepted!',
      body: '$providerName has accepted your booking request',
      payload: 'booking_accepted:$bookingId',
    );
  }

  static Future<void> showPaymentNotification({
    required double amount,
    required String patientName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Payment Received!',
      body: '\$${amount.toStringAsFixed(2)} received from $patientName',
      payload: 'payment',
    );
  }

  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static void subscribeToTopic(String topic) {
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void unsubscribeFromTopic(String topic) {
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
