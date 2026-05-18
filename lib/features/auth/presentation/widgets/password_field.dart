import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// A password text field with visibility toggle.
/// Optionally shows a password strength indicator bar.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggleVisibility,
    this.hint,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.errorText,
    this.autofillHints,
    this.showStrengthIndicator = false,
    this.strengthScore = 0,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final String? hint;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final Iterable<String>? autofillHints;
  final bool showStrengthIndicator;
  final int strengthScore; // 0–4
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isVisible,
          textInputAction: textInputAction ?? TextInputAction.next,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          autofillHints: autofillHints,
          enabled: enabled,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: AuthTheme.fieldDecoration(
            context: context,
            label: label,
            hint: hint,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggleVisibility,
              splashRadius: 20,
            ),
            errorText: errorText,
          ),
        ),
        if (showStrengthIndicator && controller.text.isNotEmpty) ...[
          const SizedBox(height: AuthTheme.spacingSm),
          _PasswordStrengthBar(score: strengthScore),
        ],
      ],
    );
  }
}

/// Visual password strength bar. Score ranges 0–4.
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.score});

  final int score;

  static const _labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
  static const _colors = [
    Colors.transparent,
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0, 4);
    final color = _colors[clampedScore];
    final label = _labels[clampedScore];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < clampedScore;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled
                        ? color
                        : Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AuthTheme.spacingSm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
