import 'package:pigeon/pigeon.dart';

class CastMessage {
  String? namespace;
  String? message;
}

@HostApi()
abstract class CastHostApi {
  void sendMessage(CastMessage message);
  void showCastDialog();
}

@FlutterApi()
abstract class CastFlutterApi {
  List<String> getSessionMessageNamespaces();
  void onCastStateChanged(int castState);
  void onMessageReceived(CastMessage message);

  //region Session State handling
  void onSessionStarting();
  void onSessionStarted();
  void onSessionStartFailed();
  void onSessionEnding();
  void onSessionEnded();
  void onSessionResuming();
  void onSessionResumed();
  void onSessionResumeFailed();
  void onSessionSuspended();
  //endregion
}