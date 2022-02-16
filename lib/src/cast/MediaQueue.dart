import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/src/PlatformBridgeApis.dart';

typedef MediaQueueItemsInsertedInRangeCallback = void Function(
    int insertIndex, int insertCount);
typedef MediaQueueItemsChangedAtIndexesCallback = void Function(
    List<int?> indexes);
typedef MediaQueueItemsReorderedAtIndexesCallback = void Function(
    List<int?> indexes, int insertBeforeIndex);

class MediaQueue {
  final CastHostApi _hostApi;

  MediaQueue(this._hostApi);

  /// Called when a contiguous range of queue items have been inserted into the queue.
  MediaQueueItemsInsertedInRangeCallback? itemsInsertedInRange;

  /// Called when the queue has been entirely reloaded.
  VoidCallback? itemsReloaded;

  /// Called when one or more queue items have been removed from the queue.
  MediaQueueItemsChangedAtIndexesCallback? itemsRemovedAtIndexes;

  /// Called when one or more queue items have been reordered in the queue.
  MediaQueueItemsReorderedAtIndexesCallback? itemsReorderedAtIndexes;

  /// Called when one or more queue items have been updated in the queue.
  MediaQueueItemsChangedAtIndexesCallback? itemsUpdatedAtIndexes;

  /// Called when one or more changes have been made to the queue.
  VoidCallback? mediaQueueChanged;

  /// Called when one or more changes are about to be made to the queue.
  VoidCallback? mediaQueueWillChange;
}
