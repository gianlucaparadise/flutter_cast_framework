import 'package:flutter/material.dart';

class ExpandedControlsProgressController extends ChangeNotifier {
  int progress = 0;
  int duration = 0;

  void updateProgress(int progress, int duration) {
    this.progress = progress;
    this.duration = duration;
    notifyListeners();
  }
}

class ExpandedControlsProgress extends StatefulWidget {
  final ExpandedControlsProgressController controller;

  const ExpandedControlsProgress({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ExpandedControlsProgress> createState() =>
      _ExpandedControlsProgressState();
}

class _ExpandedControlsProgressState extends State<ExpandedControlsProgress> {
  int progress = 0;
  int duration = 0;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);

    // this is the denominator, can't be 0
    final durationFix = this.duration == 0 ? 1 : this.duration;
    final progressPercent = this.progress / durationFix;

    final progressD = Duration(milliseconds: this.progress);
    final durationD = Duration(milliseconds: this.duration);

    return Column(
      children: [
        LinearProgressIndicator(
          color: Colors.red,
          backgroundColor: Colors.grey,
          value: progressPercent,
        ),
        Container(height: 8), // Spacer
        Row(
          children: [
            Text(
              _positionToString(progressD, durationD),
              style: textStyle,
            ),
            Spacer(),
            Text(
              _positionToString(durationD, durationD),
              style: textStyle,
            ),
          ],
        ),
      ],
    );
  }
}

String _positionToString(Duration d, Duration total) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  if (total.inMinutes <= 60) {
    // This is less than a hour, I display only minutes and seconds
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
}
