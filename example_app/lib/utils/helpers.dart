import 'constants.dart';

class Helpers {
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String getAppTitle() {
    return Constants.appName;
  }
}
