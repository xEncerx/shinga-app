const Set<String> _windowsReservedNames = {
  'CON',
  'PRN',
  'AUX',
  'NUL',
  r'CLOCK$',
  r'CONIN$',
  r'CONOUT$',
  'COM1',
  'COM2',
  'COM3',
  'COM4',
  'COM5',
  'COM6',
  'COM7',
  'COM8',
  'COM9',
  'COM¹',
  'COM²',
  'COM³',
  'LPT1',
  'LPT2',
  'LPT3',
  'LPT4',
  'LPT5',
  'LPT6',
  'LPT7',
  'LPT8',
  'LPT9',
  'LPT¹',
  'LPT²',
  'LPT³',
};

/// Whether [value] is a portable package-relative POSIX path.
///
/// Windows device names and characters are rejected so a manifest parsed on
/// one host resolves to the same kind of package entry on every supported OS.
bool isPortablePluginPackagePath(String value) {
  if (value.isEmpty || value.startsWith('/') || value.contains(r'\')) {
    return false;
  }

  return value.split('/').every(_isPortableSegment);
}

bool _isPortableSegment(String segment) {
  if (segment.isEmpty ||
      segment == '.' ||
      segment == '..' ||
      segment.endsWith('.') ||
      segment.endsWith(' ')) {
    return false;
  }

  for (final codeUnit in segment.codeUnits) {
    if (codeUnit <= 0x1F ||
        codeUnit == 0x22 ||
        codeUnit == 0x2A ||
        codeUnit == 0x3A ||
        codeUnit == 0x3C ||
        codeUnit == 0x3E ||
        codeUnit == 0x3F ||
        codeUnit == 0x7C) {
      return false;
    }
  }

  final basename = segment.split('.').first.toUpperCase();
  return !_windowsReservedNames.contains(basename);
}
