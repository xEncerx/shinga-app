/// A generic key-value storage interface.
///
/// All implementations must call [init] before performing any operations.
abstract interface class KeyValueStorage {
  /// Initializes the storage instance.
  Future<void> init();

  /// Returns the value associated with [key], or `null` if not found.
  Future<String?> read(String key);

  /// Returns all stored key-value pairs as a [Map].
  Future<Map<String, String>> readAll();

  /// Returns `true` if the storage contains an entry for [key].
  Future<bool> containsKey(String key);

  /// Writes [value] associated with [key] to the storage.
  Future<void> write(String key, String value);

  /// Deletes the entry associated with [key].
  Future<void> delete(String key);

  /// Removes all entries from the storage.
  Future<void> clear();
}
