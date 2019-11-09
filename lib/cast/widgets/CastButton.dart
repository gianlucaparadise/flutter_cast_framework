import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast/widgets/CastIcon.dart';
import 'package:flutter_cast_framework/flutter_cast_framework.dart';

class CastButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: CastIcon(),
        onTap: () => FlutterCastFramework.castContext.showCastChooserDialog());
  }
}
