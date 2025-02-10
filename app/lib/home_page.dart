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

  @override
  void initState() {
    super.initState();
    socketService.connectAndListen();
    socketService.onJoinSession = (data) {
      setState(() => _data = data.toString());
    };
    socketService.onHomeWidgetsReceived = (data) {
      setState(() => _data = data.toString());
    };

    socketService.joinSession('1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Text(_data),
    );
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
}
