import 'package:flutter/material.dart';

extension BoldTextStyle on TextStyle? {
  TextStyle? get bold => this?.copyWith(
        fontWeight: FontWeight.bold,
      );
}

extension SemiBoldTextStyle on TextStyle? {
  TextStyle? get semiBold => this?.copyWith(
        fontWeight: FontWeight.w600,
      );
}
