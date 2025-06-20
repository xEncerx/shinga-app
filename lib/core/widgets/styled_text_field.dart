import 'package:flutter/material.dart';

/// A custom text field.
///
/// This widget extends TextField with additional styling options and
/// built-in password visibility toggle functionality.
class StyledTextField extends StatefulWidget {
  /// Creates a text field.
  /// - `controller` - The controller for the text field.
  /// - `prefixIcon` - An optional icon displayed at the start of the text field.
  /// - `hintText` - The hint text displayed when the field is empty.
  /// - `bgColor` - The background color of the text field.
  /// - `margin` - The margin around the text field.
  /// - `isPasswordField` - Whether the text field is for password input(enable password visibility toggle functionality).
  /// - `borderRadius` - The border radius of the text field.
  /// - `obscuringCharacter` - The character used to obscure password input.
  /// - `rightContentPadding` - The right padding for the content inside the text field.
  /// - `leftContentPadding` - The left padding for the content inside the text field.
  const StyledTextField({
    super.key,
    this.controller,
    this.prefixIcon,
    this.hintText,
    this.bgColor,
    this.margin,
    this.isPasswordField = false,
    this.borderRadius = 10,
    this.obscuringCharacter = "ඞ",
    this.rightContentPadding = 0,
    this.leftContentPadding = 0,
  });

  final TextEditingController? controller;
  final Color? bgColor;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Icon? prefixIcon;
  final String? hintText;
  final bool isPasswordField;
  final String obscuringCharacter;
  final double rightContentPadding;
  final double leftContentPadding;

  @override
  State<StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.isPasswordField;

    super.initState();
  }

  void _togglePasswordVisibility() {
    setState(() => obscureText = !obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: obscureText,
        obscuringCharacter: widget.obscuringCharacter,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15).copyWith(
            right: widget.rightContentPadding,
            left: widget.leftContentPadding,
          ),
          prefixIcon: widget.isPasswordField
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.lock : Icons.lock_open,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : widget.prefixIcon,
        ),
      ),
    );
  }
}
