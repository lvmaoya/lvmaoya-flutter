import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class BleExample extends StatefulWidget {
  const BleExample({super.key});

  @override
  State<BleExample> createState() => _BleExampleState();
}

class _BleExampleState extends State<BleExample> {
  List<dynamic> numberList = [];
  //打开蓝牙
  openBle() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    subscription.cancel();
  }
  //扫描
  scanBle() async {
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        }
      },
      onError: (e) => print(e),
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
        withServices: [Guid("180D")],
        withNames: ["CEEGESIS_70041dc99f50"],
        timeout: Duration(seconds: 15));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  connectBlueConnection() {}
  closeBlueConnection() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ble Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GFButton(
              onPressed: openBle,
              text: "打开蓝牙",
              type: GFButtonType.outline2x,
            ),
            GFButton(
              onPressed: scanBle,
              text: "扫描蓝牙",
              type: GFButtonType.outline2x,
            ),
            GFButton(
              onPressed: connectBlueConnection,
              text: "蓝牙连接",
              type: GFButtonType.outline2x,
            ),
            GFButton(
              onPressed: closeBlueConnection,
              text: "关闭蓝牙连接",
              type: GFButtonType.outline2x,
            ),
            Column(
              children: numberList.map((e) => Text(e.toString())).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
