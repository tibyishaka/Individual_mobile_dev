import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localisation/app_localizations.dart';
import '../models/listing.dart';
import '../models/review.dart';
import '../providers/listings_provider.dart';
import 'listing_form.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final provider = ListingsScope.of(context);
    final theme = Theme.of(context);
    final hasCoords = listing.latitude != 0.0 || listing.longitude != 0.0;
    final isOwner = provider.isOwner(listing);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: listing.imageUrl != null ? 240 : 160,
            pinned: true,
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingFormScreen(listing: listing),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete listing',
                  onPressed: () => _confirmDelete(context, provider),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                listing.name,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: listing.imageUrl != null
                  ? Image.network(
                      listing.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _CategoryGradient(category: listing.category),
                    )
                  : _CategoryGradient(category: listing.category),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Badge ──
                  _CategoryBadge(category: listing.category),
                  const SizedBox(height: 20),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          onPressed: () =>
                              _launchPhone(context, listing.contactNumber),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          onPressed: hasCoords
                              ? () => _launchDirections(context, listing)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Info Section ──
                  _InfoTile(
                    Icons.location_on,
                    'Address',
                    listing.address,
                    theme,
                  ),
                  _InfoTile(
                    Icons.phone,
                    'Contact',
                    listing.contactNumber,
                    theme,
                  ),
                  _InfoTile(
                    Icons.description,
                    'Description',
                    listing.description,
                    theme,
                  ),
                  const SizedBox(height: 20),

                  // ── Mini Map ──
                  if (hasCoords) ...[
                    Text(
                      'Location',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(listing.latitude, listing.longitude),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('location'),
                              position: LatLng(
                                listing.latitude,
                                listing.longitude,
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                _categoryHue(listing.category),
                              ),
                            ),
                          },
                          zoomGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          liteModeEnabled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Reviews ──
                  if (listing.id != null)
                    _ReviewsSection(
                      listing: listing,
                      provider: provider,
                      theme: theme,
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ListingsProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListingTitle),
        content: Text(l10n.deleteConfirmMsg(listing.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await provider.deleteListing(listing);
              if (context.mounted) Navigator.pop(context); // go back
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String number) async {
    final uri = Uri.parse('tel:${number.replaceAll(' ', '')}');
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not call $number')));
      }
    }
  }

  Future<void> _launchDirections(BuildContext context, Listing l) async {
    String originParam = '';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          originParam = '&origin=${pos.latitude},${pos.longitude}';
        }
      }
    } catch (_) {}

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '$originParam'
      '&destination=${l.latitude},${l.longitude}&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
    }
  }
}

// ── Category gradient hero background ──
class _CategoryGradient extends StatelessWidget {
  final String category;
  const _CategoryGradient({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(200), color.withAlpha(100)],
        ),
      ),
      child: Center(
        child: Icon(
          _categoryIcon(category),
          size: 64,
          color: Colors.white.withAlpha(180),
        ),
      ),
    );
  }
}

// ── Category badge ──
class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_categoryIcon(category), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Info row ──
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  const _InfoTile(this.icon, this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reviews section ──
class _ReviewsSection extends StatefulWidget {
  final Listing listing;
  final ListingsProvider provider;
  final ThemeData theme;
  const _ReviewsSection({
    required this.listing,
    required this.provider,
    required this.theme,
  });

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  double _newRating = 0;
  final _commentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: widget.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // ── Write Review Card ──
        Card(
          elevation: 0,
          color: widget.theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write a Review',
                  style: widget.theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                _StarPicker(
                  rating: _newRating,
                  onChanged: (r) => setState(() => _newRating = r),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: _isSaving || _newRating == 0
                        ? null
                        : _submitReview,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Reviews List ──
        StreamBuilder<List<Review>>(
          stream: widget.provider.getReviews(widget.listing.id!),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reviews = snap.data ?? [];
            if (reviews.isEmpty) {
              return Center(
                child: Text(
                  'No reviews yet — be the first!',
                  style: TextStyle(
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final avg =
                reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Average summary
                Row(
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: widget.theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StarDisplay(rating: avg),
                        Text(
                          '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                          style: widget.theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...reviews.map(
                  (r) => _ReviewCard(review: r, theme: widget.theme),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSaving = true);
    try {
      await widget.provider.ensureAuthenticated();
      final displayName = await widget.provider.getDisplayName() ?? 'Anonymous';
      final review = Review(
        userId: widget.provider.currentUserId!,
        userName: displayName,
        rating: _newRating,
        comment: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );
      await widget.provider.addReview(widget.listing.id!, review);
      if (mounted) {
        _commentController.clear();
        setState(() => _newRating = 0);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Tap-to-select star rating ──
class _StarPicker extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  const _StarPicker({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onChanged((i + 1).toDouble()),
          child: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 34,
          ),
        );
      }),
    );
  }
}

// ── Read-only star display ──
class _StarDisplay extends StatelessWidget {
  final double rating;
  const _StarDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        }
        if (rating > i) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        }
        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
      }),
    );
  }
}

// ── Single review card ──
class _ReviewCard extends StatelessWidget {
  final Review review;
  final ThemeData theme;
  const _ReviewCard({required this.review, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.userName,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                _StarDisplay(rating: review.rating),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.comment, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared category helpers ──
Color _categoryColor(String cat) {
  switch (cat) {
    case 'Health':
      return Colors.red;
    case 'Government':
      return Colors.blue;
    case 'Entertainment':
      return Colors.purple;
    case 'Education':
      return Colors.orange;
    case 'Tourist Attraction':
      return Colors.green;
    default:
      return Colors.deepPurple;
  }
}

double _categoryHue(String cat) {
  switch (cat) {
    case 'Health':
      return BitmapDescriptor.hueRed;
    case 'Government':
      return BitmapDescriptor.hueBlue;
    case 'Entertainment':
      return BitmapDescriptor.hueViolet;
    case 'Education':
      return BitmapDescriptor.hueOrange;
    case 'Tourist Attraction':
      return BitmapDescriptor.hueGreen;
    default:
      return BitmapDescriptor.hueMagenta;
  }
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
