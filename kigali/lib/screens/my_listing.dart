import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import 'listing_detail.dart';
import 'listing_form.dart';

class MyListingScreen extends StatefulWidget {
  const MyListingScreen({super.key});

  @override
  State<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ListingsScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Listings'),
            Tab(text: 'My Listings'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListingFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  120,
                ),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: provider.setSearchQuery,
            ),
          ),

          // Category filter buttons (Home-tab style)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryButton(
                  context,
                  'All',
                  Icons.apps,
                  Colors.grey,
                  provider,
                  null,
                ),
                _buildCategoryButton(
                  context,
                  'Health',
                  Icons.local_hospital,
                  Colors.red,
                  provider,
                  'Health',
                ),
                _buildCategoryButton(
                  context,
                  'Government',
                  Icons.account_balance,
                  Colors.blue,
                  provider,
                  'Government',
                ),
                _buildCategoryButton(
                  context,
                  'Entertainment',
                  Icons.movie,
                  Colors.purple,
                  provider,
                  'Entertainment',
                ),
                _buildCategoryButton(
                  context,
                  'Education',
                  Icons.school,
                  Colors.orange,
                  provider,
                  'Education',
                ),
                _buildCategoryButton(
                  context,
                  'Tourist Attraction',
                  Icons.tour,
                  Colors.green,
                  provider,
                  'Tourist Attraction',
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllListingsTab(provider: provider, theme: theme),
                _MyListingsTab(provider: provider, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    ListingsProvider provider,
    String? category,
  ) {
    final isSelected = provider.selectedCategory == category;
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : color.withAlpha(40),
          foregroundColor: isSelected ? Colors.white : color,
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        onPressed: () {
          provider.setCategory(
            provider.selectedCategory == category ? null : category,
          );
        },
      ),
    );
  }
}

// ── All Listings Tab ──
class _AllListingsTab extends StatelessWidget {
  final ListingsProvider provider;
  final ThemeData theme;
  const _AllListingsTab({required this.provider, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(
              'Failed to load listings',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: provider.startListening,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final listings = provider.listings;
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.list_alt,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No listings found',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _ListingCard(listing: listings[index], provider: provider);
      },
    );
  }
}

// ── My Listings Tab ──
class _MyListingsTab extends StatelessWidget {
  final ListingsProvider provider;
  final ThemeData theme;
  const _MyListingsTab({required this.provider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final myListings = provider.allListings
        .where((l) => provider.isOwner(l))
        .toList();

    if (myListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.list_alt,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t created any listings yet',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListingFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Listing'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: myListings.length,
      itemBuilder: (context, index) {
        return _ListingCard(listing: myListings[index], provider: provider);
      },
    );
  }
}

// ── Shared listing card ──
class _ListingCard extends StatelessWidget {
  final Listing listing;
  final ListingsProvider provider;
  const _ListingCard({required this.listing, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = provider.isOwner(listing);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: listing),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcon(listing.category),
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      listing.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      listing.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.contactNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (isOwner) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingFormScreen(listing: listing),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _confirmDelete(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Delete "${listing.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteListing(listing);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Health':
        return Icons.local_hospital;
      case 'Government':
        return Icons.account_balance;
      case 'Entertainment':
        return Icons.movie;
      case 'Education':
        return Icons.school;
      case 'Tourist Attraction':
        return Icons.tour;
      default:
        return Icons.place;
    }
  }
}
