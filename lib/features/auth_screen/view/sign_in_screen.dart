import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

/// Screen for user sign-in.
@RoutePage()
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Center(
      child: FormBuilder(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Text(
              t.auth.signIn.title,
              style: theme.textTheme.titleLarge.semiBold,
            ),
            Text(
              t.auth.signIn.subtitle,
              style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              name: 'username',
              label: t.auth.common.usernameOrEmail,
              validator: TextFieldFilterService.username(validateEmail: true),
            ),
            const SizedBox(height: 10),
            AuthTextField(
              name: 'password',
              label: t.auth.common.password,
              isPassword: true,
              validator: TextFieldFilterService.password(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.router.navigatePath('reset-password'),
                child: Text(
                  t.auth.signIn.forgotPassword,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AuthActionButton(
              text: t.auth.signIn.title,
              onPressed: _onSignInButtonPressed,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(t.auth.signIn.noAccount),
                TextButton(
                  onPressed: () => context.router.navigatePath('sign-up'),
                  child: Text(t.auth.signUp.title),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                const Expanded(child: Divider()),
                Flexible(
                  child: Text(
                    t.auth.signIn.loginWith,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _onGoogleOAuthButtonPressed,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(150, 50),
                  ),
                  child: IconWithText(
                    text: 'Google',
                    textColor: theme.colorScheme.onSurface,
                    icon: SvgPicture.asset(
                      'assets/svgs/google_logo.svg',
                      width: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: _onYandexOAuthButtonPressed,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(140, 50),
                  ),
                  child: IconWithText(
                    text: 'Yandex',
                    textColor: theme.colorScheme.onSurface,
                    icon: SvgPicture.asset(
                      'assets/svgs/yandex_logo.svg',
                      width: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.fields;
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          username: fields?['username']?.value as String,
          password: fields?['password']?.value as String,
        ),
      );
    }
  }

  Future<void> _onGoogleOAuthButtonPressed() async {
    final response = await googleOAuthConfig.getTokenWithAuthCodeFlow(
      clientId: googleClientId,
      clientSecret: googleClientSecret,
      scopes: kGoogleScopes,
      webAuthOpts: {'useWebview': false},
    );
    if (mounted) {
      context.read<AuthBloc>().add(
        AuthSignInWithOAuthRequested(
          oAuthResponse: response,
          provider: OAuthProvider.Google,
        ),
      );
    }
  }

  Future<void> _onYandexOAuthButtonPressed() async {
    final response = await yandexOAuthConfig.getTokenWithAuthCodeFlow(
      clientId: yandexClientId,
      scopes: kYandexScopes,
      webAuthOpts: {'useWebview': false},
    );
    if (mounted) {
      context.read<AuthBloc>().add(
        AuthSignInWithOAuthRequested(
          oAuthResponse: response,
          provider: OAuthProvider.Yandex,
        ),
      );
    }
  }
}
