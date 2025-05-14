import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    this.controller,
    this.prefixIcon,
    this.hintText,
    this.bgColor,
    this.margin,
    this.isPasswordField = false,
    this.borderRadius = 0,
    this.obscuringCharacter = "ඞ",
    this.rightContentPadding = 0,
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

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
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
