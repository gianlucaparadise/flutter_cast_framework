import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/src/cast/widgets/queue_list/QueueListItemHolder.dart';
import 'package:flutter_cast_framework/src/cast/widgets/queue_list/utils.dart';

class QueueList extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final ListItemBuilder listItemBuilder;
  final EmptyStateBuilder? emptyListStateBuilder;
  final EmptyStateBuilder? emptyItemStateBuilder;

  QueueList({
    Key? key,
    required this.castFramework,
    required this.listItemBuilder,
    this.emptyListStateBuilder,
    this.emptyItemStateBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessionManager = castFramework.castContext.sessionManager;

    Widget _getEmptyState(BuildContext context) {
      if (emptyListStateBuilder == null) return defaultEmptyState();
      return emptyListStateBuilder!(context, false, null);
    }

    Widget _getErrorState(BuildContext context, Object? error) {
      if (emptyListStateBuilder == null) return defaultEmptyState();
      return emptyListStateBuilder!(context, false, error);
    }

    Widget _getLoadingState(BuildContext context) {
      if (emptyListStateBuilder == null) return defaultEmptyState();
      return emptyListStateBuilder!(context, true, null);
    }

    Widget _getList(int count) {
      return ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          return QueueListItemHolder(
            castFramework: this.castFramework,
            index: index,
            listItemBuilder: listItemBuilder,
            emptyItemStateBuilder: emptyItemStateBuilder,
          );
        },
      );
    }

    return FutureBuilder<int>(
      future: sessionManager.remoteMediaClient.mediaQueue.getItemCount(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final count = snapshot.data;
          if (count == null || count < 0) {
            return _getEmptyState(context);
          }

          return _getList(count);
        } else if (snapshot.hasError) {
          return _getErrorState(context, snapshot.error);
        } else {
          return _getLoadingState(context);
        }
      },
    );
  }
}
