import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

/// A customizable text field widget for the app.
class SaTextField extends StatefulWidget {
  /// Creates a [SaTextField] widget.
  const SaTextField({
    super.key,
    // Controllers
    this.controller,
    this.focusNode,
    // Input configuration
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    // Style
    this.style,
    this.textAlign = TextAlign.start,
    // Decoration (full customization or individual fields)
    this.decoration,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.filled,
    this.fillColor,
    this.border,
    this.constraints,
    this.contentPadding,
    this.mouseCursor,
    // Behavior
    this.readOnly = false,
    this.enabled,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.errorMaxLines,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.expands = false,
    // Callbacks
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    // Password field
    this.isPassword = false,
    this.passwordVisible,
    this.onPasswordVisibilityChanged,
    this.passwordToggleIconBuilder,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Defines the focus for this text field.
  final FocusNode? focusNode;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  final TextCapitalization textCapitalization;

  /// Additional input formatters applied to the underlying text field.
  final List<TextInputFormatter>? inputFormatters;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The decoration to show around the text field.
  /// If provided, this takes precedence over individual decoration fields.
  final InputDecoration? decoration;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// Text that describes the input field.
  final String? labelText;

  /// Text that appears below the field to indicate an error.
  final String? errorText;

  /// An icon that appears before the editable part of the text field.
  final Widget? prefixIcon;

  /// An icon that appears after the editable part of the text field.
  final Widget? suffixIcon;

  /// Whether the decoration is filled with [fillColor].
  final bool? filled;

  /// The color to fill the decoration with, if [filled] is true.
  final Color? fillColor;

  /// The border to display when the text field is not focused and not showing an error.
  final InputBorder? border;

  /// Whether the text field should be read-only.
  final bool readOnly;

  /// Whether the text field is enabled.
  final bool? enabled;

  /// Whether this text field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// Character used for obscuring text if [obscureText] is true.
  final String obscuringCharacter;

  /// Whether to hide the text being edited.
  final bool obscureText;

  /// Whether to enable autocorrection.
  final bool? autocorrect;

  /// Whether to show input suggestions as the user types.
  final bool enableSuggestions;

  /// The maximum number of lines to show at one time, wrapping if necessary.
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// The maximum number of characters to allow in the text field.
  final int? maxLength;

  /// The maximum number of lines to use for the error text when [errorText] is not null.
  final int? errorMaxLines;

  /// Determines how the [maxLength] limit should be enforced.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Optional constraints for the text field's decoration, such as (max/min) width or height.
  final BoxConstraints? constraints;

  /// Optional content padding for the text field's decoration.
  final EdgeInsetsGeometry? contentPadding;

  /// The cursor to display when hovering over the text field.
  final MouseCursor? mouseCursor;

  /// Whether this widget's height will be sized to fill its parent.
  final bool expands;

  /// Whether this text field is a password field.
  /// When true, automatically adds password visibility toggle.
  final bool isPassword;

  /// Controls password visibility externally.
  ///
  /// If null, the widget manages visibility internally.
  /// If provided, [onPasswordVisibilityChanged] should also be provided.
  final bool? passwordVisible;

  /// Called when the password visibility toggle is pressed.
  /// Use this callback to update the external [passwordVisible] state.
  final ValueChanged<bool>? onPasswordVisibilityChanged;

  /// Custom builder for the password toggle icon.
  ///
  /// If null, uses default visibility/visibility_off icons.
  final Widget Function({required bool isVisible, required VoidCallback onToggle})?
  passwordToggleIconBuilder;

  /// Called when the user changes the text.
  final void Function(String)? onChanged;

  /// Called when the user submits the text.
  final void Function(String)? onSubmitted;

  /// Called when the user taps on the text field.
  final void Function()? onTap;

  /// Called when the user finishes editing.
  final void Function()? onEditingComplete;

  @override
  State<SaTextField> createState() => _SaTextFieldState();
}

class _SaTextFieldState extends State<SaTextField> {
  bool _internalPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      style: widget.style,
      textAlign: widget.textAlign,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.isPassword ? !_isPasswordVisible : widget.obscureText,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      expands: widget.expands,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      mouseCursor: widget.mouseCursor,
      // IconConstraints are fixed due to a bug in the hugeicons-flutter library
      // Issue: https://github.com/hugeicons/hugeicons-flutter/issues/30
      // Temporary solution - set a minimum width for icons so they don't expand to the full height of the TextField.
      decoration:
          widget.decoration?.copyWith(
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIconConstraints: const BoxConstraints(minWidth: 40),
          ) ??
          InputDecoration(
            constraints: widget.constraints,
            contentPadding:
                widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            hintText: widget.hintText,
            labelText: widget.labelText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword ? _buildPasswordToggle() : widget.suffixIcon,
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIconConstraints: const BoxConstraints(minWidth: 40),
            border: widget.border,
            filled: widget.filled,
            fillColor: widget.fillColor,
            errorMaxLines: widget.errorMaxLines,
          ),
    );
  }

  /// Determines the current password visibility state, using external control if provided, otherwise internal state.
  bool get _isPasswordVisible {
    return widget.passwordVisible ?? _internalPasswordVisible;
  }

  void _togglePasswordVisibility() {
    if (widget.onPasswordVisibilityChanged != null) {
      widget.onPasswordVisibilityChanged!(!_isPasswordVisible);
    } else {
      setState(() {
        _internalPasswordVisible = !_internalPasswordVisible;
      });
    }
  }

  /// Builds the password visibility toggle widget, using a custom builder if provided, otherwise default icons.
  Widget _buildPasswordToggle() {
    if (widget.passwordToggleIconBuilder != null) {
      return widget.passwordToggleIconBuilder!(
        isVisible: _isPasswordVisible,
        onToggle: _togglePasswordVisibility,
      );
    }

    return SaIconButton(
      icon: SaIcon(
        icon: SaIconSource.huge(
          _isPasswordVisible ? HugeIconsStrokeRounded.viewOff : HugeIconsStrokeRounded.view,
        ),
      ),
      onPressed: _togglePasswordVisibility,
    );
  }
}
