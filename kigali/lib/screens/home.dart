import 'dart:async';
import 'package:flutter/material.dart';
import '../localisation/app_localizations.dart';
import 'settings.dart';
import 'category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _images = [
    'assets/images/kigali-Rwanda.jpg',
    'assets/images/Kigali.jpg',
    'assets/images/Kigali-Rwa.jpg',
    'assets/images/Kigali, Rwanda.jpg',
    'assets/images/Kigal.jpg',
    'assets/images/Kiga.jpg',
  ];

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(l10n?.homeWelcome ?? 'Welcome to Kigali')),
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
              child: Text(
                l10n?.homeDiscover ?? 'Discover Kigali',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final imageIndex = index % _images.length;
                    return Image.asset(
                      _images[imageIndex],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) {
                final isActive = (_currentPage % _images.length) == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            _buildCategoryButton(
              context,
              'Health',
              l10n?.catHealth ?? 'Health',
              Icons.local_hospital,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Government',
              l10n?.catGovernment ?? 'Government',
              Icons.account_balance,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Entertainment',
              l10n?.catEntertainment ?? 'Entertainment',
              Icons.movie,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Education',
              l10n?.catEducation ?? 'Education',
              Icons.school,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Tourist Attraction',
              l10n?.catTourist ?? 'Tourist Attraction',
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
    String categoryKey,
    String label,
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
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(title: categoryKey),
            ),
          );
        },
      ),
    );
  }
}
