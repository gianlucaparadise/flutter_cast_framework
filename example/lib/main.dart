import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';
import 'package:flutter_cast_framework_example/expanded_controls_route.dart';

import 'media_load_request_data_helper.dart';

void main() => runApp(
      MaterialApp(
        home: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterCastFramework castFramework;

  CastState _castState = CastState.idle;
  SessionState _sessionState = SessionState.idle;
  String _message = '';
  PlayerState _playerState = PlayerState.idle;

  bool get _hasSession => _sessionState == SessionState.started;
  bool get _hasMedia {
    if (!_hasSession) return false;

    switch (_playerState) {
      case PlayerState.idle:
      case PlayerState.unknown:
        return false;
      case PlayerState.loading:
      case PlayerState.buffering:
      case PlayerState.paused:
      case PlayerState.playing:
        return true;
    }
  }

  final textMessageController = TextEditingController();

  final String castNamespace = 'urn:x-cast:flutter-cast-framework-demo';

  @override
  void initState() {
    super.initState();
    castFramework = FlutterCastFramework.create([castNamespace]);
    castFramework.castContext.state.addListener(_onCastStateChanged);

    final sessionManager = castFramework.castContext.sessionManager;
    sessionManager.state.addListener(_onSessionStateChanged);
    sessionManager.onMessageReceived = _onMessageReceived;
    sessionManager.remoteMediaClient.playerState
        .addListener(_onRemoteMediaClientStatusUpdated);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textMessageController.dispose();

    castFramework.castContext.state.removeListener(_onCastStateChanged);

    final sessionManager = castFramework.castContext.sessionManager;
    sessionManager.state.removeListener(_onSessionStateChanged);
    sessionManager.onMessageReceived = null;
    sessionManager.remoteMediaClient.playerState
        .removeListener(_onRemoteMediaClientStatusUpdated);

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
    debugPrint("Player state changed from example");
    setState(() {
      final playerState = castFramework
          .castContext.sessionManager.remoteMediaClient.playerState.value;

      _playerState = playerState;
    });
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

  Future<void> _openExpandedControls() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpandedControlsRoute(
          castFramework: castFramework,
        ),
      ),
    );
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
    return Scaffold(
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
                      enabled: _hasSession,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text('Send'),
                      onPressed: _hasSession ? _onSendMessage : null,
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
                onPressed: _hasSession ? _onCastVideo : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Player State: $_playerState"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: Text('Expanded Controls'),
                onPressed: _hasMedia ? _openExpandedControls : null,
              ),
            ),
            _buildTitle("Mini Controller"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MiniController(
                castFramework: castFramework,
                onControllerTapped: _hasMedia ? _openExpandedControls : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
