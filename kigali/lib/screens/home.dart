import 'package:flutter/material.dart';
import 'settings.dart';
import 'category.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Welcome to Kigali')),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Discover Kigali',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/kigali-Rwanda.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryButton(
              context,
              'Health',
              Icons.local_hospital,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Government',
              Icons.account_balance,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Entertainment',
              Icons.movie,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Education',
              Icons.school,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Tourist Attraction',
              Icons.tour,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 18)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(title: title),
            ),
          );
        },
      ),
    );
  }
}
