import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lvmaoya/main.dart';
import 'package:lvmaoya/examples/messagePush/message_detail.dart';



class FirebaseService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static late AndroidNotificationChannel channel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static bool isFlutterLocalNotificationsInitialized = false;

  //初始化flutterLocalNotificationsPlugin和Chanel
  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      '987284204481',
      'lvmaoya',
      description:
          'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  //设置后台回调
  static Future<void> initNotifications() async {
    // await firebaseMessaging.getNotificationSettings();
    await firebaseMessaging.requestPermission();
    // 获取Firebase Cloud 消息传递令牌
    final fCMToken = await firebaseMessaging.getToken();
    // 前台运行通知监听
    FirebaseMessaging.onMessage.listen(onMessage);
    // 监听 后台运行时通过系统信息条打开应用
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    // 如需在每次令牌更新时获得通知
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // 每当生成新令牌时，都会触发此回调。
    }).onError((err) {
      // Error getting token.
    });
    debugPrint("message-Token:$fCMToken");
  }

  static void onMessageOpenedApp(RemoteMessage message) {
    print("打开通知");
    print("Handling a background message: ${message.messageId}");
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("payload: ${message.data}");
    print('A new onMessageOpenedApp event was published!');
    navigatorKey.currentState?.pushNamed(
      '/message',
      arguments: MessageArguments(message, true),
    );
  }

  static void onMessage(RemoteMessage? message) {
    // 如果消息不是空的话
    if (message == null) return;
    // 用户点击通知， 进入特定该页面
    // Get.toNamed("/home", arguments: message);
    print("前台通知");
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("payload: ${message.data}");
    showFlutterNotification(message);
  }

  static void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'app_icon',
          ),
        ),
      );
    }
  }
}
