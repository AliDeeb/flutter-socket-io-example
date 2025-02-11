import 'dart:convert';

import 'package:app/socket_service.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final socketService = SocketService();
  String _data = '';
  String _color = '';
  int _radius = 0;
  double _width = 250;
  double _height = 250;

  @override
  void initState() {
    super.initState();
    socketService.connectAndListen();
    socketService.onJoinSession = (data) {
      setState(() => _data = data.toString());
    };
    socketService.onHomeWidgetsReceived = (data) {
      final jsonData = json.decode(data);
      _color = jsonData['color'] ?? "";
      _radius = jsonData['radius'] ?? 0;
      _width = ((jsonData['width'] ?? 0) as int).toDouble();
      _height = ((jsonData['height'] ?? 0) as int).toDouble();
      _color = _color.replaceAll("#", "");
      setState(() => _data = '');
    };

    socketService.joinSession('1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.fastEaseInToSlowEaseOut,
          alignment: Alignment.center,
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: _color.isNotEmpty ? hexToColor(_color) : null,
            borderRadius: BorderRadius.circular(_radius.toDouble()),
          ),
          child: Text(
            _data,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Function to convert hex string to Color
  Color hexToColor(String hexString) {
    // Remove the '#' character if present
    hexString = hexString.replaceAll('#', '');

    // Add full opacity if the hex string is only 6 characters long
    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // FF for full opacity
    }

    // Parse the hex string to an integer
    int hexValue = int.parse(hexString, radix: 16);

    // Create and return a Color object
    return Color(hexValue);
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
}
