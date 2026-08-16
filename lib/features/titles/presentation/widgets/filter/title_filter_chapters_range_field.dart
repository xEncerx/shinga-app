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
  static const int _maximumChapters = 10000;
  static final TextInputFormatter _maximumChaptersFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      final chapters = int.tryParse(newValue.text);
      return chapters != null && chapters <= _maximumChapters ? newValue : oldValue;
    },
  );

  final _formState = GlobalKey<FormState>();
  final _minFocusNode = FocusNode();
  final _maxFocusNode = FocusNode();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  bool _isInitialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final state = context.read<TitleFilterCubit>().state;
    if (state is TitleFilterLoaded) {
      _minController.text = state.draft.minChapters?.toString() ?? '';
      _maxController.text = state.draft.maxChapters?.toString() ?? '';
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _minController.dispose();
    _minFocusNode.dispose();
    _maxController.dispose();
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
          _minController.text = minChapters?.toString() ?? '';
        }
        if (!_maxFocusNode.hasFocus) {
          _maxController.text = maxChapters?.toString() ?? '';
        }
      },
      buildWhen: (_, _) => false,
      builder: (_, _) {
        return Form(
          key: _formState,
          child: Row(
            spacing: AppSpacing.s,
            children: [
              Flexible(
                child: SaFormTextField(
                  controller: _minController,
                  focusNode: _minFocusNode,
                  labelText: t.titles.common.from,
                  keyboardType: TextInputType.number,
                  validator: _validateRange,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _maximumChaptersFormatter,
                  ],
                ),
              ),
              SaText('—', style: AppTextStyle.title),
              Flexible(
                child: SaFormTextField(
                  controller: _maxController,
                  focusNode: _maxFocusNode,
                  labelText: t.titles.common.to,
                  keyboardType: TextInputType.number,
                  validator: _validateRange,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _maximumChaptersFormatter,
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
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);
    if ((min != null && min > _maximumChapters) || (max != null && max > _maximumChapters)) {
      return t.titles.filter.chaptersLimitError(max: _maximumChapters);
    }
    if (min != null && max != null && min > max) {
      return '${t.titles.common.from} > ${t.titles.common.to}';
    }
    return null;
  }

  void _onChanged() {
    if (!(_formState.currentState?.validate() ?? false)) return;

    context.read<TitleFilterCubit>().setChaptersRange(
      int.tryParse(_minController.text),
      int.tryParse(_maxController.text),
    );
  }
}
