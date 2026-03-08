import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../localisation/app_localizations.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import 'listing_detail.dart';

/// Geographic center of Kigali City
const _kigaliCenter = LatLng(-1.9441, 30.0619);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  MapType _mapType = MapType.normal;
  LatLng? _userLocation;
  LatLng? _searchedLocation;
  String? _searchedName;
  Set<Polyline> _polylines = {};
  bool _isSearching = false;
  bool _isFetchingRoute = false;

  List<_SearchResult> _suggestions = [];
  String? _selectedSubcategory;
  String? _selectedCategoryFilter;

  static const _categories = [
    _Cat('Health', 'Health', Icons.local_hospital, Colors.blue),
    _Cat('Govt', 'Government', Icons.account_balance, Colors.teal),
    _Cat('Entertain.', 'Entertainment', Icons.movie, Colors.purple),
    _Cat('Education', 'Education', Icons.school, Colors.orange),
    _Cat('Tourist', 'Tourist Attraction', Icons.tour, Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Rwanda geographic bounds (used to validate GPS results) ──
  static bool _isInRwanda(double lat, double lng) {
    // Rwanda bounding box with a small buffer
    return lat >= -3.0 && lat <= -1.0 && lng >= 28.8 && lng <= 31.0;
  }

  // ── Location permission & fetch ──
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Ignore emulator / spoofed locations outside Rwanda
    if (!_isInRwanda(position.latitude, position.longitude)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Live location unavailable — showing Kigali city centre.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 16.0),
      );
    }
  }

  // ── Search places using Nominatim (free, no API key) ──
  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=5'
        '&countrycodes=rw',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'KigaliApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions = data.map((item) {
            return _SearchResult(
              name: item['display_name'] as String,
              lat: double.parse(item['lat'] as String),
              lon: double.parse(item['lon'] as String),
            );
          }).toList();
        });
      }
    } catch (_) {
      // Silently handle network errors
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // ── Select a search result ──
  void _selectSearchResult(_SearchResult result) {
    final point = LatLng(result.lat, result.lon);
    setState(() {
      _searchedLocation = point;
      _searchedName = result.name.split(',').first;
      _suggestions = [];
      _polylines = {};
    });
    _searchController.text = _searchedName!;
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(point, 16.0));
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ── Fetch route from OSRM (free, no API key) ──
  Future<void> _fetchRoute(LatLng destination, String destinationName) async {
    if (_userLocation == null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noLocationWarning)));
      }
      return;
    }

    setState(() {
      _isFetchingRoute = true;
      _searchedLocation = destination;
      _searchedName = destinationName;
    });

    try {
      final from = '${_userLocation!.longitude},${_userLocation!.latitude}';
      final to = '${destination.longitude},${destination.latitude}';

      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$from;$to'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        final routePoints = coords
            .map<LatLng>(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();

        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: Colors.blue,
              width: 5,
            ),
          };
        });

        // Fit map to show entire route
        if (routePoints.isNotEmpty) {
          final bounds = _boundsFromPoints(routePoints);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 60),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not fetch route')));
      }
    } finally {
      if (mounted) setState(() => _isFetchingRoute = false);
    }
  }

  // ── Open directions bottom-sheet popup ──
  void _openDirectionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DirectionsSheet(
        userLocation: _userLocation,
        onNavigate: (destination, name) {
          Navigator.pop(ctx);
          _fetchRoute(destination, name);
        },
      ),
    );
  }

  // ── Compute bounds from a list of points ──
  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ── Clear route and search ──
  void _clearRoute() {
    setState(() {
      _polylines = {};
      _searchedLocation = null;
      _searchedName = null;
      _suggestions = [];
    });
    _searchController.clear();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_kigaliCenter, 13.0),
    );
  }

  // ── Build all map markers ──
  Set<Marker> _buildMarkers(BuildContext context) {
    final markers = <Marker>{};

    // Searched location marker
    if (_searchedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('searched'),
          position: _searchedLocation!,
          infoWindow: InfoWindow(title: _searchedName ?? 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // Listing markers from Firestore
    final provider = ListingsScope.of(context);
    var listings = provider.allListings
        .where((l) => l.latitude != 0.0 || l.longitude != 0.0)
        .toList();

    if (_selectedSubcategory != null && _selectedCategoryFilter != null) {
      listings = listings
          .where(
            (l) =>
                l.category == _selectedCategoryFilter &&
                l.subcategory == _selectedSubcategory,
          )
          .toList();
    }

    for (final listing in listings) {
      markers.add(
        Marker(
          markerId: MarkerId(listing.id ?? listing.name),
          position: LatLng(listing.latitude, listing.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _selectedSubcategory != null
                ? BitmapDescriptor.hueBlue
                : _categoryHue(listing.category),
          ),
          infoWindow: InfoWindow(
            title: listing.name,
            snippet: listing.subcategory,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(listing: listing),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ── Fit camera to all markers matching the active subcategory filter ──
  void _fitToFilteredMarkers() {
    final provider = ListingsScope.of(context);
    final filtered = provider.allListings
        .where(
          (l) =>
              (l.latitude != 0.0 || l.longitude != 0.0) &&
              l.category == _selectedCategoryFilter &&
              l.subcategory == _selectedSubcategory,
        )
        .toList();

    if (filtered.isEmpty) return;

    if (filtered.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(filtered.first.latitude, filtered.first.longitude),
          15.0,
        ),
      );
      return;
    }

    final points = filtered
        .map((l) => LatLng(l.latitude, l.longitude))
        .toList();
    final bounds = _boundsFromPoints(points);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  double _categoryHue(String cat) {
    switch (cat) {
      case 'Health':
        return BitmapDescriptor.hueBlue;
      case 'Government':
        return BitmapDescriptor.hueCyan;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMap), centerTitle: true),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHintMap,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions = []);
                        },
                      ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  120,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchPlace,
              onSubmitted: _searchPlace,
            ),
          ),

          // ── Search Suggestions ──
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                // ignore: unnecessary_underscores
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final result = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place, size: 20),
                    title: Text(
                      result.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),

          // ── Category Dropdown Buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              children: _categories.map((cat) {
                final subcats = Listing.subcategories[cat.listingKey] ?? [];
                final isActive = _selectedCategoryFilter == cat.listingKey;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PopupMenuButton<String>(
                      tooltip: cat.label,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (sub) {
                        setState(() {
                          _selectedSubcategory = sub;
                          _selectedCategoryFilter = cat.listingKey;
                        });
                        // Zoom the camera to show all matching markers
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _fitToFilteredMarkers();
                        });
                      },
                      itemBuilder: (_) => subcats
                          .map(
                            (s) => PopupMenuItem<String>(
                              value: s,
                              child: Text(
                                l10n.subcategoryLabel(s),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cat.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: _CategoryChip(cat: cat, isActive: isActive),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Active filter banner ──
          if (_selectedSubcategory != null)
            _ActiveFilterBanner(
              subcategory: _selectedSubcategory!,
              showingLabel: l10n.showingFilter,
              color: _categories
                  .firstWhere(
                    (c) => c.listingKey == _selectedCategoryFilter,
                    orElse: () => _categories.first,
                  )
                  .color,
              onClear: () => setState(() {
                _selectedSubcategory = null;
                _selectedCategoryFilter = null;
              }),
            ),

          // ── Google Map ──
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: _mapType,
                  initialCameraPosition: const CameraPosition(
                    target: _kigaliCenter,
                    zoom: 13.0,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _buildMarkers(context),
                  polylines: _polylines,
                ),

                // ── Map control buttons (top-right) ──
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      // Toggle street / satellite
                      _MapButton(
                        icon: _mapType == MapType.satellite
                            ? Icons.map
                            : Icons.satellite,
                        tooltip: _mapType == MapType.satellite
                            ? l10n.streetView
                            : l10n.satelliteView,
                        onTap: () => setState(() {
                          _mapType = _mapType == MapType.normal
                              ? MapType.satellite
                              : MapType.normal;
                        }),
                      ),
                      const SizedBox(height: 8),

                      // My location
                      _MapButton(
                        icon: Icons.my_location,
                        tooltip: l10n.myLocation,
                        onTap: () async {
                          await _determinePosition();
                          if (_userLocation != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(_userLocation!, 16.0),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),

                      // Get directions → opens popup
                      _MapButton(
                        icon: _isFetchingRoute
                            ? Icons.hourglass_top
                            : Icons.directions,
                        tooltip: l10n.getDirections,
                        onTap: _isFetchingRoute ? () {} : _openDirectionsSheet,
                      ),
                      const SizedBox(height: 8),

                      // Zoom In
                      _MapButton(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: () => _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Zoom Out
                      _MapButton(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: () => _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Clear / refresh
                      _MapButton(
                        icon: Icons.refresh,
                        tooltip: l10n.clearRoute,
                        onTap: _clearRoute,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Directions bottom-sheet popup
// ─────────────────────────────────────────────────────────────────────────────

class _DirectionsSheet extends StatefulWidget {
  final LatLng? userLocation;
  final void Function(LatLng destination, String name) onNavigate;

  const _DirectionsSheet({
    required this.userLocation,
    required this.onNavigate,
  });

  @override
  State<_DirectionsSheet> createState() => _DirectionsSheetState();
}

class _DirectionsSheetState extends State<_DirectionsSheet> {
  final TextEditingController _destController = TextEditingController();
  List<_SearchResult> _suggestions = [];
  bool _isSearching = false;
  _SearchResult? _selected;

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  Future<void> _searchDestination(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _selected = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _selected = null;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=6'
        '&countrycodes=rw',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'KigaliApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions = data
              .map(
                (item) => _SearchResult(
                  name: item['display_name'] as String,
                  lat: double.parse(item['lat'] as String),
                  lon: double.parse(item['lon'] as String),
                ),
              )
              .toList();
        });
      }
    } catch (_) {
      // Silently handle network errors
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(_SearchResult result) {
    setState(() {
      _selected = result;
      _suggestions = [];
      _destController.text = result.name.split(',').first;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearDestination() {
    _destController.clear();
    setState(() {
      _suggestions = [];
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.directionsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // From: current location row
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(120),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.userLocation != null
                            ? l10n.yourLocation
                            : l10n.gettingLocation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Dotted connector
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Container(
                  width: 2,
                  height: 16,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(60),
                ),
              ),

              // To: search field row
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _destController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l10n.searchDestination,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(120),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _destController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearDestination,
                              )
                            : null,
                      ),
                      onChanged: (v) {
                        setState(() {}); // refresh clear button visibility
                        _searchDestination(v);
                      },
                      onSubmitted: _searchDestination,
                    ),
                  ),
                ],
              ),

              // Suggestion list
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 32),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    // ignore: unnecessary_underscores
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 12, endIndent: 12),
                    itemBuilder: (_, i) {
                      final r = _suggestions[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.place, size: 18),
                        title: Text(
                          r.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () => _selectSuggestion(r),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Get Directions button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selected != null
                      ? () => widget.onNavigate(
                          LatLng(_selected!.lat, _selected!.lon),
                          _selected!.name.split(',').first,
                        )
                      : null,
                  icon: const Icon(Icons.directions),
                  label: Text(l10n.getDirections),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search result model ──
class _SearchResult {
  final String name;
  final double lat;
  final double lon;
  const _SearchResult({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

// ── Reusable map floating button ──
class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

// ── Category data class ──
class _Cat {
  final String label;
  final String listingKey; // matches Listing.categories key
  final IconData icon;
  final Color color;
  const _Cat(this.label, this.listingKey, this.icon, this.color);
}

// ── Category chip button (used as PopupMenuButton child) ──
class _CategoryChip extends StatelessWidget {
  final _Cat cat;
  final bool isActive;
  const _CategoryChip({required this.cat, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? cat.color : cat.color.withAlpha(220),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat.icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    cat.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active filter banner ──
class _ActiveFilterBanner extends StatelessWidget {
  final String subcategory;
  final Color color;
  final String showingLabel;
  final VoidCallback onClear;
  const _ActiveFilterBanner({
    required this.subcategory,
    required this.color,
    required this.showingLabel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$showingLabel: $subcategory',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, size: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
