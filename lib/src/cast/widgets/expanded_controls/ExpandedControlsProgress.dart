import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExpandedControlsProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white);

    return Column(
      children: [
        LinearProgressIndicator(
          color: Colors.red,
          backgroundColor: Colors.grey,
          value: 0.5,
        ),
        Container(height: 8), // Spacer
        Row(
          children: [
            Text(
              "start",
              style: textStyle,
            ),
            Spacer(),
            Text(
              "end",
              style: textStyle,
            ),
          ],
        ),
      ],
    );
  }
}
