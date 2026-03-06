import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import 'listing_detail.dart';

/// Geographic center of Rwanda
const _rwandaCenter = LatLng(-1.9403, 29.8739);

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
    _Cat('Health', 'Health', Icons.local_hospital, Colors.red),
    _Cat('Government', 'Government', Icons.account_balance, Colors.blue),
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

    final position = await Geolocator.getCurrentPosition();
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
  Future<void> _fetchRoute() async {
    if (_userLocation == null || _searchedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need both your location and a destination'),
        ),
      );
      return;
    }

    setState(() => _isFetchingRoute = true);

    try {
      final from = '${_userLocation!.longitude},${_userLocation!.latitude}';
      final to =
          '${_searchedLocation!.longitude},${_searchedLocation!.latitude}';

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
      CameraUpdate.newLatLngZoom(_rwandaCenter, 9.0),
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
            _categoryHue(listing.category),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Map'), centerTitle: true),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place in Rwanda...',
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
                      },
                      itemBuilder: (_) => subcats
                          .map(
                            (s) => PopupMenuItem<String>(
                              value: s,
                              child: Text(
                                s,
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
                    target: _rwandaCenter,
                    zoom: 9.0,
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
                            ? 'Street View'
                            : 'Satellite View',
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
                        tooltip: 'My Location',
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

                      // Get directions (route)
                      _MapButton(
                        icon: _isFetchingRoute
                            ? Icons.hourglass_top
                            : Icons.directions,
                        tooltip: 'Get Directions',
                        onTap: _isFetchingRoute ? () {} : _fetchRoute,
                      ),
                      const SizedBox(height: 8),

                      // Clear / refresh
                      _MapButton(
                        icon: Icons.refresh,
                        tooltip: 'Clear Route',
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
  final VoidCallback onClear;
  const _ActiveFilterBanner({
    required this.subcategory,
    required this.color,
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
                'Showing: $subcategory',
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
