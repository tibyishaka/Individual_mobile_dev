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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
            const SizedBox(height: 20),

            // ── Tagline section ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Everything Kigali, in one place.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find hospitals, government offices, restaurants, schools '
                    'and hidden gems — all across the city. Tap a category to get started.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section header above buttons ──
            Row(
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildCategoryButton(
              context,
              'Health',
              l10n?.catHealth ?? 'Health',
              'Hospitals · Clinics · Pharmacies · Polyclinics',
              Icons.local_hospital,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Government',
              l10n?.catGovernment ?? 'Government',
              'Police Stations · District & Sector Offices · RIB',
              Icons.account_balance,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Entertainment',
              l10n?.catEntertainment ?? 'Entertainment',
              'Restaurants · Hotels · Cafés · Cinemas · Nightlife',
              Icons.movie,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Education',
              l10n?.catEducation ?? 'Education',
              'Schools · Universities · Libraries · Training Centers',
              Icons.school,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCategoryButton(
              context,
              'Tourist Attraction',
              l10n?.catTourist ?? 'Tourist Attraction',
              'Museums · Parks · Genocide Memorials · Cultural Sites',
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
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(title: categoryKey),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
