import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../providers/shop_providers.dart';
import '../widgets/state_views.dart';

/// Price must be a plain number that is 0 or more.
String? validatePrice(String? input) {
  final text = input?.trim() ?? '';
  if (!RegExp(r'^-?(\d+\.?\d*|\.\d+)$').hasMatch(text)) return 'Enter a number';
  if (double.parse(text) < 0) return 'Must be 0 or more';
  return null;
}

/// Stock must be a whole number from 0 to 32767 (a smallint in the database).
String? validateStock(String? input) {
  final text = input?.trim() ?? '';
  if (!RegExp(r'^-?\d+$').hasMatch(text)) return 'Enter a whole number';
  if (text.startsWith('-') && RegExp(r'[1-9]').hasMatch(text)) {
    return 'Must be 0 or more';
  }
  final value = int.tryParse(text);
  if (value == null || value > 32767) return 'Max 32767';
  return null;
}

/// Admin form to add a product, or edit one when [product] is given (the
/// fields start with its current values).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _description = TextEditingController(
    text: widget.product?.description,
  );
  late final _price = TextEditingController(
    text: widget.product?.price.toStringAsFixed(2),
  );
  late final _stock = TextEditingController(
    text: widget.product?.stock.toString(),
  );
  late int? _categoryId = widget.product?.categoryId;
  late String? _imageUrl = widget.product?.imageUrl;

  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) showErrorSnack(context, 'Image must be 5 MB or smaller.');
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
      });
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final admin = ref.read(catalogAdminProvider);
    try {
      var imageUrl = _imageUrl;
      if (_pickedBytes != null) {
        imageUrl = await admin.uploadImage(_pickedBytes!, _pickedName!);
      }
      final draft = ProductDraft(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: double.parse(_price.text.trim()),
        stock: int.parse(_stock.text.trim()),
        categoryId: _categoryId!,
        imageUrl: imageUrl,
      );
      if (_isEdit) {
        await admin.updateProduct(widget.product!.id, draft);
      } else {
        await admin.createProduct(draft);
      }
      if (!mounted) return;
      showInfoSnack(
        context,
        _isEdit ? 'Saved "${draft.name}"' : 'Added "${draft.name}"',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit product' : 'Add product')),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const MessageView(
              icon: Icons.category_outlined,
              title: 'Add a category first',
              message:
                  'Every product needs a category. Create one in the '
                  'Categories tab.',
            );
          }
          // A product's category may have been deleted meanwhile.
          if (_categoryId != null && list.every((c) => c.id != _categoryId)) {
            _categoryId = null;
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ImagePickerTile(
                  bytes: _pickedBytes,
                  url: _imageUrl,
                  onPick: _saving ? null : _pickImage,
                  onRemove: _saving
                      ? null
                      : () => setState(() {
                          _pickedBytes = null;
                          _pickedName = null;
                          _imageUrl = null;
                        }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          prefixText: '₱ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        decoration: const InputDecoration(labelText: 'Stock *'),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        validator: validateStock,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: [
                    for (final c in list)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Choose a category' : null,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isEdit ? 'Save changes' : 'Add product'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.bytes,
    required this.url,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final String? url;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = bytes != null || (url != null && url!.isNotEmpty);
    final Widget preview = bytes != null
        ? Image.memory(bytes!, fit: BoxFit.cover)
        : hasImage
        ? Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          )
        : Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: scheme.primary,
          );

    return Column(
      children: [
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 180,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: preview,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image_outlined),
              label: Text(hasImage ? 'Change image' : 'Choose image'),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.hide_image_outlined),
                label: const Text('Remove'),
              ),
          ],
        ),
      ],
    );
  }
}
