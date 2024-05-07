import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:getwidget/getwidget.dart';

class WebSocketExample extends StatefulWidget {
  const WebSocketExample({super.key});

  @override
  State<WebSocketExample> createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  final wsUrl = Uri.parse('ws://192.168.2.46:8080');
  final sendMessageController = TextEditingController();
  List<dynamic> numberList = [];
  late WebSocketChannel channel;
  Future connectServer() async {
    channel = WebSocketChannel.connect(wsUrl);
    await channel.ready;
    GFToast.showToast(
      '连接成功！',
      context,
    );
    channel.stream.listen(
      (message) {
        numberList.add('$message,');
        setState(() {});
      },
      onDone: () => GFToast.showToast(
        '连接已断开！',
        context,
      ),
    );
  }

  closeConnection() {
    channel.sink.close();
  }

  sendMessage() {
    channel.sink.add(sendMessageController.text);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    sendMessageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (e) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('WebSocketExample'),
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
                SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        numberList.map((e) => Text(e.toString())).toList(),
                  ),
                ),
                Form(
                    child: Column(
                  children: [
                    TextField(
                      controller: sendMessageController,
                      decoration: InputDecoration(
                        suffix: GFButton(
                          onPressed: sendMessage,
                          text: "发送",
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        ));
  }
}
