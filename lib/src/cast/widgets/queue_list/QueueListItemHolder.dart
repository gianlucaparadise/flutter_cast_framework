import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/src/cast/widgets/queue_list/utils.dart';

typedef ListItemBuilder = Widget Function(
  BuildContext context,
  MediaQueueItem item,
);

class QueueListItemHolder extends StatefulWidget {
  final FlutterCastFramework castFramework;
  final ListItemBuilder listItemBuilder;
  final EmptyStateBuilder? emptyItemStateBuilder;
  final int index;

  const QueueListItemHolder({
    Key? key,
    required this.castFramework,
    required this.listItemBuilder,
    required this.index,
    this.emptyItemStateBuilder,
  }) : super(key: key);

  Widget _getEmptyState(BuildContext context) {
    if (emptyItemStateBuilder == null) return defaultEmptyState();
    return emptyItemStateBuilder!(context, false, null);
  }

  Widget _getErrorState(BuildContext context, Object? error) {
    if (emptyItemStateBuilder == null) return defaultEmptyState();
    return emptyItemStateBuilder!(context, false, error);
  }

  Widget _getLoadingState(BuildContext context) {
    if (emptyItemStateBuilder == null) return defaultEmptyState();
    return emptyItemStateBuilder!(context, true, null);
  }

  @override
  State<QueueListItemHolder> createState() => _QueueListItemHolderState();
}

class _QueueListItemHolderState extends State<QueueListItemHolder> {
  bool _hasChanged = false;

  @override
  Widget build(BuildContext context) {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    final mediaQueue = sessionManager.remoteMediaClient.mediaQueue;

    return FutureBuilder<MediaQueueItem>(
      future: mediaQueue.getItemAtIndex(widget.index),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final item = snapshot.data;

          if (item == null || item.itemId == null) {
            // When itemId is null, the item is ready and needs to be
            // re-requested once it's updated
            final sub = mediaQueue.itemUpdatedAtIndexStream.listen(null);
            sub.onData((i) {
              final isUpdated = i == widget.index;
              if (isUpdated) {
                sub.cancel();
                setState(() {
                  // FIXME: I don't like how the refresh is triggered
                  _hasChanged = true;
                });
              }
            });

            return widget._getLoadingState(context);
          }

          return widget.listItemBuilder(context, item);
        } else if (snapshot.hasError) {
          return widget._getErrorState(context, snapshot.error);
        } else {
          return widget._getLoadingState(context);
        }
      },
    );
  }
}
