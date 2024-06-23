import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class JPushUtil {
  JPushUtil._internal();

  static final _instance = JPushUtil._internal();

  factory JPushUtil() => _instance;

  final JPush jPush = JPush();

  Future<void> initPlatformState() async {
    String? platformVersion;
    try {
      jPush.addEventHandler(
        onReceiveNotification: (message) async {
          print("flutter onReceiveNotification: $message");
        },
        onOpenNotification: (message) async {
          print("flutter onOpenNotification: $message");
        },
        onReceiveMessage: (message) async {
          print("flutter onReceiveMessage: $message");
        },
        onReceiveNotificationAuthorization: (message) async {
          print("flutter onReceiveNotificationAuthorization: $message");
        },
        onConnected: (message) {
          print("flutter onConnected: $message");
          return Future(() => null);
        },
      );
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      print(platformVersion);
    }
    jPush.isNotificationEnabled().then((bool value) {
      print("通知授权是否打开: $value");
      if (!value) {
        EasyLoading.showToast("没有通知权限,点击跳转打开通知设置界面");
        // Get.snackbar(
        //   "提示",
        //   "没有通知权限,点击跳转打开通知设置界面",
        //   duration: const Duration(seconds: 6),
        //   onTap: (_) {
        //     jPush.openSettingsForNotification();
        //   },
        // );
      }
    }).catchError((onError) {
      print("通知授权是否打开: ${onError.toString()}");
    });

    jPush.enableAutoWakeup(enable: true);
    jPush.setup(
      appKey: '7f684a39ff1f95ef1657acdd',
      production: true,
      debug: true,
    );
    jPush.applyPushAuthority(
      const NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true,
      ),
    );
    final rid = await jPush.getRegistrationID();
    print("flutter getRegistrationID: $rid");
  }

  setAlias(String aliasStr) {
    final alias = jPush.setAlias(aliasStr);
    print("Alias is $alias");
  }
}
