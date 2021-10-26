import 'package:flutter/widgets.dart';

import '../../flutter_cast_framework.dart';
import 'CastIcon.dart';

class CastButton extends StatelessWidget {
  final Color color;
  final EdgeInsets padding;

  CastButton({
    this.color = const Color(0xFFFFFFFF), // white
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Padding(
          padding: padding,
          child:  CastIcon(
            color: color,
          ),
        ),
        onTap: () => FlutterCastFramework.castContext.showCastChooserDialog());
  }
}
