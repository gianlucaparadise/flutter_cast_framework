import 'package:pigeon/pigeon.dart';

class CastMessage {
  String? namespace;
  String? message;
}

@HostApi()
abstract class CastApi {
  void sendMessage(CastMessage message);
}