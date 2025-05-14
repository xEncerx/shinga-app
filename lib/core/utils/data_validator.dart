class TFValidator {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    } else if (value.length < 8) {
      return "Password must contain at least 8 characters";
    }
    if (!RegExp(r"^(?=.*[A-Z])(?=.*[a-z]).{8,}$").hasMatch(value)) {
      return "Password needs upper and lowercase letters";
    }
    return null;
  }

  static String? checkOnNullOrEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "All fields must be filled";
    }
    return null;
  }

  static String? checkOnPasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return null;
  }
}
