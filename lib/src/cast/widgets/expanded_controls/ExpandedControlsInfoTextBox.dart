import 'package:flutter/material.dart';

class ExpandedControlsInfoTextBox extends StatelessWidget {
  final String text;

  const ExpandedControlsInfoTextBox({
    Key? key,
    this.text = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
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
