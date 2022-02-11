import 'package:flutter/widgets.dart';

extension MyExtendedList<T> on List<T> {
  T? lastOrNull() {
    return this.isNotEmpty ? this.last : null;
  }
}

typedef ItemWidgetBuilder<Item> = Widget Function(Item item);

/// When this return null, the pagination stops
typedef FutureItemsCallback<Item> = Future<List<Item>> Function(
    Item? lastLoadedItem);
typedef ItemCallback<Item> = void Function(Item item);

class MyPaginatedList<Item> extends StatefulWidget {
  final ItemWidgetBuilder<Item> widgetBuilder;
  final FutureItemsCallback<Item> loadMore;

  const MyPaginatedList({
    Key? key,
    required this.widgetBuilder,
    required this.loadMore,
  }) : super(key: key);

  @override
  _MyPaginatedListState createState() => _MyPaginatedListState();
}

class _MyPaginatedListState<Item> extends State<MyPaginatedList<Item>> {
  List<Item> items = [];
  bool shouldTryToLoadMore = true;

  @override
  void initState() {
    super.initState();
    waitOnItems(); // FIXME: this should be before initstate
  }

  void waitOnItems() async {
    try {
      final items = await widget.loadMore(this.items.lastOrNull());
      this.shouldTryToLoadMore = items.isNotEmpty;
      setState(() {
        this.items.addAll(items);
      });
    } catch (error) {
      print(error); // FIXME: this should call a callback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return buildLoadingProgress();
    } else {
      //TODO: show progress bar at the bottom if loading more
      return buildList();
    }
  }

  Widget buildLoadingProgress() {
    return Center(
      child: Text("Loading..."),
    );
  }

  Widget buildList() {
    return ListView.builder(
        itemCount: shouldTryToLoadMore ? null : items.length,
        itemBuilder: (context, index) {
          if (shouldTryToLoadMore && index == items.length - 1) {
            waitOnItems();
            return SizedBox.shrink();
          } else if (index >= items.length) {
            return SizedBox.shrink();
            // } else if (widget.onItemSelected != null) {
            //   return InkWell(
            //     onTap: () => {widget.onItemSelected(items[index])},
            //     child: widget.widgetBuilder(items[index]),
            //   );
          } else {
            return widget.widgetBuilder(items[index]);
          }
        });
  }
}
