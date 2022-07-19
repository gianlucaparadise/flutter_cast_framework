import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/src/PlatformBridgeApis.dart';
import 'package:meta/meta.dart';

typedef MediaQueueItemsInsertedInRangeCallback = void Function(
    int insertIndex, int insertCount);
typedef MediaQueueItemsChangedAtIndexesCallback = void Function(
    List<int?> indexes);
typedef MediaQueueItemsReorderedAtIndexesCallback = void Function(
    List<int?> indexes, int insertBeforeIndex);

class MediaQueue {
  final CastHostApi _hostApi;

  MediaQueue(this._hostApi) {
    this.itemUpdatedAtIndexStream =
        this._itemUpdatedAtIndexStreamController.stream;
  }

  void dispose() {
    this._itemUpdatedAtIndexStreamController.close();
  }

  Future<int> getItemCount() {
    return _hostApi.getQueueItemCount();
  }

  Future<MediaQueueItem> getItemAtIndex(int index) {
    return _hostApi.getQueueItemAtIndex(index);
  }

  /// Called when a contiguous range of queue items have been inserted into the queue.
  MediaQueueItemsInsertedInRangeCallback? onItemsInsertedInRange;

  /// Called when the queue has been entirely reloaded.
  VoidCallback? onItemsReloaded;

  /// Called when one or more queue items have been removed from the queue.
  MediaQueueItemsChangedAtIndexesCallback? onItemsRemovedAtIndexes;

  /// Called when one or more queue items have been reordered in the queue.
  MediaQueueItemsReorderedAtIndexesCallback? onItemsReorderedAtIndexes;

  /// Called when one or more queue items have been updated in the queue.
  MediaQueueItemsChangedAtIndexesCallback? onItemsUpdatedAtIndexes;

  /// Called when one or more changes have been made to the queue.
  VoidCallback? onMediaQueueChanged;

  /// Called when one or more changes are about to be made to the queue.
  VoidCallback? onMediaQueueWillChange;

  final _itemUpdatedAtIndexStreamController = StreamController<int>.broadcast();
  late Stream<int> itemUpdatedAtIndexStream;

  /// Internal method that shouldn't be visible
  @internal
  void dispatchItemUpdatedAtIndex(List<int?> indexes) {
    indexes.forEach((i) {
      if (i != null) {
        this._itemUpdatedAtIndexStreamController.add(i);
      }
    });
  }
}
