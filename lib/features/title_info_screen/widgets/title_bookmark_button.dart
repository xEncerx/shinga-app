import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class TitleBookmarkButton extends StatelessWidget {
  const TitleBookmarkButton({
    super.key,
    required this.titleData,
  });

  final TitleWithUserData titleData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(50, 50),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => _showChangeBookmarkDialog(context),
      child: Icon(
        BookMarkType.values[titleData.userData?.bookmark.index ?? 0].icon,
        size: 32,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Future<void> _showChangeBookmarkDialog(BuildContext context) async {
    final titleInfoBloc = context.read<TitleInfoBloc>();

    showDialog<BookMarkType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(t.titleInfo.selectBookmark),
          children: BookMarkType.values.map((BookMarkType value) {
            return SimpleDialogOption(
              onPressed: () {
                context.router.pop();
                titleInfoBloc.add(
                  UpdateTitleDataEvent(
                    titleData: titleData,
                    bookmark: value,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value.i18n),
                  if (value == (titleData.userData?.bookmark ?? BookMarkType.notReading))
                    const Icon(Icons.check_rounded),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
