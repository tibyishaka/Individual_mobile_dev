import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/listing.dart';

class ListingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Listing> _listings = [];
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<Listing> get listings => _filteredListings;
  List<Listing> get allListings => _listings;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _auth.currentUser?.uid;

  List<Listing> get _filteredListings {
    var result = _listings;

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((l) => l.name.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  /// Start listening to all listings from Firestore in real time.
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection('listings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _listings = snapshot.docs
                .map((doc) => Listing.fromDocument(doc))
                .toList();
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Sign in anonymously so the user has a UID for ownership tracking.
  Future<void> ensureAuthenticated() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  /// Create a new listing.
  Future<void> createListing(Listing listing) async {
    await ensureAuthenticated();
    final uid = _auth.currentUser!.uid;
    final data = listing.copyWith(createdBy: uid, timestamp: DateTime.now());
    await _firestore.collection('listings').add(data.toMap());
  }

  /// Update a listing (only if the current user owns it).
  Future<void> updateListing(Listing listing) async {
    if (listing.id == null) return;
    if (listing.createdBy != currentUserId) return;
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .update(listing.toMap());
  }

  /// Delete a listing (only if the current user owns it).
  Future<void> deleteListing(Listing listing) async {
    if (listing.id == null) return;
    if (listing.createdBy != currentUserId) return;
    await _firestore.collection('listings').doc(listing.id).delete();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  bool isOwner(Listing listing) => listing.createdBy == currentUserId;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// InheritedWidget to propagate ListingsProvider down the tree.
class ListingsScope extends InheritedNotifier<ListingsProvider> {
  const ListingsScope({
    super.key,
    required ListingsProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static ListingsProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ListingsScope>()!
        .notifier!;
  }
}
