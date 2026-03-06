import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  const Review({
    this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory Review.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
