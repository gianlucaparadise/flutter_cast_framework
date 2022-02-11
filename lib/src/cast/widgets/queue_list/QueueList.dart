import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework/src/cast/widgets/queue_list/MyPaginatedList.dart';

class QueueList extends StatefulWidget {
  final FlutterCastFramework flutterCastFramework;
  final ItemWidgetBuilder<MediaQueueItem>? widgetBuilder;

  const QueueList({
    Key? key,
    required this.flutterCastFramework,
    this.widgetBuilder,
  }) : super(key: key);

  @override
  _QueueListState createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  Widget widgetBuilder(MediaQueueItem item) {
    // TODO complete this method
    return SizedBox.shrink();
  }

  Future<List<MediaQueueItem>> loadMore(MediaQueueItem? lastLoadedItem) async {
    // TODO complete this method
    if (lastLoadedItem == null) {
      //first load request
      return [];
    } else {
      //subsequent load request(s)
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyPaginatedList<MediaQueueItem>(
      widgetBuilder: this.widget.widgetBuilder ?? widgetBuilder,
      loadMore: loadMore,
    );
  }
}
