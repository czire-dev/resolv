/// Validation utilities for auth forms.
/// These are pure UI-layer validators with no backend dependency.
class AuthValidators {
  AuthValidators._();

  static const int _minPasswordLength = 8;

  // ── Email ────────────────────────────────────────────────────────────────

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  // ── Display Name ─────────────────────────────────────────────────────────────

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    // if (value.length < _minPasswordLength) {
    //   return 'Password must be at least $_minPasswordLength characters.';
    // }
    return null;
  }

  static String? validatePasswordStrength(String? value) {
    // final base = validatePassword(value);
    // if (base != null) return base;
    // final hasUppercase = value!.contains(RegExp(r'[A-Z]'));
    // final hasDigit = value.contains(RegExp(r'[0-9]'));
    // if (!hasUppercase || !hasDigit) {
    //   return 'Use uppercase letters and numbers for a stronger password.';
    // }
    return null;
  }

  // ── Confirm Password ──────────────────────────────────────────────────────

  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // ── Password Strength Score ───────────────────────────────────────────────

  /// Returns 0–4: none, weak, fair, good, strong.
  static int passwordStrengthScore(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score.clamp(0, 4);
  }

  /// Example mappings to implement:
  ///   'user-not-found'       → 'No account found with this email.'
  ///   'wrong-password'       → 'Incorrect password. Please try again.'
  ///   'email-already-in-use' → 'An account already exists with this email.'
  ///   'invalid-email'        → 'The email address is badly formatted.'
  ///   'weak-password'        → 'Password is too weak.'
  ///   'network-request-failed' → 'Check your internet connection.'
  ///   'too-many-requests'    → 'Too many attempts. Please try later.'
  static String mapFirebaseError(String code) {
    print('Mapping Firebase error code: $code');
    switch (code) {
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
