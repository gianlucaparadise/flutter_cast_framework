import 'package:flutter/foundation.dart';

class CastContext {
  static final _instance = new CastContext._internal();

  CastContext._internal();

  static CastContext get instance => _instance;

  final ValueNotifier<CastState> state = ValueNotifier(CastState.unavailable);
}

enum CastState {
  default_state, // 0
  unavailable, // 1
  unconnected, // 2
  connecting, // 3
  connected, // 4
}