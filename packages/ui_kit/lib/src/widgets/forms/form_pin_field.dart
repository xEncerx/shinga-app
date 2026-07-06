import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ui_kit/ui_kit.dart';

/// A form-integrated PIN / OTP field that wraps [SaPinField] with [FormBuilderField].
///
/// Connects [SaPinField] to a `flutter_form_builder` form.
class SaFormPinField extends StatefulWidget {
  /// Creates a [SaFormPinField] widget.
  const SaFormPinField({
    required this.formKeyName,
    super.key,

    // Form params
    this.initialValue,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.valueTransformer,
    this.onSaved,
    this.enabled = true,

    // Reuse SaPinField params
    this.controller,
    this.focusNode,
    this.width = 42,
    this.height = 48,
    this.focusedSizeFactor = 1.1,
    this.defaultPinTheme,
    this.focusedPinTheme,
    this.submittedPinTheme,
    this.errorPinTheme,
    this.disabledPinTheme,
    this.textStyle,
    this.length = 6,
    this.spacing,
    this.onCompleted,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.number,
    this.cursorBuilder,
  });

  /// The unique key name used to identify this field within the form.
  final String formKeyName;

  /// The initial value of the PIN field.
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

  /// Whether the field is enabled.
  final bool enabled;

  /// Optional controller to read or manipulate the current PIN value.
  ///
  /// If `null`, an internal controller is created and managed automatically.
  final TextEditingController? controller;

  /// Optional focus node to control keyboard focus programmatically.
  final FocusNode? focusNode;

  /// Width of a single cell in logical pixels. Defaults to `42`.
  final double width;

  /// Height of a single cell in logical pixels. Defaults to `48`.
  final double height;

  /// Uniform scale factor applied to the cell size when it is focused.
  final double focusedSizeFactor;

  /// Visual overrides for the **default** (unfocused, empty) cell state.
  final SaPinCellThemeData? defaultPinTheme;

  /// Visual overrides for the **focused** (active cursor) cell state.
  final SaPinCellThemeData? focusedPinTheme;

  /// Visual overrides for the **submitted** (digit entered) cell state.
  final SaPinCellThemeData? submittedPinTheme;

  /// Visual overrides for the **error** cell state.
  final SaPinCellThemeData? errorPinTheme;

  /// Visual overrides for the **disabled** (non-interactive) cell state.
  final SaPinCellThemeData? disabledPinTheme;

  /// Text style applied to the digit inside each cell.
  final TextStyle? textStyle;

  /// Number of individual PIN cells (digits). Defaults to `6`.
  final int length;

  /// Horizontal gap between adjacent cells in logical pixels.
  final double? spacing;

  /// Called once when the user has entered all [length] digits.
  final ValueChanged<String>? onCompleted;

  /// Called whenever the PIN value changes, including intermediate states.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Additional input formatters applied to the underlying text field.
  final List<TextInputFormatter> inputFormatters;

  /// Keyboard type shown when the field gains focus. Defaults to
  /// [TextInputType.number].
  final TextInputType keyboardType;

  /// Custom widget rendered as the blinking cursor inside the focused cell.
  final Widget? cursorBuilder;

  @override
  State<SaFormPinField> createState() => _SaFormPinFieldState();
}

class _SaFormPinFieldState extends State<SaFormPinField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  bool _syncingFromField = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
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
      enabled: widget.enabled,
      initialValue: _controller.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      valueTransformer: widget.valueTransformer,
      onSaved: widget.onSaved,
      builder: (field) {
        final fieldValue = field.value ?? '';
        if (!_syncingFromField && fieldValue != _controller.text) {
          _syncingFromField = true;
          _controller.text = fieldValue;
          _syncingFromField = false;
        }

        return SaPinField(
          controller: _controller,
          focusNode: widget.focusNode,
          width: widget.width,
          height: widget.height,
          showError: field.hasError,
          enabled: widget.enabled,
          focusedSizeFactor: widget.focusedSizeFactor,
          defaultPinTheme: widget.defaultPinTheme,
          focusedPinTheme: widget.focusedPinTheme,
          submittedPinTheme: widget.submittedPinTheme,
          errorPinTheme: widget.errorPinTheme,
          disabledPinTheme: widget.disabledPinTheme,
          textStyle: widget.textStyle,
          length: widget.length,
          spacing: widget.spacing,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          cursorBuilder: widget.cursorBuilder,
          onChanged: (v) {
            if (!_syncingFromField) field.didChange(v);
            widget.onChanged?.call(v);
          },
          onCompleted: (v) {
            field.save();
            widget.onCompleted?.call(v);
          },
          onSubmitted: (v) {
            field.save();
            widget.onSubmitted?.call(v);
          },
        );
      },
    );
  }
}
