import 'package:flutter/material.dart';

class ExpandedControlsBasicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ExpandedControlsBasicButton({
    Key? key,
    this.text = "",
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: this.onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(),
        side: BorderSide(
          width: 1,
          color: Colors.white,
        ),
      ),
      child: Text(text),
    );
  }
}
