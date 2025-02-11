import 'dart:convert';

import 'package:app/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final socketService = SocketService();
  String _color = '';
  int _radius = 0;
  double _width = 0;
  double _height = 0;
  bool _isLoading = false;
  bool _isConnected = false;
  bool _isDataReceived = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Connect and disconnect buttons.
            AnimatedAlign(
              curve: Curves.fastOutSlowIn,
              duration: const Duration(seconds: 1),
              alignment: _isConnected ? Alignment.topCenter : Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isConnected
                          ? Colors.red.shade500
                          : Colors.green.shade500,
                    ),
                    onPressed: _isLoading
                        ? null
                        : _isConnected
                            ? disconnectToServer
                            : connectToServer,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isConnected ? 'Disconnect' : 'Connect to socket',
                          style: GoogleFonts.poppins(),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  if (_isConnected) ...[
                    const SizedBox(height: 25),
                    Text(
                      "Listening to data from the server.....",
                      style: GoogleFonts.poppins(),
                    )
                  ],
                ],
              ),
            ),

            // Listening for data from server.
            if (_isConnected) ...[
              _isDataReceived
                  ? Center(
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        alignment: Alignment.center,
                        width: _width,
                        height: _height,
                        decoration: BoxDecoration(
                          color: _color.isNotEmpty ? hexToColor(_color) : null,
                          borderRadius:
                              BorderRadius.circular(_radius.toDouble()),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ]
          ],
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

  void connectToServer() {
    setState(() => _isLoading = true);
    socketService.connectAndListen();
    socketService.onJoinSession = (data) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _isLoading = false;
          _isConnected = true;
        });
      });
    };
    socketService.onHomeWidgetsReceived = (data) {
      final jsonData = json.decode(data);
      _color = jsonData['color'] ?? "";
      _radius = jsonData['radius'] ?? 0;
      _width = ((jsonData['width'] ?? 0) as int).toDouble();
      _height = ((jsonData['height'] ?? 0) as int).toDouble();
      _color = _color.replaceAll("#", "");
      setState(() {
        _isDataReceived = true;
      });
    };

    socketService.joinSession('1');
  }

  void disconnectToServer() {
    setState(() => _isLoading = true);
    socketService.dispose();
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
        _isConnected = false;
        _color = '';
        _radius = 0;
        _width = 0;
        _height = 0;
        _isDataReceived = false;
      });
    });
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
}
