/// A remote filter list subscribed to by the ad blocker.
class AdBlockerFilterSubscription {
  /// Creates an ad blocker filter subscription.
  const AdBlockerFilterSubscription({
    required this.url,
  });

  /// Creates a subscription from its persisted map representation.
  factory AdBlockerFilterSubscription.fromMap(Map<String, String> map) {
    return AdBlockerFilterSubscription(
      url: map['url'] ?? '',
    );
  }

  /// The URL from which the filter list is loaded.
  final String url;

  /// Converts this subscription to its persistable map representation.
  Map<String, String> toMap() {
    return {'url': url};
  }
}
