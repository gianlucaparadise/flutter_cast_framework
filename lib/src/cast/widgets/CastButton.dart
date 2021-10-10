import 'package:flutter/widgets.dart';

import '../../flutter_cast_framework.dart';
import 'CastIcon.dart';

class CastButton extends StatelessWidget {
  final Color color;

  CastButton({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: CastIcon(
          color: color,
        ),
        onTap: () => FlutterCastFramework.castContext.showCastChooserDialog());
  }
}
