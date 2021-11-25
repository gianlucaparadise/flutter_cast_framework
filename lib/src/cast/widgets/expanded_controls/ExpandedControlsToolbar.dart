import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';

class ExpandedControlsToolbar extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final String title;
  final String subtitle;
  final VoidCallback? onBackTapped;

  const ExpandedControlsToolbar({
    required this.castFramework,
    this.title = "",
    this.subtitle = "",
    this.onBackTapped,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .headline5
        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white);

    final subtitleStyle =
        Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.grey);

    return Row(
      children: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ),
          onTap: onBackTapped,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                this.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              Text(
                this.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle,
              ),
            ],
          ),
        ),
        CastButton(
          castFramework: castFramework,
        )
      ],
    );
  }
}
