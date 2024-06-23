import 'package:flutter/material.dart';

import 'jiGuang/index.dart';

class MessagingExample extends StatefulWidget {
  const MessagingExample({super.key});

  @override
  State<MessagingExample> createState() => _MessagingExampleState();
}

class _MessagingExampleState extends State<MessagingExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Animation control'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => JGMessagePush(),
                    ));
                  },
                  child: Text("极光推送"))
            ],
          ),
        ));
  }
}
