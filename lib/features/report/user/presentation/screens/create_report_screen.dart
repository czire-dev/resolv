import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/features/report/user/presentation/controllers/report_controller.dart';
import 'package:resolv/routing/app_route.dart';
import '../widgets/report_form_fields.dart';

/// Screen for composing and submitting a new barangay report.
/// Connected to [ReportController] via Riverpod for state management.
class CreateReportScreen extends ConsumerWidget {
  const CreateReportScreen({super.key, this.onBack, this.onSubmitSuccess});

  final VoidCallback? onBack;
  final VoidCallback? onSubmitSuccess;

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubmitSuccessSheet(
        onDone: () {
          Navigator.of(context).pop(); // close sheet
          onSubmitSuccess?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportController = ref.watch(reportControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colors.shadow.withOpacity(0.08),
        surfaceTintColor: colors.surface,
        leading: _BackButton(onTap: onBack ?? () => context.go(AppRoute.reportList)),
        title: Text('New Report', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: reportController.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info Banner ─────────────────────────────────────────
                _InfoBanner(
                  message:
                      'Provide as much detail as possible to help us resolve your report faster.',
                ),
                const SizedBox(height: 24),

                // ── Report Title ────────────────────────────────────────
                ReportTextField(
                  controller: reportController.titleController,
                  label: 'Report Title',
                  hint: 'e.g. Broken street light on Rizal Ave',
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  onChanged: reportController.onTitleChanged,
                ),
                const SizedBox(height: 20),

                // ── Category ────────────────────────────────────────────
                CategorySelector(
                  selectedCategory: reportController.selectedCategory,
                  onChanged: (cat) => reportController.selectedCategory = cat,
                ),
                const SizedBox(height: 20),

                // ── Description ─────────────────────────────────────────
                ReportTextField(
                  controller: reportController.descriptionController,
                  label: 'Description',
                  hint:
                      'Describe the issue in detail. Include when it started, how severe it is, and who it affects.',
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  isRequired: true,
                  onChanged: reportController.onDescriptionChanged,
                ),
                const SizedBox(height: 20),

                // ── Address ─────────────────────────────────────────────
                ReportTextField(
                  controller: reportController.addressController,
                  label: 'Location / Address',
                  hint: 'e.g. Block 5, Lot 12, Purok 3',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  textInputAction: TextInputAction.done,
                  isRequired: false,
                  onChanged: reportController.onAddressChanged,
                ),
                const SizedBox(height: 20),

                // ── Photo ───────────────────────────────────────────────
                const ImagePickerField(),
                const SizedBox(height: 28),

                // ── Error Banner ────────────────────────────────────────
                if (reportController.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reportController.errorMessage!,
                            style: text.bodySmall?.copyWith(color: colors.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Disclaimer ──────────────────────────────────────────
                _DisclaimerText(),
              ],
            ),
          ),
        ),
      ),

      // ── Submit Button ─────────────────────────────────────────────────────
      bottomNavigationBar: _SubmitBar(
        canSubmit: reportController.canSubmit,
        isLoading: reportController.isSubmitting,
        onSubmit: () async {
          await reportController.onSubmit(ref, context);
          if (reportController.errorMessage == null) {
            _showSuccessSheet(context);
          }
        },
      ),
    );
  }
}

// ── Info Banner ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: text.bodySmall?.copyWith(color: colors.onSecondaryContainer, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disclaimer Text ───────────────────────────────────────────────────────────

class _DisclaimerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Text(
      'By submitting this report, you confirm that the information provided is accurate to the best of your knowledge. False reports may result in penalties.',
      style: text.bodySmall?.copyWith(
        color: colors.onSurfaceVariant.withOpacity(0.6),
        height: 1.5,
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ── Submit Bar ────────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.canSubmit, required this.isLoading, required this.onSubmit});

  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant.withOpacity(0.4), width: 1)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton(
          onPressed: (canSubmit && !isLoading) ? onSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary),
                )
              : Text(
                  'Submit Report',
                  style: text.labelLarge?.copyWith(
                    color: canSubmit ? colors.onPrimary : colors.onPrimary.withOpacity(0.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Success Bottom Sheet ──────────────────────────────────────────────────────

class _SubmitSuccessSheet extends StatelessWidget {
  const _SubmitSuccessSheet({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 36, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text('Report Submitted!', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Your report has been received. We\'ll notify you once the barangay takes action.',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'View My Reports',
                style: text.labelLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outlineVariant, width: 1),
        ),
        child: Icon(Icons.arrow_back_rounded, color: colors.onSurface, size: 20),
      ),
    );
  }
}
