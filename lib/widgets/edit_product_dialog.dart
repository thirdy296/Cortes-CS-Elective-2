import 'package:flutter/material.dart';

import '../models/product.dart';

/// Returns the edited product, or null if cancelled.
Future<Product?> showEditProductDialog(BuildContext context, Product product) {
  return showDialog<Product>(
    context: context,
    builder: (_) => _EditProductDialog(product: product),
  );
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({required this.product});
  final Product product;

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product.name);
  late final _description = TextEditingController(
    text: widget.product.description,
  );
  late final _category = TextEditingController(text: widget.product.category);
  late final _price = TextEditingController(
    text: widget.product.price.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _category.dispose();
    _price.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      widget.product.copyWith(
        name: _name.text.trim(),
        description: _description.text.trim(),
        category: _category.text.trim(),
        price: double.parse(_price.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: _required,
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₱',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Enter a number';
                  if (value < 0) return 'Price cannot be negative';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
