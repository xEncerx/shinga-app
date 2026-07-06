import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

const _avatarFallbackAsset = 'assets/images/404_placeholder.png';

/// Card that displays the current user's identity and profile details.
class ProfileHeaderCard extends StatelessWidget {
  /// Creates a [ProfileHeaderCard] widget.
  const ProfileHeaderCard({required this.user, super.key});

  /// User data displayed by the header.
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colors = context.colors;
    final description = user.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.l,
      children: [
        Row(
          children: [
            _ProfileAvatar(avatarUrl: user.avatarUrl.toAbsoluteUrl()),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  SaText(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h5.copyWith(color: colors.onSurface),
                  ),
                  SaText(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s),
                    child: SaChip(
                      label: user.role.i18n,
                      color: colors.primaryContainer,
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (description == null || description.isEmpty)
          SaText(
            t.profile.header.fallbackDescription,
            style: AppTextStyle.body.copyWith(color: colors.onSurfaceVariant),
          )
        else
          SaReadMoreText(
            description,
            trimMode: TrimMode.line,
            trimLines: 3,
            expandButtonLabel: t.titleDetail.common.readMoreText,
            collapseButtonLabel: t.titleDetail.common.hideText,
            style: AppTextStyle.body.copyWith(color: colors.onSurfaceVariant),
            actionButtonStyle: AppTextStyle.bodyBold.copyWith(color: colors.primary),
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final image = avatarUrl.isEmpty
        ? const SaImageSource.asset(_avatarFallbackAsset)
        : SaImageSource.network(avatarUrl);

    return SizedBox.square(
      dimension: 100,
      child: ClipOval(
        child: SaImage(
          image: image,
          placeholder: (_) => const SaShimmer(),
          errorWidget: (_, _, _) => const SaImage(
            image: SaImageSource.asset(_avatarFallbackAsset),
          ),
        ),
      ),
    );
  }
}
