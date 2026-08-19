## 0.3.0

This release focuses on application stability, maintainability, and platform compatibility.

### Added

- Added native support for Windows system proxy settings.

### Changed

- Migrated local persistence and network caching from Hive-based storage to Drift and SQLite.
- Replaced several third-party abstractions with native Flutter or project-owned implementations.
- Updated Flutter, Dart, Android build tooling, and project dependencies.
- Improved dependency lifecycle management, asynchronous cleanup, and application state synchronization.
- Refined adaptive layouts, form behavior, bookmark interactions, and loading animations.

### Removed

- Removed the obsolete storage package and unused dependencies.

### Upgrade notes

- Updating from `0.2.0` requires signing in again. Existing local settings, ad blocker subscriptions, and search history are not migrated automatically.

## 0.2.0

Initial release.
