import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Ref _ref;

  NotificationService(this._ref);

  Future<void> initNotifications() async {
    await _fcm.requestPermission();
    await _initLocalNotifications();

    final fcmToken = await _fcm.getToken();
    print('FCM Token: $fcmToken');
    if (fcmToken != null) {
      _saveTokenToDatabase(fcmToken);
      _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
    }

    _setupMessageHandlers();
  }

  Future<void> _initLocalNotifications() async {
    // Use the new custom icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  void _saveTokenToDatabase(String token) {
    final userId = _ref.read(authRepositoryProvider).currentUser?.uid;
    if (userId == null) return;

    final tokensRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tokens');

    tokensRef.doc(token).set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.data}');
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    BigPictureStyleInformation? bigPictureStyleInformation;
    final String? imageUrl = message.notification?.android?.imageUrl;
    
    if (imageUrl != null) {
      try {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/notification_image.jpg';
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: notification.title,
            htmlFormatContentTitle: true,
            summaryText: notification.body,
            htmlFormatSummaryText: true,
          );
        }
      } catch (e) {
        print('Error downloading notification image: $e');
      }
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // Use the new custom icon here as well
          icon: '@drawable/ic_notification',
          styleInformation: bigPictureStyleInformation,
        ),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});
