import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/settings/settings.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

class _FilterField {
  _FilterField({required this.id, this.initialValue = ''});
  final String id;
  final String initialValue;
}

@RoutePage()
class SettingsAdBlockerPage extends StatefulWidget {
  const SettingsAdBlockerPage({super.key});

  @override
  State<SettingsAdBlockerPage> createState() => _SettingsAdBlockerPageState();
}

class _SettingsAdBlockerPageState extends State<SettingsAdBlockerPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<_FilterField> _fields = [];
  int _nextId = 0;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final subs = context.read<AppSettingsCubit>().state.settings.adBlockerFilterSubscriptions;
      for (final sub in subs) {
        _fields.add(_FilterField(id: 'filter_$_nextId', initialValue: sub.url));
        _nextId++;
      }
      _isInitialized = true;
    }
  }

  void _addField() {
    setState(() {
      _fields.add(_FilterField(id: 'filter_$_nextId'));
      _nextId++;
    });
  }

  void _removeField(String id) {
    setState(() {
      _fields.removeWhere((f) => f.id == id);
      _formKey.currentState?.removeInternalFieldValue(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final adBlockerT = Translations.of(context).settings.reader.adBlocker;
    final isAdBlockerEnabled = context.select(
      /// Type need here to set the correct state of the cubit.
      // ignore: avoid_types_on_closure_parameters
      (AppSettingsCubit cubit) => cubit.state.settings.isAdBlockerEnabled,
    );
    final adBlocker = context.deps.adBlocker;

    return Scaffold(
      appBar: AppBar(
        title: SaText(adBlockerT.title),
        leading: const SaBackButton(),
      ),
      body: StreamListener(
        stream: context.deps.webViewObserver.errors,
        onData: (context, error) {
          final message = ExceptionMapper.fromWebViewError(error).toMessage();
          ScaffoldMessengerHelper.showError(
            context: context,
            title: message.title,
            subtitle: message.description,
          );
        },
        child: SafeArea(
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SaSwitchListTile(
                    value: isAdBlockerEnabled,
                    title: SaText(isAdBlockerEnabled ? adBlockerT.disable : adBlockerT.enable),
                    subtitle: isAdBlockerEnabled
                        ? StreamBuilder(
                            stream: adBlocker.ruleCountStream,
                            builder: (_, snapshot) => SaText(
                              '${adBlockerT.filters}: ${_fields.length} | ${adBlockerT.rules}: ${snapshot.data ?? adBlocker.ruleCount}',
                            ),
                          )
                        : null,
                    onChanged: (value) =>
                        context.read<AppSettingsCubit>().changeAdBlockerStatus(value),
                  ),
                  SaAnimatedClipRect(
                    open: isAdBlockerEnabled,
                    alignment: Alignment.topCenter,
                    child: Column(
                      spacing: AppSpacing.s,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SaListTile(
                          title: SaText(adBlockerT.filterSubscriptions),
                          tileColor: Colors.transparent,
                          trailing: SaIconButton(
                            icon: const SaIcon(
                              icon: SaIconSource.huge(HugeIconsStrokeRounded.add01),
                            ),
                            onPressed: _addField,
                          ),
                        ),
                        for (final field in _fields)
                          Row(
                            spacing: AppSpacing.s,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SaFormTextField(
                                  formKeyName: field.id,
                                  initialValue: field.initialValue,
                                  hintText: 'https://example.com/filter.txt',
                                  validator: FormValidator.url(),
                                ),
                              ),
                              SaIconButton(
                                icon: SaIcon(
                                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.delete01),
                                  color: colorScheme.error,
                                ),
                                onPressed: () => _removeField(field.id),
                              ),
                            ],
                          ),
                        const SaDivider(),
                        ValueListenableBuilder<bool>(
                          valueListenable: adBlocker.isReady,
                          builder: (_, isReady, _) => SaPrimaryButton(
                            onPressed: _onSave,
                            isLoading: !isReady,
                            child: SaText(adBlockerT.saveFilters.title),
                          ),
                        ),
                        SaOpacityButton(
                          onPressed: _onClearCache,
                          backgroundColor: colorScheme.error,
                          child: SaText(adBlockerT.clearCache.title),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final newSubs = <AdBlockerFilterSubscription>[];

      for (final field in _fields) {
        final url = values[field.id] as String?;
        if (url != null && url.trim().isNotEmpty) {
          newSubs.add(AdBlockerFilterSubscription(url: url.trim()));
        }
      }

      await context.read<AppSettingsCubit>().changeAdBlockerFilterSubscriptions(newSubs);
    }
  }

  Future<void> _onClearCache() async {
    final t = Translations.of(context);
    final adBlockerT = t.settings.reader.adBlocker;

    await showDialog<void>(
      context: context,
      builder: (context) => SaConfirmationDialog(
        title: adBlockerT.clearCache.title,
        description: adBlockerT.clearCache.description,
        confirmText: t.common.yes,
        cancelText: t.common.no,
        onConfirm: () async {
          final adBlocker = context.deps.adBlocker;
          if (adBlocker.isReady.value) {
            await adBlocker.clearCache();
            if (!context.mounted) return;
            ScaffoldMessengerHelper.showMessage(
              context: context,
              title: adBlockerT.clearCache.success,
            );
          }
        },
      ),
    );
  }
}
