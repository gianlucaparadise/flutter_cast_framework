import 'package:flutter/material.dart';

import 'ExpandedControlsBasicButton.dart';

class ExpandedControlsAdSkipBoxController extends ChangeNotifier {
  int progress = 0;
  int duration = 0;
  int whenSkippable = 0;

  void updateProgress(int progress, int duration, int whenSkippable) {
    this.progress = progress;
    this.duration = duration;
    this.whenSkippable = whenSkippable;
    notifyListeners();
  }
}

/// Placeholder to be used for the castingToText of ExpandedControlsConnectedDeviceLabel
const SKIP_AD_TIMER_PLACEHOLDER = "{{skip_remaining_time}}";

class ExpandedControlsAdSkipBox extends StatefulWidget {
  final ExpandedControlsAdSkipBoxController controller;

  final _defaultSkipAdTimerText =
      "You can skip this ad in $SKIP_AD_TIMER_PLACEHOLDER...";
  final _defaultSkipAdButtonText = "Skip Ad";

  /// Label to indicate remaining time for ad. Default is "You can skip this ad in {{skip_remaining_time}}...",
  /// where {{skip_remaining_time}} is replaced with the remaining time.
  /// {{skip_remaining_time}} can be found in the constant SKIP_AD_TIMER_PLACEHOLDER.
  final String? skipAdTimerText;

  /// Label for the Skip Ad button. Default is "Skip Ad".
  final String? skipAdButtonText;
  final VoidCallback? onSkipPressed;

  const ExpandedControlsAdSkipBox({
    Key? key,
    required this.controller,
    this.skipAdButtonText,
    this.skipAdTimerText,
    this.onSkipPressed,
  }) : super(key: key);

  @override
  State<ExpandedControlsAdSkipBox> createState() =>
      _ExpandedControlsAdSkipBoxState();
}

class _ExpandedControlsAdSkipBoxState extends State<ExpandedControlsAdSkipBox> {
  int progress = 0;
  int duration = 0;
  int whenSkippable = 5000;

  @override
  void initState() {
    widget.controller.addListener(_onProgressUpdated);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onProgressUpdated);
    super.dispose();
  }

  void _onProgressUpdated() {
    setState(() {
      if (!mounted) return;
      this.progress = widget.controller.progress;
      this.duration = widget.controller.duration;
      this.whenSkippable = widget.controller.whenSkippable;
    });
  }

  String _replaceRemainingTime(
      String textWithPlaceholder, String remainingTime) {
    return textWithPlaceholder.replaceAll(
        SKIP_AD_TIMER_PLACEHOLDER, remainingTime);
  }

  @override
  Widget build(BuildContext context) {
    final canSkip = progress > whenSkippable;
    if (canSkip) {
      return ExpandedControlsBasicButton(
        text: widget.skipAdButtonText ?? widget._defaultSkipAdButtonText,
        onPressed: widget.onSkipPressed,
      );
    }

    final remainingTimeMs = this.whenSkippable - this.progress;
    final remainingTimeD = Duration(milliseconds: remainingTimeMs);
    final durationD = Duration(milliseconds: this.duration);

    final remainingTime = _positionToString(remainingTimeD, durationD);
    final baseLabel = widget.skipAdTimerText ?? widget._defaultSkipAdTimerText;
    final label = _replaceRemainingTime(baseLabel, remainingTime);
    return Text(
      label,
      style: TextStyle(color: Colors.white),
    );
  }
}

String _positionToString(Duration d, Duration total) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  if (total.inSeconds <= 60) {
    // This is less than a minute, I display only seconds
    return "${d.inSeconds}";
  }

  if (total.inMinutes <= 60) {
    // This is less than a hour, I display only minutes and seconds
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
}
