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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              AuthFormContainer(
                formKey: formKey,
                title: t.auth.signIn.title,
                subtitle: t.auth.signIn.subtitle,
                actionText: t.auth.signIn.title,
                onActionPressed: _onSignInButtonPressed,
                promptText: t.auth.signIn.promptText,
                promptActionText: t.auth.signUp.title,
                onPromptActionPressed: () => context.router.pushPath('sign-up'),
                formFields: [
                  FormBuilderTextField(
                    name: 'username',
                    decoration: InputDecoration(
                      labelText: t.auth.common.username,
                      errorMaxLines: 2,
                    ),
                    validator: TextFieldFilterService.length(3, 20),
                  ),
                  const SizedBox(height: 10),
                  PasswordTextField(title: t.auth.common.password),
                ],
                extraActionButton: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.router.pushPath('reset-password'),
                    child: Text(t.auth.signIn.forgotPassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      style: theme.textTheme.bodyLarge.semiBold,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: AppTheme.isMobile ? null : _onGoogleOAuthButtonPressed,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(150, 45),
                    ),
                    child: IconWithText(
                      text: "Google",
                      textColor: theme.colorScheme.onPrimary,
                      icon: SvgPicture.asset(
                        'assets/svgs/google_logo.svg',
                        width: 30,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _onYandexOAuthButtonPressed,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(150, 45),
                    ),
                    child: IconWithText(
                      text: "Yandex",
                      textColor: theme.colorScheme.onPrimary,
                      icon: SvgPicture.asset(
                        'assets/svgs/yandex_logo.svg',
                        width: 24,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
