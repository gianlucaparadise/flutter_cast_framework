import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/widgets.dart';
import 'package:flutter_cast_framework_example/widgets/QueueListItem.dart';

class QueueRoute extends StatelessWidget {
  final FlutterCastFramework castFramework;

  const QueueRoute({
    Key? key,
    required this.castFramework,
  }) : super(key: key);

  Widget _getEmptyQueueMessage(BuildContext context, String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _getEmptyItemMessage(BuildContext context, String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: QueueList(
        castFramework: castFramework,
        listItemBuilder: (BuildContext context, MediaQueueItem item) {
          return QueueListItem(item: item);
        },
        emptyListStateBuilder: (context, isLoading, error) {
          if (isLoading) {
            return _getEmptyQueueMessage(context, "Loading...");
          }

          if (error != null) {
            debugPrint(
              "MediaQueue - error while retrieving items count $error",
            );
            return _getEmptyQueueMessage(context, "An error occurred");
          }

          return _getEmptyQueueMessage(context, "Queue is empty!");
        },
        emptyItemStateBuilder: (context, isLoading, error) {
          if (isLoading) {
            return _getEmptyItemMessage(context, "Loading...");
          }

          if (error != null) {
            debugPrint(
              "MediaQueue - error while retrieving items count $error",
            );
            return _getEmptyItemMessage(context, "An error occurred");
          }

          return _getEmptyItemMessage(context, "Item is empty!");
        },
      ),
    );
  }
}
