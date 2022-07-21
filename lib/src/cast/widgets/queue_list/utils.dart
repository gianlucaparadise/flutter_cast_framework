import 'package:flutter/widgets.dart';

typedef EmptyStateBuilder = Widget Function(
    BuildContext context, bool isLoading, Object? error);

final defaultEmptyState = () => SizedBox.shrink();
