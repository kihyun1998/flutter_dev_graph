import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import '../widgets/loading_indicator.dart';
import 'product_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Helpers.getAppTitle())),
      body: Column(
        children: [
          ListTile(
            title: const Text('Products'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
