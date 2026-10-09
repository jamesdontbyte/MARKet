import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/msme_category.dart';
import '../../../../domain/models/personal_account.dart';
import '../../../../domain/models/verification_document.dart';
import '../../../../domain/models/business_location.dart';
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
import '../../../core/widgets/wordmark.dart';
import '../../home/view_models/home_view_model.dart';
import '../view_models/onboarding_view_model.dart';

/// The MSME onboarding workflow (spec §2): personal registration → business
/// information → verification documents → verification → location & geofence.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _vm = OnboardingViewModel();
  final _personalKey = GlobalKey<FormState>();
  final _businessKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _exploreDemo() async {
    final home = context.read<HomeViewModel>();
    final session = context.read<SessionViewModel>();
    await home.load();
    if (!mounted || home.business == null) return;
    session.completeOnboarding(
      const PersonalAccount(fullName: 'Maria Dela Cruz', email: 'maria@antiquebrew.ph', mobile: '0917 555 0142'),
    );
    context.go('/home');
  }

  void _finish() {
    context.read<HomeViewModel>().setBusiness(_vm.buildBusiness());
    context.read<SessionViewModel>().completeOnboarding(_vm.buildAccount());
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.step == OnboardingStep.welcome) {
          return _Welcome(onStart: _vm.next, onDemo: _exploreDemo);
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _vm.back();
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _StepHeader(vm: _vm),
                  Expanded(child: _stepBody()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stepBody() {
    return switch (_vm.step) {
      OnboardingStep.personal => _PersonalStep(vm: _vm, formKey: _personalKey),
      OnboardingStep.business => _BusinessStep(vm: _vm, formKey: _businessKey),
      OnboardingStep.documents => _DocumentsStep(vm: _vm),
      OnboardingStep.verification => _VerificationStep(vm: _vm),
      OnboardingStep.location => _LocationStep(vm: _vm, onConfirm: _finish),
      OnboardingStep.welcome => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// Welcome
// ---------------------------------------------------------------------------

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart, required this.onDemo});

  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepTeal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wordmark(size: 22),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('For MSMEs in Antique',
                    style: AppTypography.label.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Put your business\non the map.',
                style: AppTypography.display.copyWith(color: Colors.white, fontSize: 38, height: 1.1),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                'Register, get verified, and reach customers who walk within 100 meters of your door.',
                style: AppTypography.bodyText.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
              ),
              const SizedBox(height: AppSpace.xl),
              const _Benefit(icon: Icons.verified_rounded, text: 'Verified business profile'),
              const _Benefit(icon: Icons.campaign_rounded, text: 'Simple digital promotions'),
              const _Benefit(icon: Icons.radar_rounded, text: 'Location-based reach, 100 m'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onStart, child: const Text('Create my account')),
              ),
              const SizedBox(height: AppSpace.sm),
              Center(
                child: TextButton(
                  onPressed: onDemo,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Explore with demo data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 22),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(text, style: AppTypography.bodyText.copyWith(color: Colors.white))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared step chrome
// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.vm});
  final OnboardingViewModel vm;

  static const _titles = {
    OnboardingStep.personal: ('Create your account', 'Tell us who you are.'),
    OnboardingStep.business: ('About your business', 'This is what customers will see.'),
    OnboardingStep.documents: ('Verify your business', 'Upload a clear photo of each document.'),
    OnboardingStep.verification: ('Verification', 'We check your documents before you go live.'),
    OnboardingStep.location: ('Set your location', 'Place the pin on your business.'),
  };

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _titles[vm.step] ?? ('', '');
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.sm, AppSpace.lg, AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: vm.back,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.deepTeal),
              ),
              Expanded(
                child: Semantics(
                  label: 'Step ${vm.stepNumber} of ${OnboardingViewModel.totalSteps}',
                  child: Row(
                    children: [
                      for (var i = 1; i <= OnboardingViewModel.totalSteps; i++)
                        Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i <= vm.stepNumber ? AppColors.coral : AppColors.hairline,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Text('${vm.stepNumber}/${OnboardingViewModel.totalSteps}', style: AppTypography.label),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpace.md, top: AppSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.display),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable body with a pinned bottom action area.
class _StepLayout extends StatelessWidget {
  const _StepLayout({required this.children, required this.bottom});

  final List<Widget> children;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.xl),
            children: children,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.md, AppSpace.xl, AppSpace.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: SizedBox(width: double.infinity, child: bottom),
        ),
      ],
    );
  }
}

Widget _gap([double h = AppSpace.lg]) => SizedBox(height: h);

// ---------------------------------------------------------------------------
// Step 1 — personal registration (§2.1)
// ---------------------------------------------------------------------------

class _PersonalStep extends StatefulWidget {
  const _PersonalStep({required this.vm, required this.formKey});
  final OnboardingViewModel vm;
  final GlobalKey<FormState> formKey;

  @override
  State<_PersonalStep> createState() => _PersonalStepState();
}

class _PersonalStepState extends State<_PersonalStep> {
  bool _hidden = true;
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return _StepLayout(
      bottom: FilledButton(
        onPressed: () {
          if (widget.formKey.currentState!.validate()) vm.next();
        },
        child: const Text('Continue'),
      ),
      children: [
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: vm.fullName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(labelText: 'Full name'),
                onChanged: (v) => vm.fullName = v,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter your full name' : null,
              ),
              _gap(),
              TextFormField(
                initialValue: vm.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => vm.email = v,
                validator: (v) {
                  final email = (v ?? '').trim();
                  if (email.isEmpty && vm.mobile.trim().isEmpty) {
                    return 'Enter an email or a mobile number';
                  }
                  if (email.isNotEmpty && !_emailRe.hasMatch(email)) return 'Enter a valid email';
                  return null;
                },
              ),
              _gap(),
              TextFormField(
                initialValue: vm.mobile,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: const InputDecoration(labelText: 'Mobile number', hintText: '0917 000 0000'),
                onChanged: (v) => vm.mobile = v,
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.isNotEmpty && digits.length < 10) return 'Enter a valid mobile number';
                  return null;
                },
              ),
              _gap(),
              TextFormField(
                initialValue: vm.password,
                obscureText: _hidden,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 8 characters',
                  suffixIcon: IconButton(
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                    icon: Icon(_hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  ),
                ),
                onChanged: (v) => vm.password = v,
                validator: (v) => (v ?? '').length < 8 ? 'Use at least 8 characters' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — business information (§3)
// ---------------------------------------------------------------------------

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({required this.vm, required this.formKey});
  final OnboardingViewModel vm;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    String? required(String? v, String msg) => (v ?? '').trim().isEmpty ? msg : null;
    return _StepLayout(
      bottom: FilledButton(
        onPressed: () {
          if (formKey.currentState!.validate()) vm.next();
        },
        child: const Text('Continue'),
      ),
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: vm.businessName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Business name'),
                onChanged: (v) => vm.businessName = v,
                validator: (v) => required(v, 'Enter your business name'),
              ),
              _gap(AppSpace.xl),
              Text('What kind of business is it?', style: AppTypography.section),
              const SizedBox(height: AppSpace.sm),
              FormField<MsmeCategory>(
                initialValue: vm.category,
                validator: (v) => v == null ? 'Choose a category' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: [
                        for (final c in MsmeCategory.values)
                          ChoiceChip(
                            avatar: Icon(c.icon, size: 18,
                                color: field.value == c ? Colors.white : AppColors.tealInk),
                            label: Text(c.label),
                            selected: field.value == c,
                            showCheckmark: false,
                            selectedColor: AppColors.deepTeal,
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.hairline),
                            labelStyle: AppTypography.label.copyWith(
                              color: field.value == c ? Colors.white : AppColors.ink,
                            ),
                            onSelected: (_) {
                              vm.category = c;
                              field.didChange(c);
                            },
                          ),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(field.errorText!,
                            style: AppTypography.label.copyWith(color: AppColors.danger)),
                      ),
                  ],
                ),
              ),
              _gap(AppSpace.xl),
              TextFormField(
                initialValue: vm.description,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Short description',
                  alignLabelWithHint: true,
                  hintText: 'What do you sell or offer?',
                ),
                onChanged: (v) => vm.description = v,
                validator: (v) => required(v, 'Describe your business'),
              ),
              _gap(AppSpace.xl),
              DropdownButtonFormField<String>(
                initialValue: vm.municipality,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Municipality'),
                items: [for (final m in antiqueMunicipalities) DropdownMenuItem(value: m, child: Text(m))],
                onChanged: (v) => vm.municipality = v,
                validator: (v) => v == null ? 'Choose a municipality' : null,
              ),
              _gap(),
              TextFormField(
                initialValue: vm.barangay,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Barangay'),
                onChanged: (v) => vm.barangay = v,
                validator: (v) => required(v, 'Enter your barangay'),
              ),
              _gap(),
              TextFormField(
                initialValue: vm.address,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Street / address'),
                onChanged: (v) => vm.address = v,
                validator: (v) => required(v, 'Enter your address'),
              ),
              _gap(),
              TextFormField(
                initialValue: vm.contactNumber,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Business contact number'),
                onChanged: (v) => vm.contactNumber = v,
                validator: (v) => required(v, 'Enter a contact number'),
              ),
              _gap(),
              TextFormField(
                initialValue: vm.operatingHours,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Operating hours',
                  hintText: 'Mon–Sat, 8:00 AM – 6:00 PM',
                ),
                onChanged: (v) => vm.operatingHours = v,
                validator: (v) => required(v, 'Enter your operating hours'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — verification documents (§4)
// ---------------------------------------------------------------------------

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({required this.vm});
  final OnboardingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!vm.allDocumentsUploaded)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: Text('${vm.documentsUploaded} of ${DocumentType.values.length} documents uploaded',
                  style: AppTypography.bodyMuted),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: vm.allDocumentsUploaded ? vm.submitDocuments : null,
              child: const Text('Submit for verification'),
            ),
          ),
        ],
      ),
      children: [
        for (final type in DocumentType.values) ...[
          _DocumentCard(
            type: type,
            path: vm.documentPath(type),
            onPick: () async {
              final p = await pickPhoto(context, title: type.label);
              if (p != null) vm.setDocument(type, p);
            },
            onRemove: () => vm.removeDocument(type),
          ),
          _gap(AppSpace.md),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.inkMuted),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text('Your documents are only used to verify your business.',
                  style: AppTypography.bodyMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.type, required this.path, required this.onPick, required this.onRemove});

  final DocumentType type;
  final String? path;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final uploaded = path != null;
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: uploaded
                  ? AppImage(path!, semanticLabel: '${type.label} preview')
                  : const ColoredBox(
                      color: AppColors.tealTint,
                      child: Icon(Icons.description_outlined, color: AppColors.tealInk, size: 30),
                    ),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: AppTypography.section.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(uploaded ? 'Uploaded' : type.description,
                    style: AppTypography.bodyMuted.copyWith(
                      fontSize: 13,
                      color: uploaded ? AppColors.tealInk : AppColors.inkMuted,
                    )),
              ],
            ),
          ),
          if (uploaded) ...[
            IconButton(
              tooltip: 'Replace ${type.label}',
              onPressed: onPick,
              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.tealInk),
            ),
            IconButton(
              tooltip: 'Remove ${type.label}',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: AppColors.inkMuted),
            ),
          ] else
            OutlinedButton(
              onPressed: onPick,
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
              child: const Text('Upload'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 — verification status (§4)
// ---------------------------------------------------------------------------

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({required this.vm});
  final OnboardingViewModel vm;

  @override
  Widget build(BuildContext context) {
    final status = vm.verification;
    final (message, icon) = switch (status) {
      VerificationStatus.verified => (
          'Your business is verified. One last step: confirm where it is.',
          Icons.verified_rounded
        ),
      VerificationStatus.requiresCorrection => (
          'Some documents are unclear or incomplete. Update them and submit again.',
          Icons.error_outline_rounded
        ),
      VerificationStatus.rejected => (
          'We could not approve this application. Check your documents and try again.',
          Icons.block_rounded
        ),
      _ => ('We are reviewing your documents. This can take a little while.', Icons.hourglass_top_rounded),
    };

    final Widget action;
    if (status.isVerified) {
      action = FilledButton(onPressed: vm.next, child: const Text('Continue to location'));
    } else if (status == VerificationStatus.requiresCorrection || status == VerificationStatus.rejected) {
      action = FilledButton(
        onPressed: () => vm.go(OnboardingStep.documents),
        child: const Text('Update documents'),
      );
    } else {
      action = const FilledButton(onPressed: null, child: Text('Waiting for approval'));
    }

    return _StepLayout(
      bottom: action,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.deepTeal),
                  const SizedBox(width: AppSpace.sm),
                  Text('Status', style: AppTypography.section),
                  const Spacer(),
                  VerificationBadge(status: status),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Text(message, style: AppTypography.bodyText),
              const Divider(height: AppSpace.xl, color: AppColors.hairline),
              for (final t in DocumentType.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.teal),
                      const SizedBox(width: AppSpace.md),
                      Text(t.label, style: AppTypography.bodyText),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _gap(),
        // No review backend yet: the reviewer's decision is simulated here.
        AppCard(
          color: AppColors.warningTint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.science_outlined, color: AppColors.warning),
                  const SizedBox(width: AppSpace.sm),
                  Text('Demo reviewer', style: AppTypography.section.copyWith(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 4),
              Text('There is no review team connected yet. Choose a decision to continue the demo.',
                  style: AppTypography.bodyMuted.copyWith(color: AppColors.ink)),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(48, 40), backgroundColor: AppColors.deepTeal),
                    onPressed: () => vm.simulateReview(VerificationStatus.verified),
                    child: const Text('Approve'),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
                    onPressed: () => vm.simulateReview(VerificationStatus.requiresCorrection),
                    child: const Text('Needs correction'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 5 — location & 100 m geofence (§5)
// ---------------------------------------------------------------------------

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.vm, required this.onConfirm});
  final OnboardingViewModel vm;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GeofenceMap(
            center: vm.pin,
            onCenterChanged: vm.movePin,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.lg, AppSpace.xl, AppSpace.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.coralTint, shape: BoxShape.circle),
                    child: const Icon(Icons.radar_rounded, color: AppColors.coralInk),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${BusinessLocation.geofenceRadiusMeters.round()}-meter coverage',
                            style: AppTypography.section),
                        Text('Drag the map to move the pin. The coverage area is fixed.',
                            style: AppTypography.bodyMuted.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              _gap(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onConfirm, child: const Text('Confirm location')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
