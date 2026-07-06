/// An enumeration representing the different statuses of titles available in the system.
enum TitleStatus {
  /// The title is actively being published.
  ongoing,

  /// The title has completed publication.
  finished,

  /// Publication has been permanently stopped.
  discontinued,

  /// Publication is temporarily on hold.
  frozen,

  /// The title has been announced but not yet released.
  anons,

  /// The publication status is not known.
  unknown,
}
