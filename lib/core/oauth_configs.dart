import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_client.dart';

import 'core.dart';

final redirectUri = AppTheme.isMobile
    ? 'com.shinga.app:/callback'
    : 'http://localhost:8080/callback';
final customUriScheme = AppTheme.isMobile ? 'com.shinga.app' : 'http://localhost:8080';

// --- Google OAuth2 Configuration ---
final googleOAuthConfig = GoogleOAuth2Client(
  redirectUri: redirectUri,
  customUriScheme: customUriScheme,
);
final googleClientId = AppTheme.isMobile
    ? const String.fromEnvironment('GOOGLE_CLIENT_ANDROID_ID')
    : const String.fromEnvironment('GOOGLE_CLIENT_WINDOWS_ID');
const googleClientSecret = String.fromEnvironment('GOOGLE_CLIENT_WINDOWS_SECRET');
final kGoogleScopes = ['openid', 'email', 'profile'];

// --- Yandex OAuth2 Configuration ---
final yandexOAuthConfig = OAuth2Client(
  authorizeUrl: 'https://oauth.yandex.ru/authorize',
  tokenUrl: 'https://oauth.yandex.ru/token',
  redirectUri: redirectUri,
  customUriScheme: customUriScheme,
);
const yandexClientId = String.fromEnvironment('YANDEX_CLIENT_ID');
final kYandexScopes = ['login:email', 'login:info'];
