import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorWheelPage extends StatefulWidget {
  const ColorWheelPage({super.key});

  @override
  _ColorWheelPageState createState() => _ColorWheelPageState();
}

class _ColorWheelPageState extends State<ColorWheelPage> {
  Offset _currentPosition = Offset.zero;
  Color _currentColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esp32 S3 Blufi,Mqtt,Ble'),
      ),
      body: GestureDetector(
        onPanUpdate: _handlePanUpdate,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: ColorWheelPainter(),
                ),
              ),
            ),
            Positioned(
              left: _currentPosition.dx - 10,
              top: _currentPosition.dy - 10,
              child: GestureDetector(
                onPanUpdate: _handlePanUpdate,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: _currentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final double radius = box.size.width / 2;
    final double angle = atan2(localPosition.dy - radius, localPosition.dx - radius);
    final double distance = sqrt(pow(localPosition.dx - radius, 2) + pow(localPosition.dy - radius, 2));

    if (distance <= radius) {
      setState(() {
        _currentPosition = Offset(
          radius + cos(angle) * distance,
          radius + sin(angle) * distance,
        );
        _currentColor = HSVColor.fromAHSV(1, angle * 180 / pi, distance / radius, 1).toColor();
        print('RGB: $_currentColor');
      });
    }
  }
}

class ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Gradient gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: List.generate(360, (index) => HSVColor.fromAHSV(1, index.toDouble(), 1, 1).toColor()),
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}