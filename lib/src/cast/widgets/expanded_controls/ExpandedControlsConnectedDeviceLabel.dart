import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';

/// Placeholder to be used for the castingToText of ExpandedControlsConnectedDeviceLabel
const CAST_DEVICE_NAME_PLACEHOLDER = "{{cast_device_name}}";

class ExpandedControlsConnectedDeviceLabel extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final _defaultCastingToText = "Casting to $CAST_DEVICE_NAME_PLACEHOLDER";

  /// Label to introduce cast device. Default is "Casting to {{cast_device_name}}",
  /// where {{cast_device_name}} is replaced with the device name.
  /// {{cast_device_name}} can be found in the constant CAST_DEVICE_NAME_PLACEHOLDER.
  final String? castingToText;

  ExpandedControlsConnectedDeviceLabel({
    Key? key,
    required this.castFramework,
    this.castingToText,
  }) : super(key: key);

  String _replaceDeviceName(String textWithPlaceholder, String deviceName) {
    return textWithPlaceholder.replaceAll(
        CAST_DEVICE_NAME_PLACEHOLDER, deviceName);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);

    return FutureBuilder<CastDevice>(
      future: castFramework.castContext.sessionManager.getCastDevice(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final castDevice = snapshot.data;
          final castDeviceName = castDevice?.friendlyName ?? "";
          final baseCastLabel = castingToText ?? _defaultCastingToText;
          final label = _replaceDeviceName(baseCastLabel, castDeviceName);
          return Text(label, style: textStyle);
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
