final RegExp _windowsDrivePattern = RegExp('^[A-Za-z]:');

/// Whether [value] is a portable package-relative POSIX path.
bool isSafePackagePath(String value) {
  if (value.isEmpty ||
      value.startsWith('/') ||
      value.startsWith(r'\') ||
      value.contains(r'\') ||
      value.contains(':') ||
      value.contains('\u0000') ||
      _windowsDrivePattern.hasMatch(value)) {
    return false;
  }

  return value
      .split('/')
      .every((segment) => segment.isNotEmpty && segment != '.' && segment != '..');
}
