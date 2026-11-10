import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/shop_providers.dart';
import '../utils/formatters.dart';

/// Price slider. While dragging, only the local labels move; the Supabase
/// query runs once when the user lets go (`onChangeEnd`), not on every frame.
class PriceRangeFilter extends ConsumerStatefulWidget {
  const PriceRangeFilter({super.key});

  @override
  ConsumerState<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends ConsumerState<PriceRangeFilter> {
  /// Values while the thumbs are being dragged; null when not dragging.
  RangeValues? _dragging;

  @override
  Widget build(BuildContext context) {
    final boundsAsync = ref.watch(priceBoundsProvider);
    final selected = ref.watch(shopFilterProvider.select((f) => f.priceRange));

    return boundsAsync.when(
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => Text('Could not load prices: $e'),
      data: (bounds) {
        if (bounds.max <= bounds.min) return const SizedBox.shrink();
        final values = _clamp(_dragging ?? selected, bounds);
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Price', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${formatPeso(values.start)} – ${formatPeso(values.end)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            RangeSlider(
              min: bounds.min,
              max: bounds.max,
              values: values,
              labels: RangeLabels(
                formatPeso(values.start),
                formatPeso(values.end),
              ),
              onChanged: (v) => setState(
                () => _dragging = RangeValues(
                  v.start.roundToDouble(),
                  v.end.roundToDouble(),
                ),
              ),
              onChangeEnd: (v) {
                final rounded = _clamp(
                  RangeValues(v.start.floorToDouble(), v.end.ceilToDouble()),
                  bounds,
                );
                setState(() => _dragging = null);
                ref.read(shopFilterProvider.notifier).setPriceRange(rounded);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatPeso(bounds.min), style: theme.textTheme.bodySmall),
                Text(formatPeso(bounds.max), style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Keeps the range inside the table's bounds (they can shrink after an
  /// edit or delete). `null` means the full range.
  RangeValues _clamp(RangeValues? range, PriceBounds b) {
    if (range == null) return RangeValues(b.min, b.max);
    final start = range.start.clamp(b.min, b.max);
    final end = range.end.clamp(start, b.max);
    return RangeValues(start, end);
  }
}
