/// A generic typed-collection storage interface.
///
/// Unlike Key-Value storage, which operates on key-value string pairs,
/// [CollectionStorage] stores typed objects identified by string keys.
///
/// All implementations must call [init] before performing any operations.
abstract interface class CollectionStorage<T> {
  /// Initializes the storage collection.
  ///
  /// [dir] is the directory path where storage files will be kept.
  /// If [dir] is null, uses the default storage location.
  /// Must be called before any other operations.
  Future<void> init([String? dir]);

  /// Returns the object associated with [id], or `null` if not found.
  Future<T?> read(String id);

  /// Returns all stored objects as a [List].
  Future<List<T>> readAll();

  /// Returns `true` if the collection contains an entry for [id].
  Future<bool> containsKey(String id);

  /// Writes [value] associated with [id] to the collection.
  Future<void> write(String id, T value);

  /// Deletes the entry associated with [id].
  Future<void> delete(String id);

  /// Removes all entries from the collection.
  Future<void> clear();

  /// Emits the updated list of all objects whenever the collection changes.
  Stream<List<T>> watch();
}
