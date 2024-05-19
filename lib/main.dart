import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:lvmaoya/examples/esp32LightColor/index.dart';
import 'package:lvmaoya/examples/generativeAi/index.dart';
import 'package:lvmaoya/examples/logger/index.dart';
import 'package:lvmaoya/examples/lottie/index.dart';
import 'package:lvmaoya/examples/provider/index.dart';
import 'package:lvmaoya/examples/wifi/index.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'examples/Blue/index.dart';
import 'examples/SSE/index.dart';
import 'examples/provider/lib/Counter.dart';
import 'examples/sharedPreferences/index.dart';
import 'examples/webSocket/index.dart';

Future<void> main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://909c4eb9e0a731298c4de53249b89589@o4507151999172608.ingest.us.sentry.io/4507152004087808';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () async {
      // await Future.delayed(const Duration(seconds: 3));
      // FlutterNativeSplash.remove();
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Counter()),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.blueM3,
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: FlexThemeData.light(
              scheme: FlexScheme.blueM3,
            ).primaryColor,
            titleTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(size: 20, color: Colors.white),
            centerTitle: true),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.materialHc,
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: FlexThemeData.light(
              scheme: FlexScheme.blueM3,
            ).primaryColor,
            titleTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true),
        iconTheme: const IconThemeData(size: 20, color: Colors.white),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Flutter Demos'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ExampleBtn> btns = [
    ExampleBtn(const WebSocketExample(), "WebSocketExample"),
    ExampleBtn(const SSEExample(), "SSEExample"),
    ExampleBtn(const BleExample(), "BleExample"),
    ExampleBtn(const SharedPreferencesExample(), "SharedPreferencesExample"),
    ExampleBtn(const GenerativeAiExample(), "GenerativeAiExample"),
    ExampleBtn(const WifiExample(), "WifiExample"),
    ExampleBtn(const LoggerExample(), "LoggerExample"),
    ExampleBtn(const LottieExample(), "LottieExample"),
    ExampleBtn(const ProviderExample(), "ProviderExample"),
    ExampleBtn(const ColorWheelPage(), "MqttExample")
  ];
  final ZoomDrawerController z = ZoomDrawerController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
        duration: const Duration(milliseconds: 500),
        menuScreenTapClose: true,
        controller: z,
        openCurve: Curves.fastOutSlowIn,
        moveMenuScreen: true,
        // slideWidth: MediaQuery.of(context).size.width - 20,
        overlayBlend: BlendMode.hardLight,
        angle: 0,
        mainScreenScale: 0,
        mainScreenTapClose: true,
        mainScreenOverlayColor: Colors.white.withOpacity(0.0),
        overlayBlur: 1,
        style: DrawerStyle.defaultStyle,
        shrinkMainScreen: false,
        boxShadow: null,
        borderRadius: 0,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        menuScreenWidth: MediaQuery.of(context).size.width * 0.65,
        menuBackgroundColor: Colors.blue,
        menuScreen: Scaffold(
          backgroundColor: Colors.blue,
          body: const Column(
            children: [
              ListTile(
                title: Text("hello"),
              ),
              ListTile(
                title: Text("world"),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            key: const Key('increment_floatingActionButton'),
            onPressed: () => context.read<Counter>().increment(),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
        mainScreen: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
            ),
            leading: GestureDetector(
              onTap: () {
                z.toggle!();
              },
              child: const Center(
                child: ClipOval(
                  child: Image(
                    image: AssetImage("assets/avatar.jpg"),
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
                children: btns
                    .map(
                      (e) => TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => e.widget,
                            ));
                          },
                          child: Center(
                            child: Text(e.title),
                          )),
                    )
                    .toList()),
          ),
        ));
  }
}

class ExampleBtn {
  String title;
  Widget widget;
  ExampleBtn(this.widget, this.title);
}
