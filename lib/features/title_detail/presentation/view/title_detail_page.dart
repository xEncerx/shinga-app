import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// Page that displays detailed information about a title.
@RoutePage()
class TitleDetailPage extends StatelessWidget {
  /// Creates a [TitleDetailPage] widget.
  const TitleDetailPage({required this.titleData, super.key});

  /// The title data to display, including user-specific information.
  final TitleWithUserDataEntity titleData;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TitleDetailCubit(
        initialData: titleData,
        userTitlesRepository: context.deps.userTitlesRepository,
      ),
      child: const _TitleDetailView(),
    );
  }
}

// Отдельный виджет — у него уже есть доступ к BlocProvider выше
class _TitleDetailView extends StatelessWidget {
  const _TitleDetailView();

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return BlocListener<TitleDetailCubit, TitleDetailState>(
      listener: (context, state) {
        if (state.failure != null) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          final message = state.failure!.toMessage();
          ScaffoldMessengerHelper.showError(
            context: context,
            title: message.title,
            subtitle: message.description,
          );
        }
      },
      child: isWide ? const TitleDetailWideLayout() : const TitleDetailNarrowLayout(),
    );
  }
}
