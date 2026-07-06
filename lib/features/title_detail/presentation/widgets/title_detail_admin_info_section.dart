import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget that displays administrative information about a title.
class TitleDetailAdminInfoSection extends StatelessWidget {
  /// Creates a [TitleDetailAdminInfoSection] widget.
  const TitleDetailAdminInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocSelector<SessionBloc, SessionState, UserRole>(
      selector: (state) => state is SessionAuthenticated ? state.session.user.role : UserRole.user,
      builder: (_, role) {
        if (role == UserRole.admin) {
          return BlocBuilder<TitleDetailCubit, TitleDetailState>(
            buildWhen: (previous, current) => previous.data != current.data,
            builder: (_, state) {
              return SaSectionCard.transparent(
                headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.manager)),
                headerLabel: SaText(t.titleDetail.staffSection.title),
                child: Column(
                  children: [
                    SaCopyText(
                      label: SaText(
                        '${t.titleDetail.staffSection.titleId.title} ${state.data.title.id}',
                      ),
                      textToCopy: state.data.title.id.toString(),
                      onCopied: (value) => ScaffoldMessengerHelper.showMessage(
                        context: context,
                        title: t.titleDetail.staffSection.titleId.copiedMessage,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
