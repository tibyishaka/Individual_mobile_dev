import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/listing.dart';
import '../providers/listings_provider.dart';

class ListingFormScreen extends StatefulWidget {
  final Listing? listing;
  const ListingFormScreen({super.key, this.listing});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  bool _isSaving = false;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameController = TextEditingController(text: l?.name ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _contactController = TextEditingController(text: l?.contactNumber ?? '');
    _descriptionController = TextEditingController(text: l?.description ?? '');
    _selectedCategory = l?.category ?? Listing.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Geocode an address string using Nominatim, biased to Kigali.
  Future<({double lat, double lng})?> _geocodeAddress(String address) async {
    final query = '$address, Kigali, Rwanda';
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&limit=1'
      '&viewbox=29.90,-2.06,30.20,-1.83'
      '&bounded=1',
    );
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'KigaliApp/1.0'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        return (
          lat: double.parse(data[0]['lat'] as String),
          lng: double.parse(data[0]['lon'] as String),
        );
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = ListingsScope.of(context);
      final address = _addressController.text.trim();

      // Use existing coordinates when editing, otherwise geocode the address.
      double lat = widget.listing?.latitude ?? 0.0;
      double lng = widget.listing?.longitude ?? 0.0;

      final addressChanged = !_isEditing || address != widget.listing!.address;

      if (addressChanged) {
        final coords = await _geocodeAddress(address);
        if (coords != null) {
          lat = coords.lat;
          lng = coords.lng;
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not find coordinates for this address. '
                'Listing saved with default location.',
              ),
            ),
          );
        }
      }

      final listing = Listing(
        id: widget.listing?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: address,
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        createdBy: widget.listing?.createdBy ?? '',
        timestamp: widget.listing?.timestamp ?? DateTime.now(),
      );

      if (_isEditing) {
        await provider.updateListing(listing);
      } else {
        await provider.createListing(listing);
      }

      if (mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Listing' : 'New Listing'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Place / Service Name', Icons.place),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: _inputDecoration('Category', Icons.category),
              items: Listing.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration(
                'Address (street & area)',
                Icons.location_on,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              decoration: _inputDecoration('Contact Number', Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Contact is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration('Description', Icons.description),
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? 'Save Changes' : 'Create Listing'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
