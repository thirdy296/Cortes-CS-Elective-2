import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../widgets/order_tile.dart';
import '../widgets/state_views.dart';

/// Customer: own orders only, newest first.
class OrderHistoryView extends ConsumerWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);
    return orders.when(
      loading: () => const LoadingView(label: 'Loading your orders'),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(myOrdersProvider)),
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.refresh(myOrdersProvider.future),
        child: list.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  MessageView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Orders you place will show up here.',
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                findChildIndexCallback: (key) => orderIndexForKey(list, key),
                itemBuilder: (_, i) =>
                    OrderTile(key: ValueKey(list[i].id), order: list[i]),
              ),
      ),
    );
  }
}
