/// Extension methods for enums.
extension EnumByNameOrDefault<T extends Enum> on List<T> {
  /// Returns the enum value with the given [name], or [defaultValue] if no such value exists.
  T byNameOrDefault(String name, T defaultValue) =>
      firstWhere((e) => e.name == name, orElse: () => defaultValue);
}
