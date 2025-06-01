import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:kesehatan_kampus/utility/notification_setting.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) {});

    final LinuxInitializationSettings initializationSettingsLinux =
        const LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    required String type,
  }) async {
    final settings = await NotificationSettings.loadSettings();

    // Check if the notification type is enabled
    if ((type == 'newMessages' && !settings['new_messages']!) ||
        (type == 'promotions' && !settings['promotions']!) ||
        (type == 'updates' && !settings['updates']!)) {
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // Save notification to SharedPreferences
    await saveNotificationToPrefs(
      title: title,
      body: body,
      time: DateTime.now().toString(),
      type: type,
    );
  }

  static Future<void> saveNotificationToPrefs({
    required String title,
    required String body,
    required String time,
    required String type,
  }) async {
    if (title.isEmpty || body.isEmpty || time.isEmpty || type.isEmpty) {
      throw ArgumentError('Notification details cannot be empty');
    }

    final prefs = await SharedPreferences.getInstance();

    // Create a notification object
    final notification = {
      'title': title,
      'body': body,
      'time': time,
      'type': type,
      'isRead': false,  // By default, the notification is unread
    };

    // Get existing notifications or initialize an empty list
    List<String> notificationsJson = prefs.getStringList('notifications') ?? [];

    // Convert the notification map to a JSON string and save it
    notificationsJson.add(json.encode(notification));

    // Save the updated list of notifications
    await prefs.setStringList('notifications', notificationsJson);
  }

  static Future<List<Map>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the saved notifications list
    List<String> notificationsJson = prefs.getStringList('notifications') ?? [];

    // Convert the JSON strings back to maps and explicitly cast to Map<String, dynamic>
    List<Map> notifications = notificationsJson.map((jsonStr) {
      try {
        final decoded = json.decode(jsonStr);
        // Explicitly cast Map<dynamic, dynamic> to Map<String, dynamic>
        return Map<String, dynamic>.from(decoded as Map); // Force the type cast here
      } catch (e) {
        print('Error decoding notification: $e');
        return {}; // Return an empty map on error
      }
    }).toList();

    return notifications;
  }
}
