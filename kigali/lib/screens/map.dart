import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'category.dart';

// ─────────────────────────────────────────────────────────────
// Tile layer URLs (no API key needed)
// ─────────────────────────────────────────────────────────────
const _esriSatelliteUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/'
    'World_Imagery/MapServer/tile/{z}/{y}/{x}';

const _esriLabelsUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/'
    'Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';

const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Kigali bounding box – restricts panning to the city area.
final _kigaliBounds = LatLngBounds(
  const LatLng(-2.06, 29.90),
  const LatLng(-1.83, 30.20),
);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  static const _kigaliCenter = LatLng(-1.9441, 30.0619);

  bool _isSatellite = true;
  LatLng? _userLocation;
  LatLng? _searchedLocation;
  String? _searchedName;
  List<LatLng> _routePoints = [];
  bool _isSearching = false;
  bool _isFetchingRoute = false;

  // Search suggestions from Nominatim
  List<_SearchResult> _suggestions = [];

  static const _categories = [
    _Cat('Health', Icons.local_hospital, Colors.red),
    _Cat('Government', Icons.account_balance, Colors.blue),
    _Cat('Entertainment', Icons.movie, Colors.purple),
    _Cat('Education', Icons.school, Colors.orange),
    _Cat('Tourist', Icons.tour, Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
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
        '&viewbox=29.90,-2.06,30.20,-1.83'
        '&bounded=1',
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
      _routePoints = []; // clear old route
    });
    _searchController.text = _searchedName!;
    _mapController.move(point, 17.0);
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
      // OSRM expects lon,lat (not lat,lon)
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

        setState(() {
          _routePoints = coords
              .map<LatLng>(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
        });

        // Fit map to show entire route
        if (_routePoints.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(_routePoints);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
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
      setState(() => _isFetchingRoute = false);
    }
  }

  // ── Clear route and search ──
  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _searchedLocation = null;
      _searchedName = null;
      _suggestions = [];
    });
    _searchController.clear();
    _mapController.move(_kigaliCenter, 17.0);
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
                hintText: 'Search for a place in Kigali...',
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

          // ── Category Buttons Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _CategoryChip(
                      cat: cat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryScreen(title: cat.label),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Map ──
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _kigaliCenter,
                    initialZoom: 17.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _kigaliBounds,
                    ),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    // Base tile layer
                    TileLayer(
                      urlTemplate: _isSatellite ? _esriSatelliteUrl : _osmUrl,
                      userAgentPackageName: 'com.example.kigali',
                      maxZoom: 18,
                    ),

                    // Street-name overlay (satellite only)
                    if (_isSatellite)
                      TileLayer(
                        urlTemplate: _esriLabelsUrl,
                        userAgentPackageName: 'com.example.kigali',
                        maxZoom: 18,
                      ),

                    // Route polyline (blue line from user to destination)
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),

                    // Markers layer
                    MarkerLayer(
                      markers: [
                        // User location (blue dot)
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(180),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        // Searched destination (green pin)
                        if (_searchedLocation != null)
                          Marker(
                            point: _searchedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // ── Map control buttons (top-right) ──
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      // Toggle satellite / street view
                      _MapButton(
                        icon: _isSatellite ? Icons.map : Icons.satellite,
                        tooltip: _isSatellite
                            ? 'Street View'
                            : 'Satellite View',
                        onTap: () {
                          setState(() => _isSatellite = !_isSatellite);
                        },
                      ),
                      const SizedBox(height: 8),

                      // My location
                      _MapButton(
                        icon: Icons.my_location,
                        tooltip: 'My Location',
                        onTap: () async {
                          await _determinePosition();
                          if (_userLocation != null) {
                            _mapController.move(_userLocation!, 17.0);
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

// ── Marker icon widget ──
class _MarkerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MarkerIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ── Category data class ──
class _Cat {
  final String label;
  final IconData icon;
  final Color color;
  const _Cat(this.label, this.icon, this.color);
}

// ── Category chip button ──
class _CategoryChip extends StatelessWidget {
  final _Cat cat;
  final VoidCallback onTap;
  const _CategoryChip({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cat.color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.icon, color: Colors.white, size: 18),
              const SizedBox(height: 2),
              Text(
                cat.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
