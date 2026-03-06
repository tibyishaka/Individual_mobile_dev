import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import 'listing_detail.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  const CategoryScreen({super.key, required this.title});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = ListingsScope.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final listings = provider.allListings
        .where((l) => l.category == widget.title)
        .where(
          (l) =>
              _searchQuery.isEmpty ||
              l.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.categoryLabel(widget.title) ?? widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n?.searchHint ?? 'Search...',
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
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (listings.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 56,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n?.noListings ?? 'No ${widget.title} listings found',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: listings.length,
                itemBuilder: (context, index) =>
                    _CategoryListingCard(listing: listings[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryListingCard extends StatelessWidget {
  final Listing listing;
  const _CategoryListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
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
