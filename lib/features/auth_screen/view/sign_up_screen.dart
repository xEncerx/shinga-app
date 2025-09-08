import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

/// Screen for user sign-up.
@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
              t.auth.signUp.title,
              style: theme.textTheme.titleLarge.semiBold,
            ),
            Text(
              t.auth.signUp.subtitle,
              style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              name: 'username',
              label: t.auth.common.username,
              validator: TextFieldFilterService.username(),
            ),
            const SizedBox(height: 10),
            AuthTextField(
              name: 'email',
              label: t.auth.common.email,
              validator: TextFieldFilterService.email(),
            ),
            const SizedBox(height: 10),
            AuthTextField(
              name: 'password',
              label: t.auth.common.password,
              isPassword: true,
              validator: TextFieldFilterService.password(),
            ),
            const SizedBox(height: 20),
            AuthActionButton(
              text: t.auth.signUp.title,
              onPressed: _onSignUpButtonPressed,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(t.auth.signUp.haveAccount),
                TextButton(
                  onPressed: () => context.router.navigatePath('sign-in'),
                  child: Text(t.auth.signIn.title),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSignUpButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.fields;
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          username: fields?['username']?.value as String,
          email: fields?['email']?.value as String,
          password: fields?['password']?.value as String,
        ),
      );
    }
  }
}
