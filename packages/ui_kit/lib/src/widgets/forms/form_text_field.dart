import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ui_kit/ui_kit.dart';

/// Default value transformer that trims leading and trailing whitespace from the input value.
String? trimTransformer(String? value) => value?.trim();

/// A form-integrated text field widget that wraps [SaTextField] with [FormBuilderField].
///
/// Connects [SaTextField] to a `flutter_form_builder` form.
class SaFormTextField extends StatefulWidget {
  /// Creates a [SaFormTextField] widget.
  const SaFormTextField({
    required this.formKeyName,
    super.key,

    // Form params
    this.initialValue,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.valueTransformer = trimTransformer,
    this.onSaved,

    // Reuse SaTextField params
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.style,
    this.border,
    this.textAlign = TextAlign.start,
    this.decoration,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.filled,
    this.fillColor,
    this.constraints,
    this.contentPadding,
    this.mouseCursor,
    this.readOnly = false,
    this.enabled,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorMaxLines,
    this.maxLengthEnforcement,
    this.expands = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,

    // Password
    this.isPassword = false,
    this.passwordVisible,
    this.onPasswordVisibilityChanged,
    this.passwordToggleIconBuilder,
  });

  /// The unique key name used to identify this field within the form.
  final String formKeyName;

  /// The initial value of the text field.
  final String? initialValue;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final FormFieldValidator<String>? validator;

  /// Used to configure the auto validation of [FormBuilderField].
  final AutovalidateMode autovalidateMode;

  /// Transforms the field value before saving it to the form.
  final ValueTransformer<String?>? valueTransformer;

  /// Called when the field is saved via the form.
  final FormFieldSetter<String>? onSaved;

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

  /// Optional input validation and formatting.
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

  /// Optional constraints for the text field's decoration, such as (max/min) width or height.
  final BoxConstraints? constraints;

  /// Optional content padding for the text field's decoration.
  final EdgeInsetsGeometry? contentPadding;

  /// The cursor to display when hovering over the text field.
  final MouseCursor? mouseCursor;

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

  /// The maximum number of lines to use for the error text when errorText is not null.
  final int? errorMaxLines;

  /// Determines how the [maxLength] limit should be enforced.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Whether this widget's height will be sized to fill its parent.
  final bool expands;

  /// Called when the user changes the text.
  final void Function(String)? onChanged;

  /// Called when the user submits the text.
  final void Function(String)? onSubmitted;

  /// Called when the user taps on the text field.
  final void Function()? onTap;

  /// Called when the user finishes editing.
  final void Function()? onEditingComplete;

  /// Whether this text field is a password field.
  ///
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

  @override
  State<SaFormTextField> createState() => _SaFormTextFieldState();
}

class _SaFormTextFieldState extends State<SaFormTextField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  bool _syncingFromField = false;

  @override
  void initState() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    super.initState();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: widget.formKeyName,
      enabled: widget.enabled ?? true,
      initialValue: _controller.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      valueTransformer: widget.valueTransformer,
      onSaved: widget.onSaved,
      builder: (field) {
        final fieldValue = field.value ?? '';
        if (!_syncingFromField && fieldValue != _controller.text) {
          _syncingFromField = true;
          _controller.value = _controller.value.copyWith(
            text: fieldValue,
            selection: TextSelection.collapsed(offset: fieldValue.length),
            composing: TextRange.empty,
          );
          _syncingFromField = false;
        }

        return SaTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          style: widget.style,
          textAlign: widget.textAlign,
          decoration: widget.decoration,
          hintText: widget.hintText,
          labelText: widget.labelText,
          errorText: field.errorText,
          mouseCursor: widget.mouseCursor,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          filled: widget.filled,
          fillColor: widget.fillColor,
          border: widget.border,
          constraints: widget.constraints,
          contentPadding: widget.contentPadding,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          obscuringCharacter: widget.obscuringCharacter,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          errorMaxLines: widget.errorMaxLines,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          expands: widget.expands,

          isPassword: widget.isPassword,
          passwordVisible: widget.passwordVisible,
          onPasswordVisibilityChanged: widget.onPasswordVisibilityChanged,
          passwordToggleIconBuilder: widget.passwordToggleIconBuilder,

          onChanged: (v) {
            if (!_syncingFromField) field.didChange(v);
            widget.onChanged?.call(v);
          },
          onSubmitted: (v) {
            field.save();
            widget.onSubmitted?.call(v);
          },
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
        );
      },
    );
  }
}
