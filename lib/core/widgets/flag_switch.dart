import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubit/cubit.dart';
import '../../i18n/strings.g.dart';

class FlagSwitch extends StatefulWidget {
  const FlagSwitch({super.key});

  @override
  State<FlagSwitch> createState() => _FlagSwitchState();
}

class _FlagSwitchState extends State<FlagSwitch> {
  late int _currentIndex;
  final List<String> _flags = ['ru', 'en'];

  @override
  void initState() {
    super.initState();
    _currentIndex = t.$meta.locale.languageCode == 'ru' ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<int>.rollingByHeight(
      current: _currentIndex,
      values: List.generate(_flags.length, (i) => i),
      iconOpacity: 0.33,
      style: ToggleStyle(
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
      customIconBuilder: (context, local, global) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: SvgPicture.asset(
          'assets/flags/${_flags[local.index]}.svg',
        ),
      ),
      onChanged: _onChanged,
    );
  }

  void _onChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.read<AppSettingsCubit>().setLanguageCode(
          _flags[index],
        );
  }
}
