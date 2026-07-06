class AdBlockerFilterSubscription {
  const AdBlockerFilterSubscription({
    required this.url,
  });

  factory AdBlockerFilterSubscription.fromMap(Map<String, String> map) {
    return AdBlockerFilterSubscription(
      url: map['url'] ?? '',
    );
  }

  final String url;

  Map<String, String> toMap() {
    return {
      'url': url,
    };
  }
}
