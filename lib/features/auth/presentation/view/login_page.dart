import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that allows users to log in to their account.
@RoutePage()
class LoginPage extends StatefulWidget {
  /// Creates a [LoginPage] widget.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'login_form');
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginFailure) {
          final message = state.failure.toMessage();
          ScaffoldMessengerHelper.showError(
            context: context,
            title: message.title,
            subtitle: message.description,
          );
        }
        if (state is LoginSuccess) {
          ScaffoldMessengerHelper.showMessage(
            context: context,
            title: t.common.success,
            subtitle: t.auth.login.successMessage,
          );
          await context.router.replaceAll([const HomeShellRoute()]);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    children: [
                      SaText(
                        t.auth.login.title,
                        style: AppTextStyle.h4,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      SaText(
                        t.auth.login.subtitle,
                        style: AppTextStyle.titleS,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SaFormTextField(
                        formKeyName: 'identifier',
                        textInputAction: TextInputAction.next,
                        prefixIcon: const SaIcon(
                          icon: SaIconSource.huge(HugeIconsStrokeRounded.user),
                        ),
                        labelText: t.auth.common.identifier,
                        validator: FormValidator.identifier(),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      SaFormTextField(
                        formKeyName: 'password',
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        labelText: t.auth.common.password,
                        prefixIcon: const SaIcon(
                          icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
                        ),
                        isPassword: true,
                        validator: FormValidator.password(),
                        onSubmitted: (_) => _onLoginPressed(),
                        errorMaxLines: 2,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SaTextButton(
                          onPressed: _onForgotPasswordPressed,
                          child: SaText(t.auth.login.forgotPasswordButton),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      BlocBuilder<LoginCubit, LoginState>(
                        builder: (_, state) {
                          final isLoading = state is LoginLoading;

                          return SaPrimaryButton.icon(
                            onPressed: _onLoginPressed,
                            isLoading: isLoading,
                            iconAlignment: SaIconAlignment.end,
                            label: SaText(t.auth.login.loginButton),
                            icon: const SaIcon(
                              icon: SaIconSource.huge(HugeIconsStrokeRounded.login02),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SaText(t.auth.login.noAccount),
                          SaTextButton(
                            onPressed: _onSignUpPressed,
                            child: SaText(t.auth.signUp.signUpButton),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final identifier = formData['identifier'] as String;
      final password = formData['password'] as String;

      await context.read<LoginCubit>().login(
        identifier: identifier,
        password: password,
      );
    }
  }

  Future<void> _onForgotPasswordPressed() async {
    await context.router.push(const PasswordResetRoute());
  }

  Future<void> _onSignUpPressed() async {
    await context.router.push(const SignUpRoute());
  }
}
