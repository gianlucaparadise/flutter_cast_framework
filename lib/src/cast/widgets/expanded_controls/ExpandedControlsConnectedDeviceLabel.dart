import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast.dart';

class ExpandedControlsConnectedDeviceLabel extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final String castingToText;

  const ExpandedControlsConnectedDeviceLabel({
    Key? key,
    required this.castFramework,
    this.castingToText = "Casting to",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white);

    return FutureBuilder<CastDevice>(
      future: castFramework.castContext.sessionManager.getCastDevice(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var castDevice = snapshot.data;
          var castDeviceName = castDevice?.friendlyName ?? "";
          return Text("$castingToText $castDeviceName", style: textStyle);
        } else if (snapshot.hasError) {
          debugPrint("error while retrieving cast device ${snapshot.error}");
          return Text("");
        } else {
          return Text("");
        }
      },
    );
  }
}
