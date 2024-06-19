import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("后台通知");
  print("Handling a background message: ${message.messageId}");
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("payload: ${message.data}");
}

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    // await initPushNotifications();
    // 获取Firebase Cloud 消息传递令牌
    final fCMToken = await _firebaseMessaging.getToken();
    // 后台运行通知回调
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // 前台运行通知监听
    FirebaseMessaging.onMessage.listen(handleMessage);
    // 监听 后台运行时通过系统信息条打开应用
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    // 如需在每次令牌更新时获得通知
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // 每当生成新令牌时，都会触发此回调。
    }).onError((err) {
      // Error getting token.
    });
    print("message-Token:$fCMToken");
  }

  void onMessageOpenedApp(RemoteMessage message) {
    print("打开通知");
    print("Handling a background message: ${message.messageId}");
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("payload: ${message.data}");
  }

  void handleMessage(RemoteMessage? message) {
    // 如果消息不是空的话
    if (message == null) return;
    // 用户点击通知， 进入特定该页面
    // Get.toNamed("/home", arguments: message);
    print("前台通知");
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("payload: ${message.data}");
  }
}