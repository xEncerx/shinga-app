import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that allows users to create a new account.
@RoutePage()
class SignUpPage extends StatefulWidget {
  /// Creates a [SignUpPage] widget.
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'sign_up_form');
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpFailure) {
          final message = state.failure.toMessage();
          ScaffoldMessengerHelper.showError(
            context: context,
            title: message.title,
            subtitle: message.description,
          );
        }
        if (state is SignUpSuccess) {
          ScaffoldMessengerHelper.showMessage(
            context: context,
            title: t.common.success,
            subtitle: t.auth.signUp.successMessage,
          );
          _closePage();
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
                        t.auth.signUp.title,
                        style: AppTextStyle.h4,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      SaText(
                        t.auth.signUp.subtitle,
                        style: AppTextStyle.titleS,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SaFormTextField(
                        formKeyName: 'username',
                        textInputAction: TextInputAction.next,
                        prefixIcon: const SaIcon(
                          icon: SaIconSource.huge(HugeIconsStrokeRounded.user),
                        ),
                        labelText: t.auth.common.username,
                        validator: FormValidator.username(),
                        onSubmitted: (_) => _emailFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      SaFormTextField(
                        formKeyName: 'email',
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const SaIcon(
                          icon: SaIconSource.huge(HugeIconsStrokeRounded.mail01),
                        ),
                        labelText: t.auth.common.email,
                        validator: FormValidator.email(),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      SaFormTextField(
                        formKeyName: 'password',
                        focusNode: _passwordFocusNode,
                        labelText: t.auth.common.password,
                        prefixIcon: const SaIcon(
                          icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
                        ),
                        isPassword: true,
                        validator: FormValidator.password(),
                        errorMaxLines: 2,
                        onSubmitted: (_) => _onSignUpPressed(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BlocBuilder<SignUpCubit, SignUpState>(
                        builder: (_, state) {
                          final isLoading = state is SignUpLoading;

                          return SaPrimaryButton.icon(
                            onPressed: _onSignUpPressed,
                            isLoading: isLoading,
                            iconAlignment: SaIconAlignment.end,
                            label: SaText(t.auth.signUp.signUpButton),
                            icon: const SaIcon(
                              icon: SaIconSource.huge(HugeIconsStrokeRounded.userAdd01),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SaText(t.auth.signUp.alreadyHaveAccount),
                          SaTextButton(
                            onPressed: _closePage,
                            child: SaText(t.auth.login.loginButton),
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

  Future<void> _onSignUpPressed() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final username = formData['username'] as String;
      final email = formData['email'] as String;
      final password = formData['password'] as String;

      await context.read<SignUpCubit>().signUp(
        username: username,
        email: email,
        password: password,
      );
    }
  }

  void _closePage() => context.router.pop();
}
