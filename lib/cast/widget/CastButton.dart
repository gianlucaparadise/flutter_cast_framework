import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast/widget/CastIcon.dart';

class CastButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CastIcon(),
      onTap: () => debugPrint("Clicked"),
    );
  }
}
