import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/photo_picker.dart';
import '../../home/view_models/home_view_model.dart';

/// Manage products and services (spec §10.4), including the bestseller flag.
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  Future<void> _edit(BuildContext context, Business b, {Product? existing}) async {
    final result = await showModalBottomSheet<_EditorResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _ProductEditor(existing: existing, label: b.msmeCategory.itemLabel),
    );
    if (result == null || !context.mounted) return;
    final vm = context.read<HomeViewModel>();
    if (result.deleted && existing != null) {
      vm.update((cur) => cur.copyWith(products: cur.products.where((p) => p.id != existing.id).toList()));
    } else if (result.product != null) {
      final saved = result.product!;
      vm.update((cur) {
        final exists = cur.products.any((p) => p.id == saved.id);
        return cur.copyWith(
          products: exists
              ? [for (final p in cur.products) p.id == saved.id ? saved : p]
              : [...cur.products, saved],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = context.watch<HomeViewModel>().business!;
    final label = b.msmeCategory.itemLabel;
    return Scaffold(
      appBar: AppBar(title: Text(label, style: AppTypography.title.copyWith(color: Colors.white))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, b),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      body: b.products.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(b.msmeCategory.icon, size: 48, color: AppColors.tealInk),
                    const SizedBox(height: AppSpace.md),
                    Text('Nothing here yet', style: AppTypography.title),
                    const SizedBox(height: 4),
                    Text('Add what you sell or offer so customers can see it.',
                        textAlign: TextAlign.center, style: AppTypography.bodyMuted),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, 96),
              itemCount: b.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpace.md),
              itemBuilder: (context, i) {
                final p = b.products[i];
                return AppCard(
                  padding: const EdgeInsets.all(AppSpace.md),
                  onTap: () => _edit(context, b, existing: p),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: p.imageAsset != null
                              ? AppImage(p.imageAsset!, semanticLabel: p.name)
                              : ColoredBox(
                                  color: AppColors.tealTint,
                                  child: Icon(b.msmeCategory.icon, color: AppColors.tealInk),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.section.copyWith(fontSize: 15)),
                            Text('${p.category} · ${p.priceLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMuted.copyWith(fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: p.isBestseller ? 'Remove from bestsellers' : 'Mark as bestseller',
                        onPressed: () => context.read<HomeViewModel>().update((cur) => cur.copyWith(
                              products: [
                                for (final x in cur.products)
                                  x.id == p.id ? x.copyWith(isBestseller: !x.isBestseller) : x,
                              ],
                            )),
                        icon: Icon(
                          p.isBestseller ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: p.isBestseller ? AppColors.coral : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _EditorResult {
  const _EditorResult.save(Product this.product) : deleted = false;
  const _EditorResult.delete()
      : product = null,
        deleted = true;
  final Product? product;
  final bool deleted;
}

class _ProductEditor extends StatefulWidget {
  const _ProductEditor({required this.label, this.existing});
  final Product? existing;
  final String label;

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _category = TextEditingController(text: widget.existing?.category);
  late final _price = TextEditingController(text: widget.existing?.priceLabel);
  late final _desc = TextEditingController(text: widget.existing?.description);
  late bool _best = widget.existing?.isBestseller ?? false;
  late String? _image = widget.existing?.imageAsset;

  @override
  void dispose() {
    for (final c in [_name, _category, _price, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      _EditorResult.save(Product(
        id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        category: _category.text.trim(),
        priceLabel: _price.text.trim(),
        description: _desc.text.trim(),
        imageAsset: _image,
        isBestseller: _best,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(editing ? 'Edit item' : 'Add item', style: AppTypography.display),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _category,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g. Haircut, Souvenir, Room'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a category' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price or price range', hintText: '₱120 or ₱90–₱150'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a price' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _desc,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Description (optional)', alignLabelWithHint: true),
                ),
                const SizedBox(height: AppSpace.lg),
                if (_image == null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final p = await pickPhoto(context, title: 'Item photo');
                      if (p != null) setState(() => _image = p);
                    },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add photo'),
                  )
                else
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(width: 72, height: 72, child: AppImage(_image!)),
                      ),
                      const SizedBox(width: AppSpace.md),
                      TextButton(
                        onPressed: () async {
                          final p = await pickPhoto(context, title: 'Item photo');
                          if (p != null) setState(() => _image = p);
                        },
                        child: const Text('Change'),
                      ),
                      TextButton(onPressed: () => setState(() => _image = null), child: const Text('Remove')),
                    ],
                  ),
                const SizedBox(height: AppSpace.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _best,
                  activeTrackColor: AppColors.teal,
                  title: Text('Show as a bestseller', style: AppTypography.bodyText),
                  onChanged: (v) => setState(() => _best = v),
                ),
                const SizedBox(height: AppSpace.sm),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save'))),
                if (editing) ...[
                  const SizedBox(height: AppSpace.sm),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, const _EditorResult.delete()),
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('Delete item'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience used by Account to open the page.
void openProductsPage(BuildContext context) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ProductsPage()));
