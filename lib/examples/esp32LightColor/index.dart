import 'dart:convert';
import 'dart:io';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ColorWheelPage extends StatefulWidget {
  const ColorWheelPage({super.key});

  @override
  _ColorWheelPageState createState() => _ColorWheelPageState();
}

class _ColorWheelPageState extends State<ColorWheelPage> {
  Color pickerColor = const Color(0xffffffff);

  List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.white,
  ];

  late MqttServerClient mqttClient;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mqttClient = MqttServerClient.withPort(
        'b9dfdd51.ala.cn-hangzhou.emqxsl.cn', 'flutter_client', 8883);
    mqttClient.secure = true;
    mqttClient.securityContext = SecurityContext.defaultContext;

    mqttClient.onConnected = onConnected;
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.onSubscribed = onSubscribed;
    mqttClient.onUnsubscribed = onUnsubscribed;
  }

  void onConnected() {
    EasyLoading.showToast("连接成功");
    print('Connected');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onUnsubscribed(String? topic) {
    print('Unsubscribed from topic: $topic');
  }

  //-------------control------------------------------

  Future<void> onConnectBtnClick() async {
    try {
      await mqttClient.connect("lvmaoya", "king.sun1");
    } catch (e) {
      print('Exception occurred: $e');
      mqttClient.disconnect();
    }
  }

  Future<void> onSubscribeBtnClick() async {
    mqttClient.subscribe("room/temp_humi", MqttQos.atMostOnce);
    mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      Map<String, dynamic> map = jsonDecode(pt);
      debugPrint('服务器返回的数据信息-------------${map["Temp"]}');
      double tempRes = map['Temp'];
      double humiRes = map['Humi'];
      if (tempRes != 100 && humiRes != 100) {
        setState(() {
          temp = tempRes;
          humi = humiRes;
        });
      }
    });
  }

  Future<void> onDisconnectBtnClick() async {
    mqttClient.disconnect();
  }

  Future<void> onPublishBtnClick(String topic, String message) async {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    mqttClient.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  onLedSwitchOnBtnClick() {
    onPublishBtnClick("lvmaoya/iot",
        '{"led": 1,"r": ${pickerColor.red},"g": ${pickerColor.green},"b": ${pickerColor.blue}}');
  }

  onLedSwitchOffBtnClick() {
    onPublishBtnClick("lvmaoya/iot",
        '{"led": 0,"r": ${pickerColor.red},"g": ${pickerColor.green},"b": ${pickerColor.blue}}');
  }

  onLedColorChangeBtnClick(value) {
    setState(() => pickerColor = value);
    onPublishBtnClick("lvmaoya/iot",
        '{"led": 1,"r": ${pickerColor.red},"g": ${pickerColor.green},"b": ${pickerColor.blue}}');
    debugPrint("${pickerColor.red},${pickerColor.green},${pickerColor.blue}");
  }

  onServoStartWithAngleBtnClick(double value) {
    servoAngle = value;
    setState(() {});
  }

  onServoStartBtnClick() {
    onPublishBtnClick("lvmaoya/iot", '{"servo": ${servoAngle.toInt()}}');
  }

  onServoStopBtnClick() {}

  double temp = 0.0;
  double humi = 0.0;
  double servoAngle = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Esp32 S3 Blufi,Mqtt,Ble'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Text("mqtt服务控制：",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primary))
                ],
              ),
              const Divider(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: onConnectBtnClick,
                      child: const Text("连接至EMQX")),
                  TextButton(
                      onPressed: onSubscribeBtnClick,
                      child: const Text("订阅主题")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        onPublishBtnClick("test", "hello world");
                      },
                      child: const Text("发布主题")),
                  TextButton(
                      onPressed: onDisconnectBtnClick,
                      child: const Text("取消连接服务")),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Row(
                children: [
                  Text("传感器数据采集：",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primary))
                ],
              ),
              const Divider(
                height: 20,
              ),
              Row(
                children: [
                  const Text(
                    "当前室内温度：",
                  ),
                  Text("$temp℃",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: primary)),
                  Expanded(
                    child: Container(),
                  ),
                  const Text(
                    "当前室内湿度：",
                  ),
                  Text("$humi%",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: primary)),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Row(
                children: [
                  Text("单片机灯光控制：",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primary))
                ],
              ),
              const Divider(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: onLedSwitchOnBtnClick,
                      child: const Text("开灯")),
                  TextButton(
                      onPressed: onLedSwitchOffBtnClick,
                      child: const Text("关灯")),
                ],
              ),
              Wrap(
                children: colors.asMap().entries.map((e) {
                  int index = e.key;
                  Color value = e.value;
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onLedColorChangeBtnClick(value),
                    child: Container(
                      width: 36,
                      height: 24,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                          color: value,
                          border: Border.all(
                              width: 2,
                              color: pickerColor == value
                                  ? Colors.black
                                  : Colors.transparent),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 30,
              ),
              const Row(
                children: [
                  Text("伺服电机控制：",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primary))
                ],
              ),
              const Divider(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: onServoStartBtnClick, child: const Text("转动")),
                  TextButton(
                      onPressed: onServoStopBtnClick, child: const Text("停止")),
                ],
              ),
              Row(
                children: [
                  Text("角度：${servoAngle.toInt()}度"),
                  Expanded(
                      child: SliderTheme(
                          data: Theme.of(context).sliderTheme.copyWith(
                                trackHeight: 12,
                                overlayColor: Colors.transparent,
                                activeTickMarkColor: Colors.transparent,
                                inactiveTickMarkColor: Colors.transparent,
                                thumbColor: Colors.white,
                              ),
                          child: Slider(
                            value: servoAngle,
                            onChanged: (double value) {
                              servoAngle = value;
                              setState(() {});
                            },
                            onChangeEnd: (value) =>
                                onServoStartWithAngleBtnClick(value),
                            max: 360,
                            min: -360,
                          )))
                ],
              )
            ],
          ),
        ));
  }
}
