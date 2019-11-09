import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast/CastContext.dart';
import 'package:flutter_cast_framework/flutter_cast_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CastIcon extends StatefulWidget {
  @override
  _CastIconState createState() => _CastIconState();
}

class _CastIconState extends State<CastIcon> {
  static const _connectingAssetNameList = {
    2: "assets/ic_cast_24dp.svg",
    3: "assets/ic_cast1_24dp.svg",
    4: "assets/ic_cast_connected_24dp.svg",
  };

  CastState _castState = CastState.unavailable;

  CastState get castState => _castState;

  @override
  void initState() {
    super.initState();

    FlutterCastFramework.castContext.state.addListener(_onCastStateChanged);
  }

  void _onCastStateChanged() {
    setState(() {
      _castState = FlutterCastFramework.castContext.state.value;
    });
  }

  Widget getEmpty() => Container();

  Widget getButton() {
    int stateIndex = FlutterCastFramework.castContext.state.value.index;
    String assetName = _connectingAssetNameList[stateIndex];
    return SvgPicture.asset(
      assetName,
      package: 'flutter_cast_framework',
      semanticsLabel: 'Cast Button',
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_castState) {
      case CastState.unavailable:
        return getEmpty();

      case CastState.unconnected:
      case CastState.connecting:
      case CastState.connected:
        return getButton();

      case CastState.default_state:
      default:
        debugPrint("State not handled: $_castState");
        return getEmpty();
    }
  }
}
