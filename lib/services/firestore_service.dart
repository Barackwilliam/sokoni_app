import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _b => _db.collection(FirestoreCollections.businesses);
  CollectionReference get _r => _db.collection(FirestoreCollections.reviews);

  /// Generates a new business document id BEFORE saving, so images can be
  /// uploaded under the correct Storage path (businesses/{id}/...).
  String newBusinessId() => _b.doc().id;

  /// Saves a business under a pre-generated id (see [newBusinessId]).
  Future<void> setBusiness(String id, BusinessModel b) async {
    await _b.doc(id).set(b.toMap());
  }

  Future<BusinessModel?> getBusinessById(String id) async {
    final doc = await _b.doc(id).get();
    if (!doc.exists) return null;
    return BusinessModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Stream<List<BusinessModel>> streamByCategory(String cat) => _b
      .where('category', isEqualTo: cat)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList());

  /// Businesses owned by [ownerId]. Sorted client-side so no composite
  /// index is required.
  Stream<List<BusinessModel>> streamByOwner(String ownerId) => _b
      .where('ownerId', isEqualTo: ownerId)
      .snapshots()
      .map((s) {
        final list = s.docs
            .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> updateBusiness(String id, Map<String, dynamic> data) async {
    await _b.doc(id).update(data);
  }

  Future<void> deleteBusiness(String id) async {
    await _b.doc(id).delete();
  }

  Future<List<BusinessModel>> searchByName(String q) async {
    final lower = q.toLowerCase();
    final s = await _b
        .where('nameLower', isGreaterThanOrEqualTo: lower)
        .where('nameLower', isLessThanOrEqualTo: '$lower\uf8ff')
        .limit(30)
        .get();
    return s.docs
        .map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  /// One review per user per business (doc id = businessId_userId).
  /// Submitting again UPDATES the existing review and the business average
  /// is recalculated correctly inside a single transaction.
  Future<void> addReview(ReviewModel r) async {
    final reviewRef = _r.doc('${r.businessId}_${r.userId}');
    final bRef = _b.doc(r.businessId);

    await _db.runTransaction((tx) async {
      // All reads must happen before any writes in a transaction.
      final bSnap = await tx.get(bRef);
      final oldReviewSnap = await tx.get(reviewRef);
      if (!bSnap.exists) return;

      final data = bSnap.data() as Map<String, dynamic>;
      final curAvg = (data['rating'] ?? 0.0).toDouble();
      final curCnt = (data['ratingCount'] ?? 0) as int;

      double newAvg;
      int newCnt;
      if (oldReviewSnap.exists) {
        // Replace this user's previous rating in the average.
        final oldRating =
            ((oldReviewSnap.data() as Map<String, dynamic>)['rating'] ?? 0.0)
                .toDouble();
        newCnt = curCnt == 0 ? 1 : curCnt;
        newAvg = ((curAvg * newCnt) - oldRating + r.rating) / newCnt;
      } else {
        newCnt = curCnt + 1;
        newAvg = ((curAvg * curCnt) + r.rating) / newCnt;
      }

      tx.set(reviewRef, r.toMap());
      tx.update(bRef, {
        'rating': double.parse(newAvg.toStringAsFixed(2)),
        'ratingCount': newCnt,
      });
    });
  }

  Stream<List<ReviewModel>> streamReviews(String businessId) => _r
      .where('businessId', isEqualTo: businessId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => ReviewModel.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList());
}
