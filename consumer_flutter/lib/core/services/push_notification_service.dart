import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();
  late final FirebaseMessaging _messaging;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize({void Function(String orderId, String status)? onOrderStatusChanged}) async {
    // TODO: add google-services.json / GoogleService-Info.plist for the Firebase project.
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // TODO: add Firebase platform configuration before enabling production push.
      return;
    }
    // Register the background handler only after Firebase has initialized.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _messaging = FirebaseMessaging.instance;
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(const InitializationSettings(android: android));
    FirebaseMessaging.onMessage.listen((message) async {
      final data = message.data;
      final orderId = data['orderId']?.toString();
      final status = data['status']?.toString();
      if (orderId != null && status != null) onOrderStatusChanged?.call(orderId, status);
      await _local.show(message.hashCode, message.notification?.title ?? 'NearNow', message.notification?.body ?? 'Your order status was updated.', const NotificationDetails(android: AndroidNotificationDetails('order_updates', 'Order updates', channelDescription: 'NearNow order status updates', importance: Importance.high, priority: Priority.high)));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final orderId = message.data['orderId']?.toString(); final status = message.data['status']?.toString();
      if (orderId != null && status != null) onOrderStatusChanged?.call(orderId, status);
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
