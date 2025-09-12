extension DoubleRounding on double {
  /// Rounds a number to the specified number of decimal places
  /// 
  /// [precision] - number of decimal places (0-20)
  /// 
  /// Returns a double with the rounded value
  double roundToPrecision(int precision) {
    assert(precision >= 0 && precision <= 20, 
        'Precision must be between 0 and 20');
    return double.parse(toStringAsFixed(precision));
  }
}
