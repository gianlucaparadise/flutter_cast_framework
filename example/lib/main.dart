import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CastState _castState = CastState.idle;
  SessionState _sessionState = SessionState.idle;
  String _message = '';

  final textMessageController = TextEditingController();

  final String castNamespace = 'urn:x-cast:cast-your-instructions';

  @override
  void initState() {
    super.initState();
    FlutterCastFramework.namespaces = [castNamespace];
    FlutterCastFramework.castContext.state.addListener(_onCastStateChanged);
    FlutterCastFramework.castContext.sessionManager.state
        .addListener(_onSessionStateChanged);
    FlutterCastFramework.castContext.sessionManager.onMessageReceived =
        _onMessageReceived;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textMessageController.dispose();
    super.dispose();
  }

  void _onCastStateChanged() {
    debugPrint("Cast state changed from example");
    setState(() {
      _castState = FlutterCastFramework.castContext.state.value;
    });
  }

  void _onSessionStateChanged() {
    debugPrint("Session state changed from example");
    setState(() {
      _sessionState =
          FlutterCastFramework.castContext.sessionManager.state.value;
    });
  }

  void _onMessageReceived(String namespace, String message) {
    debugPrint("Message received from example");
    setState(() {
      _message = message;
    });
  }

  void _onSendMessage() {
    String message = this.textMessageController.text;
    FlutterCastFramework.castContext.sessionManager
        .sendMessage(castNamespace, message);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cast plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              CastButton(),
              Text(
                'States',
                style: Theme.of(context).textTheme.title,
              ),
              Text('Cast State: $_castState'),
              Text('Session State: $_sessionState'),
              Text(
                'Message',
                style: Theme.of(context).textTheme.title,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textMessageController,
                    ),
                  ),
                  RaisedButton(
                    child: Text('Send'),
                    onPressed: _onSendMessage,
                  )
                ],
              ),
              Text('Received Message: $_message'),
            ],
          ),
        ),
      ),
    );
  }
}
