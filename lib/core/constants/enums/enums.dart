enum Language {
  English('en'),
  Russian('ru');

  const Language(this.languageCode);

  final String languageCode;
}

enum OAuthProvider { Google, Yandex }
