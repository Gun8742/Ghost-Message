import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {

    const AndroidNotificationDetails android =
        AndroidNotificationDetails(
      'ghost_channel',
      'Ghost Message Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: android);

    await _plugin.show(
      0,
      title,
      body,
      details,
    );
  }
}