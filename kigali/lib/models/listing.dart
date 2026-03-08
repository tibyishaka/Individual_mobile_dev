import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String? id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final String? imageUrl;
  final String? subcategory;

  const Listing({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.imageUrl,
    this.subcategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (subcategory != null) 'subcategory': subcategory,
    };
  }

  factory Listing.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      address: data['address'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      description: data['description'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      subcategory: data['subcategory'] as String?,
    );
  }

  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    String? imageUrl,
    String? subcategory,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      subcategory: subcategory ?? this.subcategory,
    );
  }

  static const List<String> categories = [
    'Health',
    'Government',
    'Entertainment',
    'Education',
    'Tourist Attraction',
  ];

  static const Map<String, List<String>> subcategories = {
    'Health': [
      'Hospitals',
      'Clinics',
      'Pharmacies',
      'Polyclinics',
      'Dispensaries',
      'Specialized Clinics',
      'Health Insurance Offices',
    ],
    'Government': [
      'District Offices',
      'Province Offices',
      'Sector Offices',
      'Cell Offices',
      'Village Offices',
      'Police Stations',
      'RIB Stations',
      "Ministers' Offices",
    ],
    'Entertainment': [
      'Restaurants',
      'Cafes',
      'Hotels',
      'Lodges',
      'Stadiums',
      'Playgrounds',
      'Cinemas',
      'Nightlife',
      'Markets',
      'Supermarkets',
    ],
    'Education': [
      'Schools',
      'Universities',
      'Libraries',
      'Education Centers',
      'Training Centers',
    ],
    'Tourist Attraction': [
      'Museums',
      'Genocide Memorials',
      'Parks',
      'Cultural Sites',
      'Viewpoints',
      'Nature Reserves',
    ],
  };
}
