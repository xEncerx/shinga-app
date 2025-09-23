import 'dart:async';
import '../../data/data.dart';

/// A service for updating titles and notifying listeners about changes.
class TitleUpdateService {
  factory TitleUpdateService() => _instance;
  TitleUpdateService._internal();
  static final TitleUpdateService _instance = TitleUpdateService._internal();

  final StreamController<TitleWithUserData> _titleUpdateController =
      StreamController<TitleWithUserData>.broadcast();

  Stream<TitleWithUserData> get titleUpdates => _titleUpdateController.stream;

  void updateTitle(TitleWithUserData updatedTitle) {
    _titleUpdateController.add(updatedTitle);
  }

  void dispose() {
    _titleUpdateController.close();
  }
}
