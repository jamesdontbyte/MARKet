import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/business.dart';
import '../../../../domain/models/business_location.dart';
import '../../../../domain/models/msme_category.dart';
import '../../../../domain/models/verification_document.dart';
import '../../../../domain/models/verification_status.dart';
import '../../../core/session_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/geofence_map.dart';
import '../../../core/widgets/photo_picker.dart';
import '../../../core/widgets/verification_badge.dart';
import '../../home/view_models/home_view_model.dart';

/// Shared chrome for Account sub-pages.
class AccountSubPage extends StatelessWidget {
  const AccountSubPage({super.key, required this.title, required this.child, this.bottom});

  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppTypography.title.copyWith(color: Colors.white))),
      body: child,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.md, AppSpace.xl, AppSpace.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.hairline)),
                ),
                child: bottom,
              ),
            ),
    );
  }
}

void _toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

// ---------------------------------------------------------------------------
// Personal information (§10.1)
// ---------------------------------------------------------------------------

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: context.read<SessionViewModel>().account?.fullName);
  late final _email = TextEditingController(text: context.read<SessionViewModel>().account?.email);
  late final _mobile = TextEditingController(text: context.read<SessionViewModel>().account?.mobile);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final session = context.read<SessionViewModel>();
    final current = session.account;
    if (current == null) return;
    session.updateAccount(current.copyWith(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
    ));
    Navigator.pop(context);
    _toast(context, 'Personal information saved');
  }

  @override
  Widget build(BuildContext context) {
    return AccountSubPage(
      title: 'Personal information',
      bottom: SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save'))),
      child: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.xl),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Enter your full name' : null,
            ),
            const SizedBox(height: AppSpace.lg),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                final e = (v ?? '').trim();
                if (e.isEmpty && _mobile.text.trim().isEmpty) return 'Enter an email or a mobile number';
                if (e.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpace.lg),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile number'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business information (§10.2)
// ---------------------------------------------------------------------------

class BusinessInfoPage extends StatefulWidget {
  const BusinessInfoPage({super.key});

  @override
  State<BusinessInfoPage> createState() => _BusinessInfoPageState();
}

class _BusinessInfoPageState extends State<BusinessInfoPage> {
  final _key = GlobalKey<FormState>();
  late final Business _b = context.read<HomeViewModel>().business!;
  late final _name = TextEditingController(text: _b.name);
  late final _desc = TextEditingController(text: _b.description);
  late final _barangay = TextEditingController(text: _b.barangay);
  late final _address = TextEditingController(text: _b.address);
  late final _contact = TextEditingController(text: _b.contactNumber);
  late final _hours = TextEditingController(text: _b.operatingHours);
  late MsmeCategory _category = _b.msmeCategory;
  late String? _municipality =
      antiqueMunicipalities.contains(_b.municipality) ? _b.municipality : null;

  @override
  void dispose() {
    for (final c in [_name, _desc, _barangay, _address, _contact, _hours]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    context.read<HomeViewModel>().update((b) => b.copyWith(
          name: _name.text.trim(),
          category: _category.label,
          description: _desc.text.trim(),
          municipality: _municipality,
          barangay: _barangay.text.trim(),
          address: _address.text.trim(),
          contactNumber: _contact.text.trim(),
          operatingHours: _hours.text.trim(),
        ));
    Navigator.pop(context);
    _toast(context, 'Business information saved');
  }

  String? _req(String? v, String m) => (v ?? '').trim().isEmpty ? m : null;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpace.lg);
    return AccountSubPage(
      title: 'Business information',
      bottom: SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save changes'))),
      child: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.xl),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Business name'),
              validator: (v) => _req(v, 'Enter your business name'),
            ),
            gap,
            DropdownButtonFormField<MsmeCategory>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in MsmeCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (v) => _category = v ?? _category,
            ),
            gap,
            TextFormField(
              controller: _desc,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              validator: (v) => _req(v, 'Describe your business'),
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _municipality,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Municipality'),
              items: [for (final m in antiqueMunicipalities) DropdownMenuItem(value: m, child: Text(m))],
              onChanged: (v) => _municipality = v,
              validator: (v) => v == null ? 'Choose a municipality' : null,
            ),
            gap,
            TextFormField(
              controller: _barangay,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Barangay'),
              validator: (v) => _req(v, 'Enter your barangay'),
            ),
            gap,
            TextFormField(
              controller: _address,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Street / address'),
              validator: (v) => _req(v, 'Enter your address'),
            ),
            gap,
            TextFormField(
              controller: _contact,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact number'),
              validator: (v) => _req(v, 'Enter a contact number'),
            ),
            gap,
            TextFormField(
              controller: _hours,
              decoration: const InputDecoration(labelText: 'Operating hours'),
              validator: (v) => _req(v, 'Enter your operating hours'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business media (§10.3)
// ---------------------------------------------------------------------------

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final b = vm.business!;

    Future<void> pick(String title, Business Function(Business, String) apply) async {
      final p = await pickPhoto(context, title: title);
      if (p != null) vm.update((cur) => apply(cur, p));
    }

    return AccountSubPage(
      title: 'Business media',
      child: ListView(
        padding: const EdgeInsets.all(AppSpace.xl),
        children: [
          Text(
            'Your photos make your profile. The dashboard colors follow your storefront photo.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpace.lg),
          _MediaSlot(
            title: 'Logo',
            hint: 'A square image works best',
            path: b.logoAsset,
            aspect: 1.6,
            onPick: () => pick('Business logo', (cur, p) => cur.copyWith(logoAsset: p)),
          ),
          const SizedBox(height: AppSpace.lg),
          _MediaSlot(
            title: 'Storefront photo',
            hint: 'Shown at the top of your dashboard',
            path: b.storefrontAsset,
            aspect: 1.8,
            onPick: () => pick('Storefront photo', (cur, p) => cur.copyWith(storefrontAsset: p)),
          ),
          const SizedBox(height: AppSpace.lg),
          _MediaSlot(
            title: 'Interior photo (optional)',
            hint: 'Show customers what it looks like inside',
            path: b.interiorAsset,
            aspect: 1.8,
            onPick: () => pick('Interior photo', (cur, p) => cur.copyWith(interiorAsset: p)),
          ),
        ],
      ),
    );
  }
}

class _MediaSlot extends StatelessWidget {
  const _MediaSlot({
    required this.title,
    required this.hint,
    required this.path,
    required this.aspect,
    required this.onPick,
  });

  final String title;
  final String hint;
  final String? path;
  final double aspect;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: path != null
                ? AppImage(path!, semanticLabel: title)
                : const ColoredBox(
                    color: AppColors.tealTint,
                    child: Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.tealInk),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.section.copyWith(fontSize: 15)),
                      Text(hint, style: AppTypography.bodyMuted.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: onPick,
                  style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
                  child: Text(path == null ? 'Upload' : 'Replace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verification documents (§10.5)
// ---------------------------------------------------------------------------

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late List<VerificationDocument> _docs = List.of(context.read<HomeViewModel>().business!.documents);

  bool get _editable {
    final s = context.read<HomeViewModel>().business!.verificationStatus;
    return s == VerificationStatus.requiresCorrection || s == VerificationStatus.rejected;
  }

  VerificationDocument _doc(DocumentType t) =>
      _docs.firstWhere((d) => d.type == t, orElse: () => VerificationDocument(type: t));

  void _resubmit() {
    context.read<HomeViewModel>().update((b) => b.copyWith(
          documents: _docs,
          verificationStatus: VerificationStatus.underReview,
        ));
    Navigator.pop(context);
    _toast(context, 'Documents resubmitted for review');
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<HomeViewModel>().business!.verificationStatus;
    final complete = DocumentType.values.every((t) => _doc(t).isUploaded);
    return AccountSubPage(
      title: 'Verification documents',
      bottom: _editable
          ? SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: complete ? _resubmit : null, child: const Text('Resubmit for review')),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.all(AppSpace.xl),
        children: [
          Row(
            children: [
              Text('Status', style: AppTypography.section),
              const SizedBox(width: AppSpace.md),
              VerificationBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          for (final t in DocumentType.values) ...[
            AppCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: _doc(t).filePath != null && !_doc(t).filePath!.startsWith('demo/')
                          ? AppImage(_doc(t).filePath!, semanticLabel: '${t.label} preview')
                          : ColoredBox(
                              color: AppColors.tealTint,
                              child: Icon(
                                _doc(t).isUploaded ? Icons.task_alt_rounded : Icons.description_outlined,
                                color: AppColors.tealInk,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.label, style: AppTypography.section.copyWith(fontSize: 15)),
                        Text(_doc(t).isUploaded ? 'Submitted' : 'Missing',
                            style: AppTypography.bodyMuted.copyWith(
                              fontSize: 13,
                              color: _doc(t).isUploaded ? AppColors.tealInk : AppColors.danger,
                            )),
                      ],
                    ),
                  ),
                  if (_editable)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
                      onPressed: () async {
                        final p = await pickPhoto(context, title: t.label);
                        if (p == null) return;
                        setState(() => _docs = [
                              for (final d in DocumentType.values)
                                d == t ? VerificationDocument(type: d, filePath: p) : _doc(d),
                            ]);
                      },
                      child: const Text('Replace'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
          ],
          if (!_editable)
            Text(
              status.isVerified
                  ? 'Your documents were approved.'
                  : 'Documents can be changed if a correction is requested.',
              style: AppTypography.bodyMuted,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location (§10.6)
// ---------------------------------------------------------------------------

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  static const _fallback = LatLng(10.7447, 121.9402);
  late LatLng _pin = () {
    final l = context.read<HomeViewModel>().business!.location;
    return l == null ? _fallback : LatLng(l.latitude, l.longitude);
  }();

  void _save() {
    context.read<HomeViewModel>().update(
        (b) => b.copyWith(location: BusinessLocation(latitude: _pin.latitude, longitude: _pin.longitude)));
    Navigator.pop(context);
    _toast(context, 'Business location updated');
  }

  @override
  Widget build(BuildContext context) {
    return AccountSubPage(
      title: 'Location',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.coralInk),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  'Coverage is fixed at ${BusinessLocation.geofenceRadiusMeters.round()} meters. Drag the map to move the pin.',
                  style: AppTypography.bodyMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save location'))),
        ],
      ),
      child: GeofenceMap(center: _pin, onCenterChanged: (c) => _pin = c),
    );
  }
}
