// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [FavoriteScreen]
class FavoriteRoute extends PageRouteInfo<void> {
  const FavoriteRoute({List<PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoriteScreen();
    },
  );
}

/// generated route for
/// [MangaInfoScreen]
class MangaInfoRoute extends PageRouteInfo<MangaInfoRouteArgs> {
  MangaInfoRoute({
    Key? key,
    required Manga mangaData,
    List<PageRouteInfo>? children,
  }) : super(
         MangaInfoRoute.name,
         args: MangaInfoRouteArgs(key: key, mangaData: mangaData),
         initialChildren: children,
       );

  static const String name = 'MangaInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MangaInfoRouteArgs>();
      return MangaInfoScreen(key: args.key, mangaData: args.mangaData);
    },
  );
}

class MangaInfoRouteArgs {
  const MangaInfoRouteArgs({this.key, required this.mangaData});

  final Key? key;

  final Manga mangaData;

  @override
  String toString() {
    return 'MangaInfoRouteArgs{key: $key, mangaData: $mangaData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MangaInfoRouteArgs) return false;
    return key == other.key && mangaData == other.mangaData;
  }

  @override
  int get hashCode => key.hashCode ^ mangaData.hashCode;
}

/// generated route for
/// [ReadingWebViewScreen]
class ReadingWebViewRoute extends PageRouteInfo<ReadingWebViewRouteArgs> {
  ReadingWebViewRoute({
    Key? key,
    required Uri initialUrl,
    List<PageRouteInfo>? children,
  }) : super(
         ReadingWebViewRoute.name,
         args: ReadingWebViewRouteArgs(key: key, initialUrl: initialUrl),
         initialChildren: children,
       );

  static const String name = 'ReadingWebViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReadingWebViewRouteArgs>();
      return ReadingWebViewScreen(key: args.key, initialUrl: args.initialUrl);
    },
  );
}

class ReadingWebViewRouteArgs {
  const ReadingWebViewRouteArgs({this.key, required this.initialUrl});

  final Key? key;

  final Uri initialUrl;

  @override
  String toString() {
    return 'ReadingWebViewRouteArgs{key: $key, initialUrl: $initialUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReadingWebViewRouteArgs) return false;
    return key == other.key && initialUrl == other.initialUrl;
  }

  @override
  int get hashCode => key.hashCode ^ initialUrl.hashCode;
}

/// generated route for
/// [SearchingScreen]
class SearchingRoute extends PageRouteInfo<void> {
  const SearchingRoute({List<PageRouteInfo>? children})
    : super(SearchingRoute.name, initialChildren: children);

  static const String name = 'SearchingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchingScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SignInScreen]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInScreen();
    },
  );
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
}
