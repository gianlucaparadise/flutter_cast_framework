import 'package:flutter/widgets.dart';

import '../../flutter_cast_framework.dart';
import 'CastIcon.dart';

class CastButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: CastIcon(),
        onTap: () => FlutterCastFramework.castContext.showCastChooserDialog());
  }
}
