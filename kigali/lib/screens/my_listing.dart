import 'package:flutter/material.dart';

class MyListingScreen extends StatelessWidget {
  const MyListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('My Listing')),
      ),
      body: const Center(
        child: Text('My Listing'),
      ),
    );
  }
}
