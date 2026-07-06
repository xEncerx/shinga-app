import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A field widget for selecting chapters range in the title filter.
class TitleFilterChaptersRangeField extends StatefulWidget {
  /// Creates a [TitleFilterChaptersRangeField] widget.
  const TitleFilterChaptersRangeField({super.key});

  @override
  State<TitleFilterChaptersRangeField> createState() => _TitleFilterChaptersRangeFieldState();
}

class _TitleFilterChaptersRangeFieldState extends State<TitleFilterChaptersRangeField> {
  final _formState = GlobalKey<FormBuilderState>();
  final _minFocusNode = FocusNode();
  final _maxFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _minFocusNode.addListener(() {
      if (!_minFocusNode.hasFocus) {
        _onChanged();
      }
    });
    _maxFocusNode.addListener(() {
      if (!_maxFocusNode.hasFocus) {
        _onChanged();
      }
    });
  }

  @override
  void dispose() {
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return BlocConsumer<TitleFilterCubit, TitleFilterState>(
      listenWhen: (prev, curr) {
        final prevMin = prev is TitleFilterLoaded ? prev.draft.minChapters : null;
        final prevMax = prev is TitleFilterLoaded ? prev.draft.maxChapters : null;
        final currMin = curr is TitleFilterLoaded ? curr.draft.minChapters : null;
        final currMax = curr is TitleFilterLoaded ? curr.draft.maxChapters : null;
        return prevMin != currMin || prevMax != currMax;
      },
      listener: (_, state) {
        final minChapters = state is TitleFilterLoaded ? state.draft.minChapters : null;
        final maxChapters = state is TitleFilterLoaded ? state.draft.maxChapters : null;
        if (!_minFocusNode.hasFocus) {
          _formState.currentState?.fields['minChapters']?.didChange(minChapters?.toString() ?? '');
        }
        if (!_maxFocusNode.hasFocus) {
          _formState.currentState?.fields['maxChapters']?.didChange(maxChapters?.toString() ?? '');
        }
      },
      buildWhen: (_, _) => false,
      builder: (_, state) {
        final chapters = state is TitleFilterLoaded
            ? (state.draft.minChapters, state.draft.maxChapters)
            : (null, null);
        return FormBuilder(
          key: _formState,
          child: Row(
            spacing: AppSpacing.s,
            children: [
              Flexible(
                child: SaFormTextField(
                  formKeyName: 'minChapters',
                  initialValue: chapters.$1?.toString(),
                  focusNode: _minFocusNode,
                  hintText: t.titles.common.from,
                  keyboardType: TextInputType.number,
                  validator: _validateRange,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              SaText('—', style: AppTextStyle.title),
              Flexible(
                child: SaFormTextField(
                  formKeyName: 'maxChapters',
                  initialValue: chapters.$2?.toString(),
                  focusNode: _maxFocusNode,
                  hintText: t.titles.common.to,
                  keyboardType: TextInputType.number,
                  validator: _validateRange,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateRange(String? value) {
    final state = _formState.currentState;
    if (state == null) return null;
    final min = int.tryParse(
      state.fields['minChapters']?.value as String? ?? '',
    );
    final max = int.tryParse(
      state.fields['maxChapters']?.value as String? ?? '',
    );
    if (min != null && max != null && min > max) {
      return '${t.titles.common.from} > ${t.titles.common.to}';
    }
    return null;
  }

  void _onChanged() {
    if (_formState.currentState?.saveAndValidate() ?? false) {
      final values = _formState.currentState!.value;
      context.read<TitleFilterCubit>().setChaptersRange(
        int.tryParse((values['minChapters'] as String?) ?? ''),
        int.tryParse((values['maxChapters'] as String?) ?? ''),
      );
    }
  }
}
