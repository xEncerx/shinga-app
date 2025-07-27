import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';
import '../../features.dart';

@RoutePage()
class TitleInfoScreen extends StatefulWidget {
  const TitleInfoScreen({
    super.key,
    required this.titleData,
  });

  final TitleWithUserData titleData;

  @override
  State<TitleInfoScreen> createState() => _TitleInfoScreenState();
}

class _TitleInfoScreenState extends State<TitleInfoScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.titleData.userData?.currentUrl ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TitleInfoBloc(getIt<RestClient>()),
      child: BlocListener<TitleInfoBloc, TitleInfoState>(
        listener: (context, state) {
          if (state is TitleInfoLoaded) {
            showSnackBar(context, t.titleInfo.success.titleUpdated);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.router.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: TitleInfoPreviewCover(
                      coverUrl: widget.titleData.title.cover.largeUrl?.fullUrl ?? '',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TitleInfoContentBody(
                      titleData: widget.titleData,
                      urlController: _urlController,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
