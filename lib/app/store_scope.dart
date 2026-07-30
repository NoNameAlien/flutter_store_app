import 'package:flutter/widgets.dart';

import '../features/store/application/store_controller.dart';

class StoreScope extends InheritedNotifier<StoreController> {
  const StoreScope({
    super.key,
    required StoreController controller,
    required super.child,
  }) : super(notifier: controller);

  static StoreController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope is missing above this widget.');
    return scope!.notifier!;
  }
}
