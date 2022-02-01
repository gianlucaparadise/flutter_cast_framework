import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';

class QueueRoute extends StatelessWidget {
  final FlutterCastFramework castFramework;

  const QueueRoute({
    Key? key,
    required this.castFramework,
  }) : super(key: key);

  Widget _getEmptyQueueMessage(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Queue is empty!",
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: _getEmptyQueueMessage(context),
    );
  }
}
