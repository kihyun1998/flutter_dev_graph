class Validators {
  static bool isValidEmail(String email) {
    return email.contains('@');
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}
