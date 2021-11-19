import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';

import 'media_load_request_data_helper.dart';

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

  final String castNamespace = 'urn:x-cast:flutter-cast-framework-demo';

  @override
  void initState() {
    super.initState();
    castFramework = FlutterCastFramework.create([castNamespace]);
    castFramework.castContext.state.addListener(_onCastStateChanged);
    castFramework.castContext.sessionManager.state
        .addListener(_onSessionStateChanged);
    castFramework.castContext.sessionManager.onMessageReceived =
        _onMessageReceived;
    castFramework.castContext.sessionManager.onStatusUpdated =
        _onRemoteMediaClientStatusUpdated;
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
      _sessionState = castFramework.castContext.sessionManager.state.value;
    });
  }

  void _onMessageReceived(String namespace, String message) {
    debugPrint("Message received from example");
    setState(() {
      _message = message;
    });
  }

  void _onRemoteMediaClientStatusUpdated() {
    debugPrint("RemoteMediaClient status updated");
  }

  void _onSendMessage() {
    String message = this.textMessageController.text;
    String messageAsJson = "{\"text\": \"$message\"}";
    castFramework.castContext.sessionManager
        .sendMessage(castNamespace, messageAsJson);
  }

  void _onCastVideo() {
    final request = getMediaLoadRequestData();
    castFramework.castContext.sessionManager.remoteMediaClient.load(request);
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cast plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CastButton(
                castFramework: castFramework,
                color: Colors.blue,
              ),
              _buildTitle("States"),
              Text('Cast State: $_castState'),
              Text('Session State: $_sessionState'),
              _buildTitle("Message"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textMessageController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text('Send'),
                        onPressed: _onSendMessage,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Received Message: $_message'),
              ),
              _buildTitle("Video"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('Cast video'),
                  onPressed: _onCastVideo,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
