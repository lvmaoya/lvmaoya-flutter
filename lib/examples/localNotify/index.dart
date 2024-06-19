import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotify extends StatefulWidget {
  const LocalNotify({super.key});

  @override
  State<LocalNotify> createState() => _LocalNotifyState();
}

class _LocalNotifyState extends State<LocalNotify> {
  int id = 0;
  Future<void> _showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'Channel Name',
            channelDescription: 'Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            fullScreenIntent: true);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      id++,
      'Notification Title',
      'Notification Body',
      notificationDetails,
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalNotify'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // 创建并显示通知
                _showNotification(flutterLocalNotificationsPlugin);
              },
              child: const Text('Show Notification'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Future.delayed(const Duration(seconds: 3)); //后台不会执行
                print("hellowolrd");
                // 创建并显示通知
                _showNotification(flutterLocalNotificationsPlugin);
              },
              child: const Text('Show Notification timeout'),
            )
          ],
        ),
      ),
    );
  }
}
