import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(Constants.appName, style: const TextStyle(fontSize: 24));
  }
}
