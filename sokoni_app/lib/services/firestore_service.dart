import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

/// Inashughulikia kusoma/kuandika data ya biashara kwenye Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _businesses =>
      _db.collection(FirestoreCollections.businesses);

  /// Ongeza biashara mpya (business owner registration)
  Future<String> addBusiness(BusinessModel business) async {
    final doc = await _businesses.add(business.toMap());
    return doc.id;
  }

  /// Sasisha taarifa za biashara
  Future<void> updateBusiness(String id, Map<String, dynamic> data) async {
    await _businesses.doc(id).update(data);
  }

  /// Pata biashara moja kwa id (business profile screen)
  Future<BusinessModel?> getBusinessById(String id) async {
    final doc = await _businesses.doc(id).get();
    if (!doc.exists) return null;
    return BusinessModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Stream ya biashara zote za category fulani (mfano Home -> category tab)
  Stream<List<BusinessModel>> streamByCategory(String category) {
    return _businesses
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Search rahisi kwa jina la biashara (prefix search - haihitaji
  /// huduma ya nje kama Algolia, inatosha kwa MVP)
  Future<List<BusinessModel>> searchByName(String query) async {
    final lower = query.toLowerCase();
    final snap = await _businesses
        .where('nameLower', isGreaterThanOrEqualTo: lower)
        .where('nameLower', isLessThanOrEqualTo: '$lower\uf8ff')
        .limit(30)
        .get();
    return snap.docs
        .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Biashara zilizopo karibu - MVP version: pata zote za category na
  /// u-filter kwa umbali kwenye app (haitumii geo-query ngumu bado).
  /// Phase 2 tunaweza kuongeza geohash kwa usahihi zaidi.
  Future<List<BusinessModel>> getAllBusinesses({int limit = 50}) async {
    final snap = await _businesses
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  // ---------------- Reviews ----------------

  Future<void> addReview(ReviewModel review) async {
    final reviewRef = _db.collection(FirestoreCollections.reviews).doc();
    await reviewRef.set(review.toMap());

    // Sasisha average rating ya biashara husika kwa transaction
    final businessRef = _businesses.doc(review.businessId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(businessRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final currentCount = (data['ratingCount'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;

      tx.update(businessRef, {
        'rating': double.parse(newRating.toStringAsFixed(2)),
        'ratingCount': newCount,
      });
    });
  }

  Stream<List<ReviewModel>> streamReviews(String businessId) {
    return _db
        .collection(FirestoreCollections.reviews)
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ReviewModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }
}
