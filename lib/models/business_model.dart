import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  final String id, ownerId, name, category, subCategory, description, phone, whatsapp, address;
  final List<String> imageUrls;
  final double latitude, longitude, rating;
  final int ratingCount;
  final bool isVerified, isAvailable;
  final DateTime createdAt;

  BusinessModel({required this.id, required this.ownerId, required this.name, required this.category,
    required this.subCategory, required this.description, required this.phone, required this.whatsapp,
    required this.imageUrls, required this.latitude, required this.longitude, required this.address,
    this.rating = 0.0, this.ratingCount = 0, this.isVerified = false, this.isAvailable = true,
    required this.createdAt});

  factory BusinessModel.fromMap(String id, Map<String, dynamic> m) => BusinessModel(
    id: id, ownerId: m['ownerId'] ?? '', name: m['name'] ?? '', category: m['category'] ?? '',
    subCategory: m['subCategory'] ?? '', description: m['description'] ?? '', phone: m['phone'] ?? '',
    whatsapp: m['whatsapp'] ?? '', imageUrls: List<String>.from(m['imageUrls'] ?? []),
    latitude: (m['latitude'] ?? 0.0).toDouble(), longitude: (m['longitude'] ?? 0.0).toDouble(),
    address: m['address'] ?? '', rating: (m['rating'] ?? 0.0).toDouble(),
    ratingCount: m['ratingCount'] ?? 0, isVerified: m['isVerified'] ?? false,
    isAvailable: m['isAvailable'] ?? true,
    createdAt: (m['createdAt'] is Timestamp) ? (m['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId, 'name': name, 'category': category, 'subCategory': subCategory,
    'description': description, 'phone': phone, 'whatsapp': whatsapp, 'imageUrls': imageUrls,
    'latitude': latitude, 'longitude': longitude, 'address': address, 'rating': rating,
    'ratingCount': ratingCount, 'isVerified': isVerified, 'isAvailable': isAvailable,
    'createdAt': Timestamp.fromDate(createdAt), 'nameLower': name.toLowerCase(),
  };
}

class ReviewModel {
  final String id, businessId, userId, userName, comment;
  final double rating;
  final DateTime createdAt;

  ReviewModel({required this.id, required this.businessId, required this.userId,
    required this.userName, required this.rating, required this.comment, required this.createdAt});

  factory ReviewModel.fromMap(String id, Map<String, dynamic> m) => ReviewModel(
    id: id, businessId: m['businessId'] ?? '', userId: m['userId'] ?? '',
    userName: m['userName'] ?? '', rating: (m['rating'] ?? 0.0).toDouble(),
    comment: m['comment'] ?? '',
    createdAt: (m['createdAt'] is Timestamp) ? (m['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'businessId': businessId, 'userId': userId, 'userName': userName,
    'rating': rating, 'comment': comment, 'createdAt': Timestamp.fromDate(createdAt),
  };
}
