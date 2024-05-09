import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lib/Counter.dart';

class ProviderExample extends StatefulWidget {
  const ProviderExample({super.key});

  @override
  State<ProviderExample> createState() => _ProviderExampleState();
}

class _ProviderExampleState extends State<ProviderExample>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.watch<Counter>().addListener(() {
      print("状态改变");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Animation control'),
        ),
        body: Column(
          children: <Widget>[
            Text(
              /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
              '${context.watch<Counter>().count}',
              key: const Key('counterState'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
