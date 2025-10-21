import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class TitleInfoContentBody extends StatefulWidget {
  const TitleInfoContentBody({
    super.key,
    required this.titleData,
    required this.urlController,
  });

  final TitleWithUserData titleData;
  final TextEditingController urlController;

  @override
  State<TitleInfoContentBody> createState() => _TitleInfoContentBodyState();
}

class _TitleInfoContentBodyState extends State<TitleInfoContentBody> with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimations = List.generate(7, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            (index * 0.1).clamp(0, 1),
            ((index * 0.1) + 0.6).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _fadeAnimations = List.generate(7, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            (index * 0.1).clamp(0, 1),
            ((index * 0.1) + 0.6).clamp(0, 1),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.read<SettingsCubit>().settings;
    final title = widget.titleData.title;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedSection(
          slideAnimation: _slideAnimations[0],
          fadeAnimation: _fadeAnimations[0],
          child: TitleHeadlineText(
            displayName: appSettings.language == AppLocale.ru
                ? title.nameRu ?? '???'
                : title.nameEn ?? '???',
            nameRu: title.nameRu,
            nameEn: title.nameEn,
            altNames: title.altNames,
          ),
        ),
        _AnimatedSection(
          slideAnimation: _slideAnimations[1],
          fadeAnimation: _fadeAnimations[1],
          child: BlocBuilder<TitleInfoBloc, TitleInfoState>(
            builder: (context, state) {
              final stateTitleData = state is TitleInfoLoaded ? state.titleData : widget.titleData;

              return Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TitleReadButton(
                      titleData: stateTitleData,
                      urlController: widget.urlController,
                    ),
                  ),
                  TitleBookmarkButton(
                    titleData: stateTitleData,
                  ),
                ],
              );
            },
          ),
        ),
        _AnimatedSection(
          slideAnimation: _slideAnimations[2],
          fadeAnimation: _fadeAnimations[2],
          child: TitleStatisticSection(
            rating: title.rating,
            views: title.views,
            chapters: title.chapters,
            date: title.date,
          ),
        ),
        if (widget.titleData.userData != null) ...[
          _AnimatedSection(
            slideAnimation: _slideAnimations[3],
            fadeAnimation: _fadeAnimations[3],
            child: BlocBuilder<TitleInfoBloc, TitleInfoState>(
              builder: (context, state) {
                final stateTitleData = state is TitleInfoLoaded
                    ? state.titleData
                    : widget.titleData;

                return TitleSelectableRating(
                  titleData: stateTitleData,
                );
              },
            ),
          ),
        ],
        _AnimatedSection(
          slideAnimation: _slideAnimations[4],
          fadeAnimation: _fadeAnimations[4],
          child: TitleRecommendationsSection(
            titleId: widget.titleData.title.id,
          ),
        ),
        _AnimatedSection(
          slideAnimation: _slideAnimations[5],
          fadeAnimation: _fadeAnimations[5],
          child: TitleInfoSection(
            scoredBy: title.scoredBy,
            status: title.status,
            type: title.type,
            inAppRating: title.inAppRating,
            inAppScoredBy: title.inAppScoredBy,
            updatedAt: title.updatedAt,
            languageCode: appSettings.language.languageCode,
          ),
        ),
        _AnimatedSection(
          slideAnimation: _slideAnimations[6],
          fadeAnimation: _fadeAnimations[6],
          child: TitleGADSection(
            genres: title.genres,
            authors: title.authors,
            description: title.description,
            locale: appSettings.language,
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.child,
  });

  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([slideAnimation, fadeAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
