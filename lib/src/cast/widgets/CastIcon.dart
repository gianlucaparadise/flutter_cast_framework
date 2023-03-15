import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../flutter_cast_framework.dart';
import '../CastContext.dart';

const Color _defaultIconColor = Color.fromARGB(255, 255, 255, 255); // white
const Color _disabledIconColor = Color.fromARGB(255, 201, 201, 201); // gray

class CastIcon extends StatefulWidget {
  final Color color;
  final FlutterCastFramework castFramework;

  CastIcon({
    required this.castFramework,
    this.color = _defaultIconColor,
  });

  @override
  _CastIconState createState() => _CastIconState();
}

Widget _getButton(String assetName, Color color) {
  return SvgPicture.asset(
    assetName,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    package: 'flutter_cast_framework',
    semanticsLabel: 'Cast Button',
  );
}

class _CastIconState extends State<CastIcon> with TickerProviderStateMixin {
  late CastState _castState;
  CastState get castState => _castState;

  @override
  void initState() {
    super.initState();
    var castContext = widget.castFramework.castContext;

    _castState = castContext.state.value;
    castContext.state.addListener(_onCastStateChanged);
  }

  void _onCastStateChanged() {
    if (!mounted) return;

    setState(() {
      if (!mounted) return;
      _castState = widget.castFramework.castContext.state.value;
    });
  }

  Widget _getEmpty() => Container();

  Widget _getAnimatedButton() => _ConnectingIcon(color: widget.color);

  @override
  Widget build(BuildContext context) {
    switch (_castState) {
      case CastState.unavailable:
        return _getButton("assets/ic_cast_24dp.svg", _disabledIconColor);

      case CastState.unconnected:
        return _getButton("assets/ic_cast_24dp.svg", widget.color);

      case CastState.connecting:
        return _getAnimatedButton();

      case CastState.connected:
        return _getButton("assets/ic_cast_connected_24dp.svg", widget.color);

      case CastState.idle:
      default:
        debugPrint("State not handled: $_castState");
        return _getButton("assets/ic_cast_24dp.svg", _disabledIconColor);
    }
  }
}

class _ConnectingIcon extends StatefulWidget {
  final Color color;

  _ConnectingIcon({required this.color});

  @override
  _ConnectingIconState createState() => _ConnectingIconState();
}

class _ConnectingIconState extends State<_ConnectingIcon> {
  static final List<String> _connectingAnimationFrames = [
    "assets/ic_cast0_24dp.svg",
    "assets/ic_cast1_24dp.svg",
    "assets/ic_cast2_24dp.svg",
  ];

  int _frameIndex = 0;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  _start() {
    if (!this.mounted) return;

    setState(() {
      if (!mounted) return;
      _frameIndex = 0;
      isAnimating = true;
    });
  }

  _nextFrame() async {
    if (!mounted) return;

    if (_frameIndex < _connectingAnimationFrames.length - 1) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          if (!mounted) return;
          _frameIndex += 1;
        });
      }
    } else {
      // When I reach the end, I re-start from the beginning
      await Future.delayed(const Duration(seconds: 1));
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    String frame;
    if (_frameIndex < _connectingAnimationFrames.length) {
      frame = _connectingAnimationFrames[_frameIndex];
    } else {
      // FIXME: sometimes this number is over the length
      debugPrint("_ConnectingIconState: FrameIndex overflow");
      frame = _connectingAnimationFrames.last;
    }

    if (isAnimating) {
      _nextFrame();
    }

    return _getButton(frame, widget.color);
  }
}
