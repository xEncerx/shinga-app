import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_button/group_button.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class MangaSectionButton extends StatefulWidget {
  const MangaSectionButton({
    super.key,
    required this.mangaId,
    required this.controller,
    required this.cubit,
  });

  final String mangaId;
  final GroupButtonController controller;
  final MangaInfoCubit cubit;

  @override
  State<MangaSectionButton> createState() => _MangaSectionButtonState();
}

class _MangaSectionButtonState extends State<MangaSectionButton> {
  late IconData icon;
  late int _originalSectionIndex;

  @override
  void initState() {
    _originalSectionIndex = widget.controller.selectedIndex ?? 0;
    icon = getSectionIcon(
      MangaSection.selectableSections[_originalSectionIndex],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      width: 50,
      child: ElevatedButton(
        onPressed: () => _showSectionAlertDialog(context, theme),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: BlocBuilder<MangaInfoCubit, MangaInfoState>(
          bloc: widget.cubit,
          builder: (context, state) {
            if (state is MangaInfoSectionUpdated) {
              icon = getSectionIcon(state.newSection);
            }
            return Icon(
              icon,
              size: 35,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }

  Future<void> _showSectionAlertDialog(
    BuildContext context,
    ThemeData theme,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        widget.controller.selectIndex(_originalSectionIndex);

        return AlertDialog(
          title: Text(t.titleInfo.changeSection),
          content: GroupButton<MangaSection>(
            controller: widget.controller,
            buttons: MangaSection.selectableSections,
            options: const GroupButtonOptions(runSpacing: 0),
            buttonIndexedBuilder: (selected, index, context) {
              return _RadioTile(
                title: MangaSection.selectableSections[index].name,
                selected: widget.controller.selectedIndex,
                index: index,
                onTap: () {
                  widget.controller.selectIndex(index);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => _close(context),
              child: Text(t.common.cancel),
            ),
            BlocBuilder<MangaInfoCubit, MangaInfoState>(
              bloc: widget.cubit,
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is! MangaInfoLoading ? () => _saveSection(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    t.common.save,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _close(BuildContext context) => Navigator.of(context).pop();

  Future<void> _saveSection(BuildContext context) async {
    _originalSectionIndex = widget.controller.selectedIndex ?? 0;

    final selectedSection = MangaSection.selectableSections[_originalSectionIndex];
    await widget.cubit.updateMangaSection(widget.mangaId, selectedSection);
    if (context.mounted) {
      _close(context);
    }
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.selected,
    required this.onTap,
    required this.index,
    required this.title,
  });

  final String title;
  final int index;
  final int? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title.capitalize),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      leading: Radio<int>(
        groupValue: selected,
        value: index,
        splashRadius: 0,
        onChanged: (val) {
          onTap();
        },
      ),
    );
  }
}
