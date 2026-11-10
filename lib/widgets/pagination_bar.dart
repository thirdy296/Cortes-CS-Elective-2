import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/shop_providers.dart';

/// "‹ 1 2 3 ›" controls. Tapping only changes the page in [shopFilterProvider];
/// the provider then fetches that page from Supabase with `.range()`.
class PaginationBar extends ConsumerWidget {
  const PaginationBar({super.key, required this.page});

  final ProductPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shopFilterProvider.notifier);
    final first = page.totalCount == 0 ? 0 : page.page * page.pageSize + 1;
    final last = page.page * page.pageSize + page.items.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous page',
                onPressed: page.hasPrevious ? notifier.previousPage : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < page.totalPages; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _PageButton(
                            number: i + 1,
                            selected: i == page.page,
                            onTap: () => notifier.goToPage(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: page.hasNext ? notifier.nextPage : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Text(
            'Showing $first–$last of ${page.totalCount} products',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 40,
      height: 40,
      child: selected
          ? FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                disabledBackgroundColor: scheme.primary,
                disabledForegroundColor: scheme.onPrimary,
              ),
              child: Text('$number'),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              child: Text('$number'),
            ),
    );
  }
}
