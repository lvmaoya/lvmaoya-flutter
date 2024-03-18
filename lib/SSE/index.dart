import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class SSEExample extends StatefulWidget {
  const SSEExample({super.key});

  @override
  State<SSEExample> createState() => _SSEExampleState();
}

class _SSEExampleState extends State<SSEExample> {
  var _streamResponse;
  List<dynamic> numberList = [];

  Future connectServer() async {
    final req = http.Request('GET', Uri.parse('http://192.168.2.46:8080'));
    final res = await http.Client().send(req);
    GFToast.showToast(
      '连接成功！',
      context,
    );
    _streamResponse = res.stream.toStringStream().listen(
      (message) {
        print(message);
        numberList.add(message.toString());
        setState(() {});
      },
      onDone: () => GFToast.showToast(
        '连接已断开！',
        context,
      ),
    );
  }

  closeConnection() {
    _streamResponse.cancel();
  }

  @override
  void dispose() {
    if (_streamResponse != null) _streamResponse.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSE Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GFButton(
              onPressed: connectServer,
              text: "连接",
              type: GFButtonType.outline2x,
            ),
            GFButton(
              onPressed: closeConnection,
              text: "关闭连接",
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
