import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterCastFramework castFramework;

  CastState _castState = CastState.idle;
  SessionState _sessionState = SessionState.idle;
  String _message = '';

  final textMessageController = TextEditingController();

  final String castNamespace = 'urn:x-cast:cast-your-instructions';

  @override
  void initState() {
    super.initState();
    castFramework = FlutterCastFramework.create([castNamespace]);
    castFramework.castContext.state.addListener(_onCastStateChanged);
    castFramework.castContext.sessionManager.state
        .addListener(_onSessionStateChanged);
    castFramework.castContext.sessionManager.onMessageReceived =
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
      _castState = castFramework.castContext.state.value;
    });
  }

  void _onSessionStateChanged() {
    debugPrint("Session state changed from example");
    setState(() {
      _sessionState =
          castFramework.castContext.sessionManager.state.value;
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
    castFramework.castContext.sessionManager
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
              CastButton(
                castFramework: castFramework,
                color: Colors.blue,
              ),
              Text(
                'States',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text('Cast State: $_castState'),
              Text('Session State: $_sessionState'),
              Text(
                'Message',
                style: Theme.of(context).textTheme.headline6,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textMessageController,
                    ),
                  ),
                  ElevatedButton(
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
