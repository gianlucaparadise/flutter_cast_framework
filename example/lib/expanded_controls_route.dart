import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';

class ExpandedControlsRoute extends StatelessWidget {
  final FlutterCastFramework castFramework;

  ExpandedControlsRoute({
    required this.castFramework,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpandedControls(
        castFramework: castFramework,
        onCloseRequested: () => Navigator.pop(context),
      ),
    );
  }
}
