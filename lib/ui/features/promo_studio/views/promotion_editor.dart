import 'package:flutter/material.dart';

import '../../../../domain/models/product.dart';
import '../../../../domain/models/promotion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/photo_picker.dart';
import '../../home/widgets/home_sections.dart' show formatDateRange;

/// Create / edit form for a promotion (spec §8.2). Pops with the promotion
/// to save, or null if dismissed.
Future<Promotion?> showPromotionEditor(
  BuildContext context, {
  required List<Product> products,
  Promotion? existing,
}) {
  return showModalBottomSheet<Promotion>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.cream,
    builder: (_) => _PromotionEditor(products: products, existing: existing),
  );
}

class _PromotionEditor extends StatefulWidget {
  const _PromotionEditor({required this.products, this.existing});

  final List<Product> products;
  final Promotion? existing;

  @override
  State<_PromotionEditor> createState() => _PromotionEditorState();
}

class _PromotionEditorState extends State<_PromotionEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _offer = TextEditingController(text: widget.existing?.offer);
  late final _description = TextEditingController(text: widget.existing?.description);
  late DateTime _start = widget.existing?.startDate ?? _today;
  late DateTime _end = widget.existing?.endDate ?? _today.add(const Duration(days: 7));
  late String? _productId = widget.existing?.relatedProductId;
  late String? _image = widget.existing?.imageAsset;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _title.dispose();
    _offer.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: _today.subtract(const Duration(days: 1)),
      lastDate: _today.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range != null) {
      setState(() {
        _start = range.start;
        _end = range.end;
      });
    }
  }

  void _save(PromotionState state) {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.pop(
      context,
      Promotion(
        id: id,
        title: _title.text.trim(),
        offer: _offer.text.trim(),
        description: _description.text.trim(),
        startDate: _start,
        endDate: _end,
        state: state,
        imageAsset: _image,
        relatedProductId: _productId,
      ),
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(editing ? 'Edit promotion' : 'Create promotion', style: AppTypography.display),
                const SizedBox(height: 4),
                Text('Customers within 100 meters of your business can be reached.',
                    style: AppTypography.bodyMuted),
                const SizedBox(height: AppSpace.xl),
                TextFormField(
                  controller: _offer,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'The offer',
                    hintText: 'Buy 1 Take 1, ₱50 off, Free fitting…',
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Describe the offer' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Promotion title'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Give your promotion a title' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Details (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDates,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Runs',
                      suffixIcon: Icon(Icons.event_rounded, color: AppColors.tealInk),
                    ),
                    child: Text(formatDateRange(_start, _end), style: AppTypography.bodyText),
                  ),
                ),
                if (widget.products.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.lg),
                  DropdownButtonFormField<String?>(
                    initialValue: _productId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Related item (optional)'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('None')),
                      for (final p in widget.products)
                        DropdownMenuItem<String?>(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (v) => setState(() => _productId = v),
                  ),
                ],
                const SizedBox(height: AppSpace.lg),
                _ImageField(
                  path: _image,
                  onPick: () async {
                    final p = await pickPhoto(context, title: 'Promotion image');
                    if (p != null) setState(() => _image = p);
                  },
                  onClear: () => setState(() => _image = null),
                ),
                const SizedBox(height: AppSpace.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _save(PromotionState.active),
                    child: Text(editing ? 'Save and publish' : 'Publish now'),
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _save(PromotionState.draft),
                    child: const Text('Save as draft'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageField extends StatelessWidget {
  const _ImageField({required this.path, required this.onPick, required this.onClear});

  final String? path;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add promotion image'),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: AppImage(path!, semanticLabel: 'Promotion image'),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _RoundIcon(icon: Icons.swap_horiz_rounded, label: 'Change image', onTap: onPick),
              const SizedBox(width: 6),
              _RoundIcon(icon: Icons.close_rounded, label: 'Remove image', onTap: onClear),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: AppColors.deepTeal),
      ),
    );
  }
}
