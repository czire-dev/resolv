import 'package:flutter/material.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';

/// Reusable form fields used by the Create Report screen.
/// All widgets are UI-only — no submission logic.

// ── Category Selector ─────────────────────────────────────────────────────────

/// Grid of tappable category tiles.
class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key, this.onChanged});

  final ValueChanged<ReportCategory?>? onChanged;

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  ReportCategory? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Category', isRequired: true),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: ReportCategory.values.map((cat) {
            final isSelected = _selected == cat;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = isSelected ? null : cat);
                widget.onChanged?.call(isSelected ? null : cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primaryContainer : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.outlineVariant.withOpacity(0.6),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 5),
                    Text(
                      cat.label,
                      style: text.labelSmall?.copyWith(
                        color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Report Text Field ─────────────────────────────────────────────────────────

/// Themed text field consistent with the auth layer's input style.
class ReportTextField extends StatelessWidget {
  const ReportTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.isRequired = false,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          minLines: minLines,
          validator: validator,
          enabled: enabled,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          decoration: _buildDecoration(context),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant.withOpacity(0.5)),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error, width: 1.2),
      ),
    );
  }
}

// ── Image Picker Placeholder ──────────────────────────────────────────────────

/// Tappable image upload zone (UI placeholder only).
class ImagePickerField extends StatefulWidget {
  const ImagePickerField({super.key});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  bool _hasImage = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Photo (Optional)', isRequired: false),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _hasImage = !_hasImage),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            decoration: BoxDecoration(
              color: _hasImage
                  ? colors.primaryContainer.withOpacity(0.4)
                  : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasImage
                    ? colors.primary.withOpacity(0.4)
                    : colors.outlineVariant.withOpacity(0.5),
                width: 1.5,
                // TODO: Use dashed border with a package like dashed_border
              ),
            ),
            child: Center(
              child: _hasImage
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: colors.primary, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          'Photo selected',
                          style: text.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to remove',
                          style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: colors.onSurfaceVariant,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to attach a photo',
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'JPG, PNG up to 5MB',
                          style: text.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared: Field Label ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          label,
          style: text.labelMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 3),
          Text(
            '*',
            style: TextStyle(color: colors.error, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
