import 'package:flutter/material.dart';

class ExpandedControlsHighlightedText extends StatelessWidget {
  final String text;

  const ExpandedControlsHighlightedText({
    Key? key,
    this.text = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          this.text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
