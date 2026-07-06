import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/auth/auth.dart';

/// A shell widget that listens to [SessionBloc] and redirects to the authentication flow if the session becomes unauthenticated.
class AuthShell extends StatelessWidget {
  /// Creates an [AuthShell] widget.
  const AuthShell({required this.child, super.key});

  /// The child widget to display when the session is authenticated.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (prev, curr) => curr is SessionUnauthenticated && prev is! SessionUnauthenticated,
      listener: (context, state) {
        final router = context.deps.appRouter;
        unawaited(router.replaceAll([const AuthRoute()]));
      },
      child: child,
    );
  }
}
