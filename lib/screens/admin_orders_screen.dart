import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../providers/order_providers.dart';
import '../utils/formatters.dart';
import '../widgets/order_tile.dart';
import '../widgets/state_views.dart';

/// Admin: every customer's orders, newest first, with a status picker.
class AdminOrdersView extends ConsumerWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);
    return orders.when(
      loading: () => const LoadingView(label: 'Loading orders'),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(allOrdersProvider)),
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.refresh(allOrdersProvider.future),
        child: list.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  MessageView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Customer orders will show up here.',
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (_, i) => OrderTile(
                  order: list[i],
                  trailing: _StatusPicker(order: list[i]),
                ),
              ),
      ),
    );
  }
}

class _StatusPicker extends ConsumerStatefulWidget {
  const _StatusPicker({required this.order});
  final Order order;

  @override
  ConsumerState<_StatusPicker> createState() => _StatusPickerState();
}

class _StatusPickerState extends ConsumerState<_StatusPicker> {
  bool _saving = false;

  Future<void> _change(String? status) async {
    if (status == null || status == widget.order.status) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(orderActionsProvider)
          .updateStatus(widget.order.id, status);
      if (mounted) {
        showInfoSnack(
          context,
          'Order #${widget.order.id} marked ${capitalize(status)}',
        );
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Status'),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: widget.order.status,
            isDense: true,
            items: [
              for (final s in kOrderStatuses)
                DropdownMenuItem(value: s, child: Text(capitalize(s))),
            ],
            onChanged: _saving ? null : _change,
          ),
        ),
        if (_saving)
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}
