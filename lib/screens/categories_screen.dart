import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/shop_providers.dart';
import '../widgets/state_views.dart';

/// Admin: list, add, rename and delete categories.
class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    Category? category,
  ]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(initial: category?.name),
    );
    if (name == null || !context.mounted) return;
    final admin = ref.read(catalogAdminProvider);
    try {
      if (category == null) {
        await admin.createCategory(name);
      } else {
        await admin.renameCategory(category.id, name);
      }
      if (context.mounted) showInfoSnack(context, 'Saved "$name"');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${c.name}"?'),
        content: const Text(
          'Only empty categories can be deleted. Move or delete its '
          'products first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete ${c.name}'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(catalogAdminProvider).deleteCategory(c.id);
      if (context.mounted) showInfoSnack(context, 'Deleted "${c.name}"');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-category',
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (list) => list.isEmpty
            ? const MessageView(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                message: 'Add one to start building the catalog.',
              )
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = list[i];
                  return ListTile(
                    leading: const Icon(Icons.label_outline),
                    title: Text(c.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Rename',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _edit(context, ref, c),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _delete(context, ref, c),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.initial});
  final String? initial;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add category' : 'Rename category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) => _submit(),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
