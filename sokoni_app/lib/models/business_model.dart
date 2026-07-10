import 'package:cloud_firestore/cloud_firestore.dart';

/// Model ya biashara - inawakilisha document moja kwenye
/// Firestore collection "businesses"
class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String category;      // mafundi | maduka | beauty | restaurant
  final String subCategory;   // mfano: "Umeme", "Hair Salon"
  final String description;
  final String phone;
  final String whatsapp;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String address;       // mfano: "Kariakoo, Dar es Salaam"
  final double rating;
  final int ratingCount;
  final bool isVerified;
  final bool isAvailable;     // available now / busy
  final DateTime createdAt;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.phone,
    required this.whatsapp,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isVerified = false,
    this.isAvailable = true,
    required this.createdAt,
  });

  /// Tengeneza BusinessModel kutoka Firestore document
  factory BusinessModel.fromMap(String id, Map<String, dynamic> map) {
    return BusinessModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Badilisha kuwa Map kabla ya kusave Firestore
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'description': description,
      'phone': phone,
      'whatsapp': whatsapp,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'ratingCount': ratingCount,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      // muhimu kwa search rahisi (case-insensitive contains)
      'nameLower': name.toLowerCase(),
    };
  }
}

/// Model ndogo ya review/rating
class ReviewModel {
  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      businessId: map['businessId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
